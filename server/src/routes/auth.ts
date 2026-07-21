import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { hashPassword, verifyPassword } from '../lib/password.js';
import { prisma } from '../lib/prisma.js';
import { createSession, hashRefreshToken, publicUser, rotateSession } from '../lib/tokens.js';
import { requireAuthentication } from '../plugins/auth.js';

const credentialsSchema = z.object({
  email: z.string().trim().email().max(254).transform((value) => value.toLowerCase()),
  password: z.string().min(12, 'Password must contain at least 12 characters.').max(128),
});

const registrationSchema = credentialsSchema.extend({
  fullName: z.string().trim().min(2).max(120),
  idNumber: z.string().trim().min(4).max(64).optional(),
});

export async function registerAuthRoutes(app: FastifyInstance): Promise<void> {
  app.post('/auth/register', {
    schema: { tags: ['Authentication'], summary: 'Create a customer account' },
  }, async (request, reply) => {
    const body = registrationSchema.parse(request.body);
    const user = await prisma.user.create({
      data: {
        email: body.email,
        fullName: body.fullName,
        idNumber: body.idNumber,
        passwordHash: await hashPassword(body.password),
      },
    });
    const session = await createSession(app, user);
    return reply.status(201).send({ user: publicUser(user), ...session });
  });

  app.post('/auth/login', {
    schema: { tags: ['Authentication'], summary: 'Sign in with email and password' },
  }, async (request, reply) => {
    const body = credentialsSchema.parse(request.body);
    const user = await prisma.user.findUnique({ where: { email: body.email } });
    const validPassword = user && user.isActive && await verifyPassword(body.password, user.passwordHash);
    if (!validPassword || !user) {
      return reply.code(401).send({ error: 'UNAUTHORIZED', message: 'Invalid email or password.' });
    }

    const session = await createSession(app, user);
    return { user: publicUser(user), ...session };
  });

  app.post('/auth/refresh', {
    schema: { tags: ['Authentication'], summary: 'Rotate a refresh token' },
  }, async (request, reply) => {
    const body = z.object({ refreshToken: z.string().min(32) }).parse(request.body);
    const session = await rotateSession(app, body.refreshToken);
    if (!session) {
      return reply.code(401).send({ error: 'UNAUTHORIZED', message: 'Your session has expired. Please sign in again.' });
    }
    return { user: publicUser(session.user), accessToken: session.accessToken, refreshToken: session.refreshToken };
  });

  app.post('/auth/logout', {
    schema: { tags: ['Authentication'], summary: 'Revoke the current refresh token' },
  }, async (request, reply) => {
    const body = z.object({ refreshToken: z.string().min(32) }).parse(request.body);
    await prisma.refreshToken.updateMany({
      where: { tokenHash: hashRefreshToken(body.refreshToken), revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return reply.status(204).send();
  });

  app.get('/auth/me', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Authentication'], summary: 'Get the signed-in user' },
  }, async (request, reply) => {
    const user = await prisma.user.findUnique({ where: { id: request.user.sub } });
    if (!user || !user.isActive) {
      return reply.code(401).send({ error: 'UNAUTHORIZED', message: 'Your account is not available.' });
    }
    return { user: publicUser(user) };
  });
}

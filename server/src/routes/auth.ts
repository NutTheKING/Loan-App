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
  phone: z.string().trim().min(7).max(30).refine(
    (value) => value.replace(/\D/g, '').length >= 7,
    'Phone number must contain at least 7 digits.',
  ),
  idNumber: z.string().trim().min(4).max(64),
  dateOfBirth: z.coerce.date(),
  gender: z.enum(['Male', 'Female', 'Other']),
  address: z.string().trim().min(5).max(500),
  acceptedTerms: z.literal(true),
}).superRefine((value, context) => {
  const today = new Date();
  const adultCutoff = new Date(today.getFullYear() - 18, today.getMonth(), today.getDate());
  if (value.dateOfBirth > adultCutoff) {
    context.addIssue({
      code: 'custom',
      path: ['dateOfBirth'],
      message: 'Customers must be at least 18 years old.',
    });
  }
});

const credentialsBodySchema = {
  type: 'object',
  additionalProperties: false,
  required: ['email', 'password'],
  properties: {
    email: { type: 'string', format: 'email', maxLength: 254 },
    password: { type: 'string', minLength: 12, maxLength: 128 },
  },
} as const;

const registrationBodySchema = {
  ...credentialsBodySchema,
  required: [
    'fullName',
    'email',
    'phone',
    'password',
    'idNumber',
    'dateOfBirth',
    'gender',
    'address',
    'acceptedTerms',
  ],
  properties: {
    fullName: { type: 'string', minLength: 2, maxLength: 120 },
    email: credentialsBodySchema.properties.email,
    phone: { type: 'string', minLength: 7, maxLength: 30 },
    password: credentialsBodySchema.properties.password,
    idNumber: { type: 'string', minLength: 4, maxLength: 64 },
    dateOfBirth: { type: 'string', format: 'date' },
    gender: { type: 'string', enum: ['Male', 'Female', 'Other'] },
    address: { type: 'string', minLength: 5, maxLength: 500 },
    acceptedTerms: { type: 'boolean', enum: [true] },
  },
} as const;

const refreshTokenBodySchema = {
  type: 'object',
  additionalProperties: false,
  required: ['refreshToken'],
  properties: {
    refreshToken: { type: 'string', minLength: 32 },
  },
} as const;

export async function registerAuthRoutes(app: FastifyInstance): Promise<void> {
  app.post('/auth/register', {
    schema: {
      tags: ['Authentication'],
      summary: 'Create a customer account',
      body: registrationBodySchema,
    },
  }, async (request, reply) => {
    const body = registrationSchema.parse(request.body);
    const user = await prisma.user.create({
      data: {
        email: body.email,
        fullName: body.fullName,
        phone: body.phone,
        idNumber: body.idNumber,
        dateOfBirth: body.dateOfBirth,
        gender: body.gender,
        address: body.address,
        passwordHash: await hashPassword(body.password),
      },
    });
    const session = await createSession(app, user);
    return reply.status(201).send({ user: await publicUser(user), ...session });
  });

  app.post('/auth/login', {
    schema: {
      tags: ['Authentication'],
      summary: 'Sign in with email and password',
      body: credentialsBodySchema,
    },
  }, async (request, reply) => {
    const body = credentialsSchema.parse(request.body);
    const user = await prisma.user.findUnique({ where: { email: body.email } });
    const validPassword = user && user.isActive && await verifyPassword(body.password, user.passwordHash);
    if (!validPassword || !user) {
      return reply.code(401).send({ error: 'UNAUTHORIZED', message: 'Invalid email or password.' });
    }

    const session = await createSession(app, user);
    return { user: await publicUser(user), ...session };
  });

  app.post('/auth/refresh', {
    schema: {
      tags: ['Authentication'],
      summary: 'Rotate a refresh token',
      body: refreshTokenBodySchema,
    },
  }, async (request, reply) => {
    const body = z.object({ refreshToken: z.string().min(32) }).parse(request.body);
    const session = await rotateSession(app, body.refreshToken);
    if (!session) {
      return reply.code(401).send({ error: 'UNAUTHORIZED', message: 'Your session has expired. Please sign in again.' });
    }
    return { user: await publicUser(session.user), accessToken: session.accessToken, refreshToken: session.refreshToken };
  });

  app.post('/auth/logout', {
    schema: {
      tags: ['Authentication'],
      summary: 'Revoke the current refresh token',
      body: refreshTokenBodySchema,
    },
  }, async (request, reply) => {
    const body = z.object({ refreshToken: z.string().min(32) }).parse(request.body);
    const tokenHash = hashRefreshToken(body.refreshToken);
    const session = await prisma.refreshToken.findUnique({
      where: { tokenHash },
      select: { userId: true },
    });
    const now = new Date();
    await prisma.$transaction(async (transaction) => {
      await transaction.refreshToken.updateMany({
        where: { tokenHash, revokedAt: null },
        data: { revokedAt: now },
      });
      if (session) {
        await transaction.user.update({
          where: { id: session.userId },
          data: { lastLogoutAt: now, lastSeenAt: now },
        });
      }
    });
    return reply.status(204).send();
  });

  app.post('/auth/presence', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Authentication'], summary: 'Keep the signed-in user presence online' },
  }, async () => ({ status: 'online' }));

  app.get('/auth/me', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Authentication'], summary: 'Get the signed-in user' },
  }, async (request, reply) => {
    const user = await prisma.user.findUnique({ where: { id: request.user.sub } });
    if (!user || !user.isActive) {
      return reply.code(401).send({ error: 'UNAUTHORIZED', message: 'Your account is not available.' });
    }
    return { user: await publicUser(user) };
  });
}

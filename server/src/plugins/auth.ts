import type { FastifyReply, FastifyRequest } from 'fastify';
import { UserRole } from '@prisma/client';

import { getEffectivePermissions } from '../lib/permissions.js';
import { prisma } from '../lib/prisma.js';

export async function requireAuthentication(request: FastifyRequest, reply: FastifyReply): Promise<void> {
  try {
    await request.jwtVerify();
  } catch {
    await reply.code(401).send({ error: 'UNAUTHORIZED', message: 'Please sign in to continue.' });
    return;
  }

  const sessionId = request.user.sid;
  const session = sessionId
    ? await prisma.refreshToken.findFirst({
        where: {
          id: sessionId,
          userId: request.user.sub,
          revokedAt: null,
          expiresAt: { gt: new Date() },
        },
        select: { id: true, user: { select: { id: true, role: true, isActive: true } } },
      })
    : null;
  if (!session || !session.user.isActive) {
    await reply.code(401).send({
      error: 'SESSION_REPLACED',
      message: 'This account was signed in on another device. Please sign in again.',
    });
    return;
  }
  request.user.role = session.user.role;
  request.permissions = await getEffectivePermissions(session.user.id, session.user.role);
  const stalePresence = new Date(Date.now() - 60_000);
  await prisma.user.updateMany({
    where: {
      id: session.user.id,
      OR: [{ lastSeenAt: null }, { lastSeenAt: { lt: stalePresence } }],
    },
    data: { lastSeenAt: new Date() },
  });
}

export function requireRoles(...allowedRoles: UserRole[]) {
  return async function authorize(request: FastifyRequest, reply: FastifyReply): Promise<void> {
    await requireAuthentication(request, reply);
    if (reply.sent) {
      return;
    }
    if (!allowedRoles.includes(request.user.role as UserRole)) {
      await reply.code(403).send({ error: 'FORBIDDEN', message: 'Your account does not have permission to perform this action.' });
    }
  };
}

export function requirePermission(permission: string) {
  return async function authorize(request: FastifyRequest, reply: FastifyReply): Promise<void> {
    await requireAuthentication(request, reply);
    if (reply.sent) {
      return;
    }
    if (!request.permissions.includes(permission)) {
      await reply.code(403).send({ error: 'FORBIDDEN', message: 'Your account does not have permission to perform this action.' });
    }
  };
}

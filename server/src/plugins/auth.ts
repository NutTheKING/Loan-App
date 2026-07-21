import type { FastifyReply, FastifyRequest } from 'fastify';
import { UserRole } from '@prisma/client';

export async function requireAuthentication(request: FastifyRequest): Promise<void> {
  await request.jwtVerify();
}

export function requireRoles(...allowedRoles: UserRole[]) {
  return async function authorize(request: FastifyRequest, reply: FastifyReply): Promise<void> {
    await request.jwtVerify();
    if (!allowedRoles.includes(request.user.role as UserRole)) {
      await reply.code(403).send({ error: 'FORBIDDEN', message: 'Your account does not have permission to perform this action.' });
    }
  };
}

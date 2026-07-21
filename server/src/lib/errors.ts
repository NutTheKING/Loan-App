import type { FastifyError, FastifyInstance } from 'fastify';
import { Prisma } from '@prisma/client';
import { ZodError } from 'zod';

export function registerErrorHandler(app: FastifyInstance): void {
  app.setErrorHandler((error: FastifyError, request, reply) => {
    if (error instanceof ZodError) {
      return reply.status(400).send({ error: 'VALIDATION_ERROR', message: 'One or more fields are invalid.', details: error.flatten() });
    }

    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
      return reply.status(409).send({ error: 'CONFLICT', message: 'A record with these details already exists.' });
    }

    if (error.statusCode && error.statusCode < 500) {
      return reply.status(error.statusCode).send({ error: 'REQUEST_ERROR', message: error.message });
    }

    request.log.error(error);
    return reply.status(500).send({ error: 'INTERNAL_ERROR', message: 'An unexpected error occurred.' });
  });
}

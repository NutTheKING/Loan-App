import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { prisma } from '../lib/prisma.js';
import { moneyToNumber, serializeLoan } from '../lib/serializers.js';
import { requireAuthentication } from '../plugins/auth.js';

export async function registerAccountRoutes(app: FastifyInstance): Promise<void> {
  app.get('/dashboard', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Account'], summary: 'Get customer dashboard data' },
  }, async (request) => {
    const [loans, transactions] = await Promise.all([
      prisma.loan.findMany({
        where: { borrowerId: request.user.sub },
        orderBy: { createdAt: 'desc' },
        take: 5,
      }),
      prisma.transaction.findMany({
        where: { userId: request.user.sub },
        orderBy: { occurredAt: 'desc' },
        take: 10,
      }),
    ]);
    return {
      loans: loans.map(serializeLoan),
      transactions: transactions.map((transaction) => ({ ...transaction, amount: moneyToNumber(transaction.amount) })),
    };
  });

  app.get('/notifications', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Account'], summary: 'List customer notifications' },
  }, async (request) => {
    const notifications = await prisma.notification.findMany({
      where: { userId: request.user.sub },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
    return { notifications };
  });

  app.patch('/notifications/:notificationId/read', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Account'], summary: 'Mark a notification as read' },
  }, async (request, reply) => {
    const { notificationId } = z.object({ notificationId: z.string().uuid() }).parse(request.params);
    const notification = await prisma.notification.updateMany({
      where: { id: notificationId, userId: request.user.sub, readAt: null },
      data: { readAt: new Date() },
    });
    if (notification.count === 0) {
      return reply.code(404).send({ error: 'NOT_FOUND', message: 'Notification not found.' });
    }
    return reply.status(204).send();
  });
}

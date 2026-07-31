import type { FastifyInstance } from 'fastify';
import { TransactionStatus, TransactionType } from '@prisma/client';
import { z } from 'zod';

import { availableBalance, serializeTransaction } from '../lib/account-balance.js';
import { sendPushToUsers } from '../lib/firebase.js';
import { findLoanApplicationBlock } from '../lib/loan-eligibility.js';
import { findUserIdsWithPermission, Permissions } from '../lib/permissions.js';
import { prisma } from '../lib/prisma.js';
import { serializeLoan } from '../lib/serializers.js';
import { requireAuthentication } from '../plugins/auth.js';

const transactionParams = z.object({ transactionId: z.string().uuid() });

export async function registerAccountRoutes(app: FastifyInstance): Promise<void> {
  app.get('/dashboard', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Account'], summary: 'Get customer dashboard data' },
  }, async (request) => {
    const [loans, transactions, balance, loanApplicationBlock] = await Promise.all([
      prisma.loan.findMany({
        where: { borrowerId: request.user.sub, submittedAt: { not: null } },
        orderBy: { createdAt: 'desc' },
        take: 5,
      }),
      prisma.transaction.findMany({
        where: { userId: request.user.sub },
        orderBy: { occurredAt: 'desc' },
        take: 10,
      }),
      availableBalance(request.user.sub),
      findLoanApplicationBlock(request.user.sub),
    ]);
    return {
      loans: loans.map(serializeLoan),
      transactions: transactions.map(serializeTransaction),
      hasPendingLoan: loanApplicationBlock?.reason === 'PENDING_REVIEW',
      hasActiveLoan: loanApplicationBlock !== null,
      canApplyForLoan: loanApplicationBlock === null,
      loanApplicationBlock,
      availableBalance: balance,
    };
  });

  app.post('/transactions', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Account'], summary: 'Request a customer deposit or withdrawal' },
  }, async (request, reply) => {
    const body = z.object({
      type: z.enum([TransactionType.DEPOSIT, TransactionType.WITHDRAWAL]),
      amount: z.coerce.number().positive().max(999999999),
      description: z.string().trim().min(2).max(200),
    }).parse(request.body);
    if (body.type === TransactionType.WITHDRAWAL) {
      const balance = await availableBalance(request.user.sub);
      if (body.amount > balance) {
        return reply.code(409).send({
          error: 'INSUFFICIENT_BALANCE',
          message: 'The withdrawal amount is higher than the available balance.',
        });
      }
    }
    const transaction = await prisma.$transaction(async (database) => {
      const created = await database.transaction.create({
        data: {
          userId: request.user.sub,
          type: body.type,
          status: TransactionStatus.PENDING,
          amount: body.amount,
          description: body.description,
        },
      });
      await database.auditLog.create({
        data: {
          actorId: request.user.sub,
          action: `TRANSACTION_${body.type}_REQUESTED`,
          entityType: 'Transaction',
          entityId: created.id,
        },
      });
      await database.notification.create({
        data: {
          userId: request.user.sub,
          title: `${body.type === TransactionType.DEPOSIT ? 'Deposit' : 'Withdrawal'} request received`,
          body: 'Your request is pending back-office review.',
          payload: '/transactions',
        },
      });
      return created;
    });
    const reviewerIds = (await findUserIdsWithPermission(
      Permissions.transactionsManage,
    )).filter((userId) => userId !== request.user.sub);
    void sendPushToUsers(reviewerIds, {
      title: `New ${body.type === TransactionType.DEPOSIT ? 'deposit' : 'withdrawal'} request`,
      body: `${body.description} is waiting for review.`,
      payload: '/admin',
    }).catch((error) =>
      app.log.warn({ err: error }, 'Unable to send transaction review push notification'),
    );
    return reply.status(202).send({
      transaction: serializeTransaction(transaction),
      availableBalance: await availableBalance(request.user.sub),
      message: 'Your request is pending back-office review.',
    });
  });

  app.get('/transactions/:transactionId', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Account'], summary: 'Get a customer transaction status' },
  }, async (request, reply) => {
    const { transactionId } = transactionParams.parse(request.params);
    const transaction = await prisma.transaction.findFirst({
      where: { id: transactionId, userId: request.user.sub },
      include: {
        loan: { select: { loanNumber: true } },
        reviewedBy: { select: { fullName: true } },
      },
    });
    if (!transaction) {
      return reply.code(404).send({
        error: 'NOT_FOUND',
        message: 'Transaction not found.',
      });
    }
    return { transaction: serializeTransaction(transaction) };
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
    return { notifications, unreadCount: notifications.filter((notification) => notification.readAt === null).length };
  });

  app.post('/devices', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Account'], summary: 'Register a Firebase notification device token' },
  }, async (request, reply) => {
    const body = z.object({
      token: z.string().trim().min(20).max(4096),
      platform: z.enum(['android', 'ios', 'web']),
    }).parse(request.body);
    const device = await prisma.deviceToken.upsert({
      where: { token: body.token },
      create: { userId: request.user.sub, token: body.token, platform: body.platform },
      update: { userId: request.user.sub, platform: body.platform, lastSeenAt: new Date() },
    });
    return reply.status(201).send({ device: { id: device.id, platform: device.platform } });
  });

  app.post('/devices/unregister', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Account'], summary: 'Unregister a Firebase notification device token' },
  }, async (request, reply) => {
    const body = z.object({ token: z.string().trim().min(20).max(4096) }).parse(request.body);
    await prisma.deviceToken.deleteMany({ where: { token: body.token, userId: request.user.sub } });
    return reply.status(204).send();
  });

  app.patch('/notifications/read-all', {
    onRequest: [requireAuthentication],
    schema: { tags: ['Account'], summary: 'Mark every notification as read' },
  }, async (request, reply) => {
    await prisma.notification.updateMany({
      where: { userId: request.user.sub, readAt: null },
      data: { readAt: new Date() },
    });
    return reply.status(204).send();
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

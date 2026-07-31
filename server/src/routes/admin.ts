import type { FastifyInstance } from 'fastify';
import {
  LoanStatus,
  PaymentStatus,
  Prisma,
  TransactionStatus,
  TransactionType,
  UserRole,
} from '@prisma/client';
import { z } from 'zod';

import {
  availableBalance,
  completedBalance,
  serializeTransaction,
} from '../lib/account-balance.js';
import { sendPushToUsers } from '../lib/firebase.js';
import { serializeLoanProduct } from '../lib/loan-products.js';
import { hashPassword } from '../lib/password.js';
import {
  findUserIdsWithPermission,
  getEffectivePermissions,
  Permissions,
} from '../lib/permissions.js';
import { moneyToNumber, serializeLoan } from '../lib/serializers.js';
import { prisma } from '../lib/prisma.js';
import { requirePermission } from '../plugins/auth.js';

const uuidParams = z.object({ id: z.string().uuid() });
const reviewableTransactionTypes: TransactionType[] = [
  TransactionType.DEPOSIT,
  TransactionType.WITHDRAWAL,
];
const deletableTransactionStatuses: TransactionStatus[] = [
  TransactionStatus.PENDING,
  TransactionStatus.REJECTED,
];

const loanProductSchema = z
  .object({
    code: z.string().trim().min(2).max(32).regex(/^[A-Z0-9_-]+$/),
    name: z.string().trim().min(2).max(120),
    description: z.string().trim().min(2).max(500),
    currency: z.string().trim().length(3).transform((value) => value.toUpperCase()),
    minimumAmount: z.coerce.number().positive().max(999999999),
    maximumAmount: z.coerce.number().positive().max(999999999),
    monthlyInterestRate: z.coerce.number().positive().max(1),
    allowedTerms: z.array(z.coerce.number().int().min(1).max(360)).min(1).max(12),
    repaymentFrequency: z.enum(['WEEKLY', 'BIWEEKLY', 'MONTHLY']),
    isActive: z.boolean(),
    isDefault: z.boolean(),
  })
  .refine((value) => value.maximumAmount >= value.minimumAmount, {
    message: 'Maximum amount must be greater than or equal to minimum amount.',
    path: ['maximumAmount'],
  });

const branchSchema = z.object({
  code: z.string().trim().min(2).max(32).regex(/^[A-Z0-9_-]+$/),
  name: z.string().trim().min(2).max(120),
  address: z.string().trim().min(5).max(500),
  phone: z.string().trim().min(7).max(30),
  email: z.string().trim().email().max(254).optional().nullable(),
  managerName: z.string().trim().min(2).max(120).optional().nullable(),
  isActive: z.boolean(),
});

const adminUserSchema = z.object({
  email: z.string().trim().email().max(254).transform((value) => value.toLowerCase()),
  fullName: z.string().trim().min(2).max(120),
  idNumber: z.string().trim().min(4).max(64).optional().nullable(),
  role: z.nativeEnum(UserRole),
  isActive: z.boolean().default(true),
  password: z.string().min(12).max(128).optional(),
  permissionKeys: z.array(z.string().trim().min(1).max(80)).max(100).optional(),
});

const backOfficeUserSchema = adminUserSchema.extend({
  role: z.enum([UserRole.STAFF, UserRole.ADMIN]),
});

const customerSchema = z.object({
  email: z.string().trim().email().max(254).transform((value) => value.toLowerCase()),
  fullName: z.string().trim().min(2).max(120),
  idNumber: z.string().trim().min(4).max(64).optional().nullable(),
  phone: z.string().trim().min(7).max(30).optional().nullable(),
  dateOfBirth: z.coerce.date().optional().nullable(),
  gender: z.string().trim().min(1).max(40).optional().nullable(),
  address: z.string().trim().min(5).max(500).optional().nullable(),
  profilePhotoUrl: z.string().trim().url().max(2048).optional().nullable(),
  isActive: z.boolean().default(true),
  password: z.string().min(12).max(128).optional(),
});

const transactionRequestSchema = z.object({
  userId: z.string().uuid(),
  amount: z.coerce.number().positive().max(999999999),
  description: z.string().trim().min(2).max(200),
});

const transactionReviewSchema = z
  .object({
    status: z.enum([
      TransactionStatus.COMPLETED,
      TransactionStatus.REJECTED,
    ]),
    reason: z.string().trim().min(5, 'Provide a clear rejection reason.').max(1000).optional(),
  })
  .superRefine((value, context) => {
    if (
      value.status === TransactionStatus.REJECTED
      && !value.reason?.trim()
    ) {
      context.addIssue({
        code: 'custom',
        path: ['reason'],
        message: 'A rejection reason is required.',
      });
    }
  });

function accountPresence(user: {
  isActive: boolean;
  lastLoginAt: Date | null;
  lastSeenAt: Date | null;
  lastLogoutAt: Date | null;
  refreshTokens: { id: string }[];
}) {
  const onlineThreshold = Date.now() - 2 * 60 * 1000;
  const isOnline =
    user.isActive
    && user.refreshTokens.length > 0
    && user.lastSeenAt !== null
    && user.lastSeenAt.getTime() >= onlineThreshold
    && (user.lastLogoutAt === null || user.lastSeenAt > user.lastLogoutAt);
  return {
    isOnline,
    presenceStatus: isOnline ? 'ONLINE' : 'OFFLINE',
    lastLoginAt: user.lastLoginAt,
    lastSeenAt: user.lastSeenAt,
    lastLogoutAt: user.lastLogoutAt,
  };
}

async function replacePermissionOverrides(
  transaction: Prisma.TransactionClient,
  userId: string,
  role: UserRole,
  permissionKeys: string[],
): Promise<void> {
  if (role === UserRole.ADMIN) {
    await transaction.userPermission.deleteMany({ where: { userId } });
    return;
  }

  const [permissions, roleAssignments] = await Promise.all([
    transaction.permission.findMany({ select: { id: true, key: true } }),
    transaction.rolePermission.findMany({
      where: { role },
      select: { permission: { select: { key: true } } },
    }),
  ]);
  const knownKeys = new Set(permissions.map((permission) => permission.key));
  const invalidKey = permissionKeys.find((key) => !knownKeys.has(key));
  if (invalidKey) {
    throw new z.ZodError([{ code: 'custom', path: ['permissionKeys'], message: `Unknown permission: ${invalidKey}` }]);
  }
  const selected = new Set(permissionKeys);
  const roleDefaults = new Set(roleAssignments.map((assignment) => assignment.permission.key));
  const overrides = permissions
    .filter((permission) => selected.has(permission.key) !== roleDefaults.has(permission.key))
    .map((permission) => ({
      userId,
      permissionId: permission.id,
      granted: selected.has(permission.key),
    }));
  await transaction.userPermission.deleteMany({ where: { userId } });
  if (overrides.length > 0) {
    await transaction.userPermission.createMany({ data: overrides });
  }
}

export async function registerAdminRoutes(app: FastifyInstance): Promise<void> {
  app.get('/admin/overview', {
    onRequest: [requirePermission(Permissions.dashboardView)],
    schema: { tags: ['Admin'], summary: 'Get the management dashboard overview' },
  }, async () => {
    const [
      customers,
      applications,
      pending,
      approved,
      rejected,
      approvedAmount,
      repayments,
      pendingDeposits,
      pendingWithdrawals,
      recentTransactions,
    ] =
      await Promise.all([
        prisma.user.count({ where: { role: UserRole.CUSTOMER, isActive: true } }),
        prisma.loan.count({ where: { submittedAt: { not: null } } }),
        prisma.loan.count({ where: { status: LoanStatus.PENDING, submittedAt: { not: null } } }),
        prisma.loan.count({ where: { status: LoanStatus.APPROVED, submittedAt: { not: null } } }),
        prisma.loan.count({ where: { status: LoanStatus.REJECTED, submittedAt: { not: null } } }),
        prisma.loan.aggregate({
          where: { status: LoanStatus.APPROVED, submittedAt: { not: null } },
          _sum: { principal: true },
        }),
        prisma.repayment.groupBy({ by: ['status'], _count: { _all: true }, _sum: { amountDue: true, amountPaid: true } }),
        prisma.transaction.count({
          where: { type: TransactionType.DEPOSIT, status: TransactionStatus.PENDING },
        }),
        prisma.transaction.count({
          where: { type: TransactionType.WITHDRAWAL, status: TransactionStatus.PENDING },
        }),
        prisma.transaction.findMany({
          include: { user: { select: { fullName: true, email: true } }, loan: { select: { loanNumber: true } } },
          orderBy: { occurredAt: 'desc' },
          take: 8,
        }),
      ]);

    return {
      customers,
      applications,
      pending,
      approved,
      rejected,
      approvedPrincipal: moneyToNumber(approvedAmount._sum.principal ?? 0),
      pendingDeposits,
      pendingWithdrawals,
      repayments: repayments.map((item) => ({
        status: item.status,
        count: item._count._all,
        amountDue: moneyToNumber(item._sum.amountDue ?? 0),
        amountPaid: moneyToNumber(item._sum.amountPaid ?? 0),
      })),
      recentTransactions: recentTransactions.map((transaction) => ({
        ...transaction,
        amount: moneyToNumber(transaction.amount),
      })),
    };
  });

  app.get('/admin/customers', {
    onRequest: [requirePermission(Permissions.customersRead)],
    schema: { tags: ['Admin'], summary: 'List customer accounts' },
  }, async () => {
    const now = new Date();
    const customers = await prisma.user.findMany({
      where: { role: UserRole.CUSTOMER },
      select: {
        id: true,
        email: true,
        fullName: true,
        idNumber: true,
        phone: true,
        dateOfBirth: true,
        gender: true,
        address: true,
        profilePhotoUrl: true,
        isActive: true,
        lastLoginAt: true,
        lastSeenAt: true,
        lastLogoutAt: true,
        createdAt: true,
        refreshTokens: {
          where: { revokedAt: null, expiresAt: { gt: now } },
          select: { id: true },
        },
        _count: {
          select: {
            loans: { where: { submittedAt: { not: null } } },
            transactions: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
    return {
      customers: customers.map(({ refreshTokens, ...customer }) => ({
        ...customer,
        ...accountPresence({ ...customer, refreshTokens }),
      })),
    };
  });

  app.get('/admin/customers/:id', {
    onRequest: [requirePermission(Permissions.customersRead)],
    schema: { tags: ['Admin customers'], summary: 'View a customer account and activity' },
  }, async (request, reply) => {
    const { id } = uuidParams.parse(request.params);
    const now = new Date();
    const customer = await prisma.user.findFirst({
      where: { id, role: UserRole.CUSTOMER },
      select: {
        id: true,
        email: true,
        fullName: true,
        idNumber: true,
        phone: true,
        dateOfBirth: true,
        gender: true,
        address: true,
        profilePhotoUrl: true,
        isActive: true,
        lastLoginAt: true,
        lastSeenAt: true,
        lastLogoutAt: true,
        createdAt: true,
        refreshTokens: {
          where: { revokedAt: null, expiresAt: { gt: now } },
          select: { id: true },
        },
        loans: {
          where: { submittedAt: { not: null } },
          include: {
            documents: true,
            repayments: { orderBy: { installment: 'asc' } },
          },
          orderBy: { createdAt: 'desc' },
          take: 20,
        },
        transactions: {
          include: {
            loan: { select: { loanNumber: true } },
            reviewedBy: { select: { fullName: true } },
          },
          orderBy: { occurredAt: 'desc' },
          take: 50,
        },
      },
    });
    if (!customer) {
      return reply.code(404).send({
        error: 'NOT_FOUND',
        message: 'Customer not found.',
      });
    }
    const { refreshTokens, loans, transactions, ...profile } = customer;
    return {
      customer: {
        ...profile,
        ...accountPresence({ ...profile, refreshTokens }),
        loans: loans.map((loan) => serializeLoan(loan)),
        transactions: transactions.map(serializeTransaction),
      },
    };
  });

  app.post('/admin/customers', {
    onRequest: [requirePermission(Permissions.customersManage)],
    schema: { tags: ['Admin customers'], summary: 'Register a customer account' },
  }, async (request, reply) => {
    const body = customerSchema.extend({ password: z.string().min(12).max(128) }).parse(request.body);
    const customer = await prisma.user.create({
      data: {
        email: body.email,
        fullName: body.fullName,
        idNumber: body.idNumber,
        phone: body.phone,
        dateOfBirth: body.dateOfBirth,
        gender: body.gender,
        address: body.address,
        profilePhotoUrl: body.profilePhotoUrl,
        isActive: body.isActive,
        role: UserRole.CUSTOMER,
        passwordHash: await hashPassword(body.password),
      },
    });
    await prisma.auditLog.create({
      data: {
        actorId: request.user.sub,
        action: 'CUSTOMER_CREATED',
        entityType: 'User',
        entityId: customer.id,
      },
    });
    const { passwordHash: _passwordHash, ...publicCustomer } = customer;
    return reply.status(201).send({
      customer: {
        ...publicCustomer,
        isOnline: false,
        presenceStatus: 'OFFLINE',
      },
    });
  });

  app.patch('/admin/customers/:id', {
    onRequest: [requirePermission(Permissions.customersManage)],
    schema: { tags: ['Admin customers'], summary: 'Update a customer account' },
  }, async (request, reply) => {
    const { id } = uuidParams.parse(request.params);
    const existing = await prisma.user.findFirst({
      where: { id, role: UserRole.CUSTOMER },
    });
    if (!existing) {
      return reply.code(404).send({ error: 'NOT_FOUND', message: 'Customer not found.' });
    }
    const body = customerSchema.parse({
      email: existing.email,
      fullName: existing.fullName,
      idNumber: existing.idNumber,
      phone: existing.phone,
      dateOfBirth: existing.dateOfBirth,
      gender: existing.gender,
      address: existing.address,
      profilePhotoUrl: existing.profilePhotoUrl,
      isActive: existing.isActive,
      ...(request.body as Record<string, unknown>),
    });
    const customer = await prisma.user.update({
      where: { id },
      data: {
        email: body.email,
        fullName: body.fullName,
        idNumber: body.idNumber,
        phone: body.phone,
        dateOfBirth: body.dateOfBirth,
        gender: body.gender,
        address: body.address,
        profilePhotoUrl: body.profilePhotoUrl,
        isActive: body.isActive,
        ...(body.password ? { passwordHash: await hashPassword(body.password) } : {}),
      },
    });
    await prisma.auditLog.create({
      data: {
        actorId: request.user.sub,
        action: 'CUSTOMER_UPDATED',
        entityType: 'User',
        entityId: customer.id,
        metadata: { isActive: customer.isActive },
      },
    });
    const { passwordHash: _passwordHash, ...publicCustomer } = customer;
    return { customer: publicCustomer };
  });

  app.delete('/admin/customers/:id', {
    onRequest: [requirePermission(Permissions.customersManage)],
    schema: { tags: ['Admin customers'], summary: 'Delete an unused customer account' },
  }, async (request, reply) => {
    const { id } = uuidParams.parse(request.params);
    const customer = await prisma.user.findFirst({
      where: { id, role: UserRole.CUSTOMER },
      select: {
        id: true,
        _count: { select: { loans: true, transactions: true } },
      },
    });
    if (!customer) {
      return reply.code(404).send({
        error: 'NOT_FOUND',
        message: 'Customer not found.',
      });
    }
    if (customer._count.loans > 0 || customer._count.transactions > 0) {
      return reply.code(409).send({
        error: 'ACCOUNT_HAS_HISTORY',
        message: 'Customers with financial history cannot be deleted. Disable the account instead.',
      });
    }
    await prisma.$transaction(async (transaction) => {
      await transaction.auditLog.create({
        data: {
          actorId: request.user.sub,
          action: 'CUSTOMER_DELETED',
          entityType: 'User',
          entityId: id,
        },
      });
      await transaction.user.delete({ where: { id } });
    });
    return reply.status(204).send();
  });

  app.get('/admin/repayments', {
    onRequest: [requirePermission(Permissions.repaymentsRead)],
    schema: { tags: ['Admin'], summary: 'List repayment installments' },
  }, async (request) => {
    const query = z.object({ status: z.nativeEnum(PaymentStatus).optional() }).parse(request.query);
    const repayments = await prisma.repayment.findMany({
      where: query.status ? { status: query.status } : undefined,
      include: {
        loan: {
          select: {
            loanNumber: true,
            borrower: { select: { id: true, fullName: true, email: true } },
          },
        },
      },
      orderBy: { dueDate: 'asc' },
    });
    return {
      repayments: repayments.map((repayment) => ({
        ...repayment,
        principal: moneyToNumber(repayment.principal),
        interest: moneyToNumber(repayment.interest),
        amountDue: moneyToNumber(repayment.amountDue),
        amountPaid: moneyToNumber(repayment.amountPaid),
      })),
    };
  });

  app.get('/admin/transactions', {
    onRequest: [requirePermission(Permissions.transactionsRead)],
    schema: { tags: ['Admin'], summary: 'List account transactions' },
  }, async (request) => {
    const query = z.object({
      type: z.nativeEnum(TransactionType).optional(),
      status: z.nativeEnum(TransactionStatus).optional(),
    }).parse(request.query);
    const transactions = await prisma.transaction.findMany({
      where: {
        ...(query.type ? { type: query.type } : {}),
        ...(query.status ? { status: query.status } : {}),
      },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            profilePhotoUrl: true,
          },
        },
        loan: { select: { loanNumber: true } },
        reviewedBy: { select: { id: true, fullName: true } },
      },
      orderBy: { occurredAt: 'desc' },
      take: 250,
    });
    return { transactions: transactions.map(serializeTransaction) };
  });

  app.get('/admin/transactions/:id', {
    onRequest: [requirePermission(Permissions.transactionsRead)],
    schema: { tags: ['Admin transactions'], summary: 'View transaction details' },
  }, async (request, reply) => {
    const { id } = uuidParams.parse(request.params);
    const transaction = await prisma.transaction.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            idNumber: true,
            profilePhotoUrl: true,
          },
        },
        loan: { select: { loanNumber: true } },
        reviewedBy: { select: { id: true, fullName: true, email: true } },
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

  app.post('/admin/transactions', {
    onRequest: [requirePermission(Permissions.transactionsManage)],
    schema: { tags: ['Admin transactions'], summary: 'Post a completed customer deposit' },
  }, async (request, reply) => {
    const body = transactionRequestSchema.parse(request.body);
    const customer = await prisma.user.findFirst({
      where: { id: body.userId, role: UserRole.CUSTOMER, isActive: true },
      select: { id: true, fullName: true },
    });
    if (!customer) {
      return reply.code(404).send({
        error: 'NOT_FOUND',
        message: 'Active customer not found.',
      });
    }
    const transaction = await prisma.$transaction(async (database) => {
      const created = await database.transaction.create({
        data: {
          userId: customer.id,
          type: TransactionType.DEPOSIT,
          status: TransactionStatus.COMPLETED,
          amount: body.amount,
          description: body.description,
          reviewedAt: new Date(),
          reviewedById: request.user.sub,
        },
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
              profilePhotoUrl: true,
            },
          },
          reviewedBy: { select: { id: true, fullName: true } },
        },
      });
      await database.auditLog.create({
        data: {
          actorId: request.user.sub,
          action: 'DEPOSIT_POSTED',
          entityType: 'Transaction',
          entityId: created.id,
          metadata: { amount: body.amount, customerId: customer.id },
        },
      });
      await database.notification.create({
        data: {
          userId: customer.id,
          title: 'Deposit completed',
          body: `${body.description} was added to your available balance.`,
          payload: '/transactions',
        },
      });
      return created;
    });
    void sendPushToUsers([customer.id], {
      title: 'Deposit completed',
      body: `${body.description} was added to your available balance.`,
      payload: '/transactions',
    }).catch((error) =>
      app.log.warn({ err: error }, 'Unable to send deposit push notification'),
    );
    return reply.status(201).send({
      transaction: serializeTransaction(transaction),
      availableBalance: await availableBalance(customer.id),
    });
  });

  app.patch('/admin/transactions/:id/status', {
    onRequest: [requirePermission(Permissions.transactionsManage)],
    schema: { tags: ['Admin transactions'], summary: 'Approve or reject a pending cash request' },
  }, async (request, reply) => {
    const { id } = uuidParams.parse(request.params);
    const body = transactionReviewSchema.parse(request.body);
    const existing = await prisma.transaction.findUnique({ where: { id } });
    if (!existing) {
      return reply.code(404).send({
        error: 'NOT_FOUND',
        message: 'Transaction not found.',
      });
    }
    if (
      existing.status !== TransactionStatus.PENDING
      || !reviewableTransactionTypes.includes(existing.type)
    ) {
      return reply.code(409).send({
        error: 'CONFLICT',
        message: 'Only pending deposit or withdrawal requests can be reviewed.',
      });
    }

    const reviewed = await prisma.$transaction(async (database) => {
      if (
        body.status === TransactionStatus.COMPLETED
        && existing.type === TransactionType.WITHDRAWAL
      ) {
        const balance = await completedBalance(existing.userId, database);
        if (moneyToNumber(existing.amount) > balance) {
          return { insufficientBalance: true as const, transaction: null };
        }
      }
      const update = await database.transaction.updateMany({
        where: { id, status: TransactionStatus.PENDING },
        data: {
          status: body.status,
          reviewReason: body.reason?.trim() || null,
          reviewedAt: new Date(),
          reviewedById: request.user.sub,
        },
      });
      if (update.count !== 1) {
        return { insufficientBalance: false as const, transaction: null };
      }
      const transaction = await database.transaction.findUniqueOrThrow({
        where: { id },
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
              profilePhotoUrl: true,
            },
          },
          loan: { select: { loanNumber: true } },
          reviewedBy: { select: { id: true, fullName: true } },
        },
      });
      const action = body.status === TransactionStatus.COMPLETED
        ? 'approved'
        : 'rejected';
      const typeLabel = existing.type === TransactionType.DEPOSIT
        ? 'deposit'
        : 'withdrawal';
      await database.notification.create({
        data: {
          userId: existing.userId,
          title: `${typeLabel[0].toUpperCase()}${typeLabel.slice(1)} ${action}`,
          body: body.status === TransactionStatus.COMPLETED
            ? `Your ${typeLabel} request was completed.`
            : `Your ${typeLabel} request was rejected: ${body.reason}`,
          payload: '/transactions',
        },
      });
      await database.auditLog.create({
        data: {
          actorId: request.user.sub,
          action: `TRANSACTION_${body.status}`,
          entityType: 'Transaction',
          entityId: id,
          metadata: { reason: body.reason, type: existing.type },
        },
      });
      return { insufficientBalance: false as const, transaction };
    });

    if (reviewed.insufficientBalance) {
      return reply.code(409).send({
        error: 'INSUFFICIENT_BALANCE',
        message: 'The customer no longer has enough completed balance for this withdrawal.',
      });
    }
    if (!reviewed.transaction) {
      return reply.code(409).send({
        error: 'CONFLICT',
        message: 'This transaction was already reviewed.',
      });
    }
    const approved = body.status === TransactionStatus.COMPLETED;
    const typeLabel = existing.type === TransactionType.DEPOSIT
      ? 'deposit'
      : 'withdrawal';
    void sendPushToUsers([existing.userId], {
      title: `${typeLabel[0].toUpperCase()}${typeLabel.slice(1)} ${approved ? 'approved' : 'rejected'}`,
      body: approved
        ? `Your ${typeLabel} request was completed.`
        : `Your ${typeLabel} request was rejected: ${body.reason}`,
      payload: '/transactions',
    }).catch((error) =>
      app.log.warn({ err: error }, 'Unable to send transaction status push notification'),
    );
    return {
      transaction: serializeTransaction(reviewed.transaction),
      availableBalance: await availableBalance(existing.userId),
    };
  });

  app.delete('/admin/transactions/:id', {
    onRequest: [requirePermission(Permissions.transactionsManage)],
    schema: { tags: ['Admin transactions'], summary: 'Delete a pending or rejected cash request' },
  }, async (request, reply) => {
    const { id } = uuidParams.parse(request.params);
    const transaction = await prisma.transaction.findUnique({ where: { id } });
    if (!transaction) {
      return reply.code(404).send({
        error: 'NOT_FOUND',
        message: 'Transaction not found.',
      });
    }
    if (
      !deletableTransactionStatuses.includes(transaction.status)
      || !reviewableTransactionTypes.includes(transaction.type)
    ) {
      return reply.code(409).send({
        error: 'IMMUTABLE_TRANSACTION',
        message: 'Completed financial records cannot be deleted.',
      });
    }
    await prisma.$transaction(async (database) => {
      await database.auditLog.create({
        data: {
          actorId: request.user.sub,
          action: 'TRANSACTION_DELETED',
          entityType: 'Transaction',
          entityId: id,
          metadata: { type: transaction.type, status: transaction.status },
        },
      });
      await database.transaction.delete({ where: { id } });
    });
    return reply.status(204).send();
  });

  app.get('/admin/reports/summary', {
    onRequest: [requirePermission(Permissions.reportsRead)],
    schema: { tags: ['Admin'], summary: 'Get portfolio and repayment report totals' },
  }, async () => {
    const [loanStatuses, repaymentStatuses, disbursements, repayments] = await Promise.all([
      prisma.loan.groupBy({
        by: ['status'],
        where: { submittedAt: { not: null } },
        _count: { _all: true },
        _sum: { principal: true, totalRepayment: true },
      }),
      prisma.repayment.groupBy({ by: ['status'], _count: { _all: true }, _sum: { amountDue: true, amountPaid: true } }),
      prisma.transaction.aggregate({ where: { type: TransactionType.LOAN_DISBURSEMENT }, _sum: { amount: true } }),
      prisma.transaction.aggregate({ where: { type: TransactionType.REPAYMENT }, _sum: { amount: true } }),
    ]);
    return {
      loanStatuses: loanStatuses.map((item) => ({
        status: item.status,
        count: item._count._all,
        principal: moneyToNumber(item._sum.principal ?? 0),
        totalRepayment: moneyToNumber(item._sum.totalRepayment ?? 0),
      })),
      repaymentStatuses: repaymentStatuses.map((item) => ({
        status: item.status,
        count: item._count._all,
        amountDue: moneyToNumber(item._sum.amountDue ?? 0),
        amountPaid: moneyToNumber(item._sum.amountPaid ?? 0),
      })),
      totalDisbursed: moneyToNumber(disbursements._sum.amount ?? 0),
      totalCollected: moneyToNumber(repayments._sum.amount ?? 0),
    };
  });

  app.get('/admin/loan-products', {
    onRequest: [requirePermission(Permissions.productsRead)],
    schema: { tags: ['Admin loan products'], summary: 'List every loan package' },
  }, async () => {
    const products = await prisma.loanProduct.findMany({ orderBy: [{ isDefault: 'desc' }, { createdAt: 'asc' }] });
    return { products: products.map(serializeLoanProduct) };
  });

  app.post('/admin/loan-products', {
    onRequest: [requirePermission(Permissions.productsManage)],
    schema: { tags: ['Admin loan products'], summary: 'Create a loan package' },
  }, async (request, reply) => {
    const body = loanProductSchema.parse(request.body);
    const product = await prisma.$transaction(async (transaction) => {
      if (body.isDefault) {
        await transaction.loanProduct.updateMany({ where: { isDefault: true }, data: { isDefault: false } });
      }
      return transaction.loanProduct.create({ data: body });
    });
    await prisma.auditLog.create({
      data: { actorId: request.user.sub, action: 'LOAN_PRODUCT_CREATED', entityType: 'LoanProduct', entityId: product.id },
    });
    return reply.status(201).send({ product: serializeLoanProduct(product) });
  });

  app.patch('/admin/loan-products/:id', {
    onRequest: [requirePermission(Permissions.productsManage)],
    schema: { tags: ['Admin loan products'], summary: 'Update a loan package' },
  }, async (request, reply) => {
    const { id } = uuidParams.parse(request.params);
    const existing = await prisma.loanProduct.findUnique({ where: { id } });
    if (!existing) {
      return reply.code(404).send({ error: 'NOT_FOUND', message: 'Loan package not found.' });
    }
    const body = loanProductSchema.parse({
      ...serializeLoanProduct(existing),
      ...(request.body as Record<string, unknown>),
    });
    const product = await prisma.$transaction(async (transaction) => {
      if (body.isDefault) {
        await transaction.loanProduct.updateMany({ where: { isDefault: true, id: { not: id } }, data: { isDefault: false } });
      }
      return transaction.loanProduct.update({ where: { id }, data: body });
    });
    await prisma.auditLog.create({
      data: { actorId: request.user.sub, action: 'LOAN_PRODUCT_UPDATED', entityType: 'LoanProduct', entityId: product.id },
    });
    return { product: serializeLoanProduct(product) };
  });

  app.delete('/admin/loan-products/:id', {
    onRequest: [requirePermission(Permissions.productsManage)],
    schema: { tags: ['Admin loan products'], summary: 'Delete an unused loan package' },
  }, async (request, reply) => {
    const { id } = uuidParams.parse(request.params);
    const product = await prisma.loanProduct.findUnique({
      where: { id },
      include: { _count: { select: { loans: true } } },
    });
    if (!product) {
      return reply.code(404).send({
        error: 'NOT_FOUND',
        message: 'Loan package not found.',
      });
    }
    if (product._count.loans > 0) {
      return reply.code(409).send({
        error: 'PACKAGE_HAS_HISTORY',
        message: 'Packages used by loan applications cannot be deleted. Disable the package instead.',
      });
    }
    await prisma.$transaction(async (transaction) => {
      await transaction.loanProduct.delete({ where: { id } });
      if (product.isDefault) {
        const replacement = await transaction.loanProduct.findFirst({
          where: { isActive: true },
          orderBy: { createdAt: 'asc' },
        });
        if (replacement) {
          await transaction.loanProduct.update({
            where: { id: replacement.id },
            data: { isDefault: true },
          });
        }
      }
      await transaction.auditLog.create({
        data: {
          actorId: request.user.sub,
          action: 'LOAN_PRODUCT_DELETED',
          entityType: 'LoanProduct',
          entityId: id,
        },
      });
    });
    return reply.status(204).send();
  });

  app.get('/admin/branches', {
    onRequest: [requirePermission(Permissions.branchesRead)],
    schema: { tags: ['Admin branches'], summary: 'List operating branches' },
  }, async () => ({ branches: await prisma.branch.findMany({ orderBy: { name: 'asc' } }) }));

  app.post('/admin/branches', {
    onRequest: [requirePermission(Permissions.branchesManage)],
    schema: { tags: ['Admin branches'], summary: 'Create an operating branch' },
  }, async (request, reply) => {
    const branch = await prisma.branch.create({ data: branchSchema.parse(request.body) });
    await prisma.auditLog.create({
      data: { actorId: request.user.sub, action: 'BRANCH_CREATED', entityType: 'Branch', entityId: branch.id },
    });
    return reply.status(201).send({ branch });
  });

  app.patch('/admin/branches/:id', {
    onRequest: [requirePermission(Permissions.branchesManage)],
    schema: { tags: ['Admin branches'], summary: 'Update an operating branch' },
  }, async (request, reply) => {
    const { id } = uuidParams.parse(request.params);
    const existing = await prisma.branch.findUnique({ where: { id } });
    if (!existing) {
      return reply.code(404).send({ error: 'NOT_FOUND', message: 'Branch not found.' });
    }
    const branch = await prisma.branch.update({
      where: { id },
      data: branchSchema.parse({ ...existing, ...(request.body as Record<string, unknown>) }),
    });
    await prisma.auditLog.create({
      data: { actorId: request.user.sub, action: 'BRANCH_UPDATED', entityType: 'Branch', entityId: branch.id },
    });
    return { branch };
  });

  app.delete('/admin/branches/:id', {
    onRequest: [requirePermission(Permissions.branchesManage)],
    schema: { tags: ['Admin branches'], summary: 'Delete an operating branch' },
  }, async (request, reply) => {
    const { id } = uuidParams.parse(request.params);
    const branch = await prisma.branch.findUnique({ where: { id } });
    if (!branch) {
      return reply.code(404).send({
        error: 'NOT_FOUND',
        message: 'Branch not found.',
      });
    }
    await prisma.$transaction(async (transaction) => {
      await transaction.branch.delete({ where: { id } });
      await transaction.auditLog.create({
        data: {
          actorId: request.user.sub,
          action: 'BRANCH_DELETED',
          entityType: 'Branch',
          entityId: id,
        },
      });
    });
    return reply.status(204).send();
  });

  app.get('/admin/permissions', {
    onRequest: [requirePermission(Permissions.usersManage)],
    schema: { tags: ['Admin users'], summary: 'List database-backed permissions' },
  }, async () => {
    const permissions = await prisma.permission.findMany({
      include: { roleAssignments: { select: { role: true } } },
      orderBy: [{ category: 'asc' }, { sortOrder: 'asc' }],
    });
    return {
      permissions: permissions.map(({ roleAssignments, ...permission }) => ({
        ...permission,
        defaultRoles: roleAssignments.map((assignment) => assignment.role),
      })),
    };
  });

  app.get('/admin/users', {
    onRequest: [requirePermission(Permissions.usersManage)],
    schema: { tags: ['Admin users'], summary: 'List staff and administrator accounts' },
  }, async () => {
    const now = new Date();
    const users = await prisma.user.findMany({
      where: { role: { in: [UserRole.STAFF, UserRole.ADMIN] } },
      include: {
        refreshTokens: {
          where: { revokedAt: null, expiresAt: { gt: now } },
          select: { id: true },
        },
        permissionOverrides: {
          select: { granted: true, permission: { select: { key: true } } },
        },
      },
      orderBy: [{ role: 'desc' }, { createdAt: 'desc' }],
    });
    return {
      users: await Promise.all(users.map(async ({
        passwordHash: _passwordHash,
        permissionOverrides,
        refreshTokens,
        ...user
      }) => ({
        ...user,
        ...accountPresence({ ...user, refreshTokens }),
        permissions: await getEffectivePermissions(user.id, user.role),
        permissionOverrides: permissionOverrides.map((assignment) => ({
          key: assignment.permission.key,
          granted: assignment.granted,
        })),
      }))),
    };
  });

  app.post('/admin/users', {
    onRequest: [requirePermission(Permissions.usersManage)],
    schema: { tags: ['Admin users'], summary: 'Create a staff or administrator account' },
  }, async (request, reply) => {
    const body = backOfficeUserSchema.extend({ password: z.string().min(12).max(128) }).parse(request.body);
    if (body.permissionKeys && !request.permissions.includes(Permissions.permissionsManage)) {
      return reply.code(403).send({ error: 'FORBIDDEN', message: 'You cannot assign permissions.' });
    }
    const user = await prisma.$transaction(async (transaction) => {
      const created = await transaction.user.create({
        data: {
          email: body.email,
          fullName: body.fullName,
          idNumber: body.idNumber,
          role: body.role,
          isActive: body.isActive,
          passwordHash: await hashPassword(body.password),
        },
      });
      if (body.permissionKeys) {
        await replacePermissionOverrides(transaction, created.id, body.role, body.permissionKeys);
      }
      return created;
    });
    await prisma.auditLog.create({
      data: { actorId: request.user.sub, action: 'USER_CREATED', entityType: 'User', entityId: user.id, metadata: { role: user.role } },
    });
    return reply.status(201).send({ user: { ...user, passwordHash: undefined, permissions: await getEffectivePermissions(user.id, user.role) } });
  });

  app.patch('/admin/users/:id', {
    onRequest: [requirePermission(Permissions.usersManage)],
    schema: { tags: ['Admin users'], summary: 'Update a user and assigned permissions' },
  }, async (request, reply) => {
    const { id } = uuidParams.parse(request.params);
    const existing = await prisma.user.findFirst({
      where: { id, role: { in: [UserRole.STAFF, UserRole.ADMIN] } },
    });
    if (!existing) {
      return reply.code(404).send({ error: 'NOT_FOUND', message: 'User not found.' });
    }
    const body = backOfficeUserSchema.parse({ ...existing, ...(request.body as Record<string, unknown>) });
    if (id === request.user.sub && !body.isActive) {
      return reply.code(409).send({ error: 'CONFLICT', message: 'You cannot deactivate your own account.' });
    }
    if (id === request.user.sub && body.role !== existing.role) {
      return reply.code(409).send({ error: 'CONFLICT', message: 'You cannot change your own role.' });
    }
    if (!request.permissions.includes(Permissions.permissionsManage) && 'permissionKeys' in (request.body as Record<string, unknown>)) {
      return reply.code(403).send({ error: 'FORBIDDEN', message: 'You cannot assign permissions.' });
    }
    if (
      id === request.user.sub
      && body.permissionKeys
      && !body.permissionKeys.includes(Permissions.usersManage)
    ) {
      return reply.code(409).send({ error: 'CONFLICT', message: 'You cannot remove your own user-management access.' });
    }
    const user = await prisma.$transaction(async (transaction) => {
      const updated = await transaction.user.update({
        where: { id },
        data: {
          email: body.email,
          fullName: body.fullName,
          idNumber: body.idNumber,
          role: body.role,
          isActive: body.isActive,
          ...(body.password ? { passwordHash: await hashPassword(body.password) } : {}),
        },
      });
      if ('permissionKeys' in (request.body as Record<string, unknown>)) {
        await replacePermissionOverrides(transaction, id, body.role, body.permissionKeys ?? []);
      } else if (body.role !== existing.role) {
        await transaction.userPermission.deleteMany({ where: { userId: id } });
      }
      return updated;
    });
    await prisma.auditLog.create({
      data: { actorId: request.user.sub, action: 'USER_UPDATED', entityType: 'User', entityId: user.id, metadata: { role: user.role, isActive: user.isActive } },
    });
    return { user: { ...user, passwordHash: undefined, permissions: await getEffectivePermissions(user.id, user.role) } };
  });

  app.delete('/admin/users/:id', {
    onRequest: [requirePermission(Permissions.usersManage)],
    schema: { tags: ['Admin users'], summary: 'Delete a staff or administrator account' },
  }, async (request, reply) => {
    const { id } = uuidParams.parse(request.params);
    if (id === request.user.sub) {
      return reply.code(409).send({
        error: 'CONFLICT',
        message: 'You cannot delete your own account.',
      });
    }
    const user = await prisma.user.findFirst({
      where: { id, role: { in: [UserRole.STAFF, UserRole.ADMIN] } },
    });
    if (!user) {
      return reply.code(404).send({
        error: 'NOT_FOUND',
        message: 'Back-office user not found.',
      });
    }
    if (user.role === UserRole.ADMIN) {
      const activeAdministrators = await prisma.user.count({
        where: { role: UserRole.ADMIN, isActive: true },
      });
      if (activeAdministrators <= 1) {
        return reply.code(409).send({
          error: 'LAST_ADMIN',
          message: 'The final active administrator cannot be deleted.',
        });
      }
    }
    await prisma.$transaction(async (transaction) => {
      await transaction.auditLog.create({
        data: {
          actorId: request.user.sub,
          action: 'USER_DELETED',
          entityType: 'User',
          entityId: id,
          metadata: { role: user.role },
        },
      });
      await transaction.user.delete({ where: { id } });
    });
    return reply.status(204).send();
  });
}

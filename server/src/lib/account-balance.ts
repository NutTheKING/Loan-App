import { Prisma, TransactionStatus, TransactionType } from '@prisma/client';

import { prisma } from './prisma.js';
import { moneyToNumber } from './serializers.js';

type DatabaseClient = typeof prisma | Prisma.TransactionClient;

export async function completedBalance(
  userId: string,
  database: DatabaseClient = prisma,
): Promise<number> {
  const [credits, debits] = await Promise.all([
    database.transaction.aggregate({
      where: {
        userId,
        status: TransactionStatus.COMPLETED,
        type: {
          in: [TransactionType.LOAN_DISBURSEMENT, TransactionType.DEPOSIT],
        },
      },
      _sum: { amount: true },
    }),
    database.transaction.aggregate({
      where: {
        userId,
        status: TransactionStatus.COMPLETED,
        type: {
          in: [
            TransactionType.REPAYMENT,
            TransactionType.WITHDRAWAL,
            TransactionType.FEE,
          ],
        },
      },
      _sum: { amount: true },
    }),
  ]);
  return (
    moneyToNumber(credits._sum.amount ?? 0) -
    moneyToNumber(debits._sum.amount ?? 0)
  );
}

export async function availableBalance(
  userId: string,
  database: DatabaseClient = prisma,
): Promise<number> {
  const [balance, pendingWithdrawals] = await Promise.all([
    completedBalance(userId, database),
    database.transaction.aggregate({
      where: {
        userId,
        type: TransactionType.WITHDRAWAL,
        status: TransactionStatus.PENDING,
      },
      _sum: { amount: true },
    }),
  ]);
  return Math.max(
    0,
    balance - moneyToNumber(pendingWithdrawals._sum.amount ?? 0),
  );
}

export function serializeTransaction<T extends { amount: unknown }>(
  transaction: T,
): Omit<T, 'amount'> & { amount: number } {
  return {
    ...transaction,
    amount: Number(String(transaction.amount)),
  };
}

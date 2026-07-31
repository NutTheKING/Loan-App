import { LoanStatus, PaymentStatus } from '@prisma/client';

import { prisma } from './prisma.js';

export type LoanApplicationBlockReason =
  | 'PENDING_REVIEW'
  | 'UNPAID_APPROVED_LOAN';

export interface LoanApplicationBlock {
  loanId: string;
  loanNumber: string;
  status: LoanStatus;
  reason: LoanApplicationBlockReason;
  message: string;
}

export async function findLoanApplicationBlock(
  borrowerId: string,
  excludeLoanId?: string,
): Promise<LoanApplicationBlock | null> {
  const loan = await prisma.loan.findFirst({
    where: {
      borrowerId,
      submittedAt: { not: null },
      ...(excludeLoanId ? { id: { not: excludeLoanId } } : {}),
      OR: [
        { status: LoanStatus.PENDING },
        {
          status: LoanStatus.APPROVED,
          repayments: {
            some: {
              status: { not: PaymentStatus.PAID },
            },
          },
        },
      ],
    },
    orderBy: { createdAt: 'desc' },
    select: {
      id: true,
      loanNumber: true,
      status: true,
    },
  });

  if (!loan) {
    return null;
  }

  if (loan.status === LoanStatus.PENDING) {
    return {
      loanId: loan.id,
      loanNumber: loan.loanNumber,
      status: loan.status,
      reason: 'PENDING_REVIEW',
      message: `Loan ${loan.loanNumber} is pending review. Wait for a decision before applying again.`,
    };
  }

  return {
    loanId: loan.id,
    loanNumber: loan.loanNumber,
    status: loan.status,
    reason: 'UNPAID_APPROVED_LOAN',
    message: `Loan ${loan.loanNumber} must be fully repaid before you can apply for another loan.`,
  };
}

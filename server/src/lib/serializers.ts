import type { Decimal } from '@prisma/client/runtime/library';

type DecimalValue = Decimal | number | string;

export function moneyToNumber(value: DecimalValue): number {
  return typeof value === 'number' ? value : Number(value.toString());
}

export function serializeLoan<T extends Record<string, unknown>>(loan: T): T {
  const monetaryFields = ['principal', 'monthlyInterestRate', 'interestAmount', 'totalRepayment', 'monthlyPayment', 'stableIncome', 'amountDue', 'amountPaid'];
  const serialized = { ...loan } as Record<string, unknown>;
  for (const field of monetaryFields) {
    const value = serialized[field];
    if (value && typeof value === 'object' && 'toString' in value) {
      serialized[field] = moneyToNumber(value as Decimal);
    }
  }
  const repayments = serialized['repayments'];
  if (Array.isArray(repayments)) {
    serialized['repayments'] = repayments.map((repayment) =>
      repayment && typeof repayment === 'object' ? serializeLoan(repayment as Record<string, unknown>) : repayment,
    );
  }
  return serialized as T;
}

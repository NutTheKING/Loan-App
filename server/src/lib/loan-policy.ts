export type LoanPolicy = {
  minimumAmount: number;
  maximumAmount: number;
  allowedTerms: readonly number[];
  monthlyInterestRate: number;
  currency: string;
};

export const loanPolicy: LoanPolicy = {
  minimumAmount: 70000,
  maximumAmount: 1500000,
  allowedTerms: [4, 12, 24, 36],
  monthlyInterestRate: 0.005,
  currency: 'PHP',
};

export type LoanQuote = {
  principal: number;
  interestAmount: number;
  totalRepayment: number;
  monthlyPayment: number;
};

export type ScheduledRepayment = {
  installment: number;
  dueDate: Date;
  principal: number;
  interest: number;
  amountDue: number;
};

function toCents(value: number): number {
  return Math.round(value * 100);
}

function fromCents(value: number): number {
  return value / 100;
}

export function calculateLoanQuote(amount: number, termMonths: number, policy: LoanPolicy = loanPolicy): LoanQuote {
  if (!Number.isFinite(amount) || amount < policy.minimumAmount || amount > policy.maximumAmount) {
    throw new Error(`Loan amount must be between ${policy.minimumAmount} and ${policy.maximumAmount}.`);
  }
  if (!policy.allowedTerms.includes(termMonths)) {
    throw new Error(`Loan term must be one of: ${policy.allowedTerms.join(', ')} months.`);
  }

  const principalCents = toCents(amount);
  const interestCents = Math.round(principalCents * policy.monthlyInterestRate * termMonths);
  const totalCents = principalCents + interestCents;

  return {
    principal: fromCents(principalCents),
    interestAmount: fromCents(interestCents),
    totalRepayment: fromCents(totalCents),
    monthlyPayment: fromCents(Math.round(totalCents / termMonths)),
  };
}

export function createRepaymentSchedule(
  amount: number,
  termMonths: number,
  startsAt = new Date(),
  policy: LoanPolicy = loanPolicy,
): ScheduledRepayment[] {
  const quote = calculateLoanQuote(amount, termMonths, policy);
  const principalCents = toCents(quote.principal);
  const interestCents = toCents(quote.interestAmount);
  const basePrincipalCents = Math.floor(principalCents / termMonths);
  const baseInterestCents = Math.floor(interestCents / termMonths);
  const principalRemainder = principalCents % termMonths;
  const interestRemainder = interestCents % termMonths;

  return Array.from({ length: termMonths }, (_, index) => {
    const installment = index + 1;
    const principal = basePrincipalCents + (installment === termMonths ? principalRemainder : 0);
    const interest = baseInterestCents + (installment === termMonths ? interestRemainder : 0);
    const dueDate = new Date(Date.UTC(startsAt.getUTCFullYear(), startsAt.getUTCMonth() + installment, startsAt.getUTCDate()));
    return { installment, dueDate, principal: fromCents(principal), interest: fromCents(interest), amountDue: fromCents(principal + interest) };
  });
}

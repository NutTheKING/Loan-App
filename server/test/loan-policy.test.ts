import assert from 'node:assert/strict';
import test from 'node:test';

import { calculateLoanQuote, createRepaymentSchedule, loanPolicy } from '../src/lib/loan-policy.js';

test('calculates the existing 0.5% flat-rate loan policy', () => {
  const quote = calculateLoanQuote(70000, 4);

  assert.deepEqual(quote, {
    principal: 70000,
    interestAmount: 1400,
    totalRepayment: 71400,
    monthlyPayment: 17850,
  });
});

test('creates an exact repayment schedule', () => {
  const schedule = createRepaymentSchedule(70000, 4, new Date('2026-01-01T00:00:00.000Z'));

  assert.equal(schedule.length, 4);
  assert.equal(schedule.reduce((sum, payment) => sum + payment.amountDue, 0), 71400);
  assert.equal(schedule[0].dueDate.toISOString(), '2026-02-01T00:00:00.000Z');
});

test('rejects an amount or term outside the approved product', () => {
  assert.throws(() => calculateLoanQuote(loanPolicy.minimumAmount - 1, 4));
  assert.throws(() => calculateLoanQuote(loanPolicy.minimumAmount, 6));
});

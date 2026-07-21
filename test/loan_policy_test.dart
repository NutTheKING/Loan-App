import 'package:flutter_test/flutter_test.dart';
import 'package:loan_app/core/loan/loan_policy.dart';

void main() {
  test('keeps the current 0.5% monthly flat-rate loan calculation', () {
    final quote = LoanPolicy.calculate(amount: 70000, termMonths: 4);

    expect(quote.principal, 70000);
    expect(quote.interestAmount, 1400);
    expect(quote.totalRepayment, 71400);
    expect(quote.monthlyPayment, 17850);
  });

  test('rejects loan products outside the approved rules', () {
    expect(
      () => LoanPolicy.calculate(amount: 69999, termMonths: 4),
      throwsArgumentError,
    );
    expect(
      () => LoanPolicy.calculate(amount: 70000, termMonths: 6),
      throwsArgumentError,
    );
  });
}

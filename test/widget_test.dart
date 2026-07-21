import 'package:flutter_test/flutter_test.dart';
import 'package:loan_app/core/loan/loan_policy.dart';

void main() {
  test('maximum product amount calculates without rounding errors', () {
    final quote = LoanPolicy.calculate(
      amount: LoanPolicy.maximumAmount,
      termMonths: 36,
    );

    expect(quote.principal, LoanPolicy.maximumAmount);
    expect(quote.totalRepayment, 1770000);
  });
}

class LoanPolicy {
  static const minimumAmount = 70000.0;
  static const maximumAmount = 1500000.0;
  static const monthlyInterestRate = 0.005;
  static const allowedTerms = [4, 12, 24, 36];

  static LoanQuote calculate({
    required double amount,
    required int termMonths,
  }) {
    if (amount < minimumAmount || amount > maximumAmount) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Amount must be inside the loan product limit.',
      );
    }
    if (!allowedTerms.contains(termMonths)) {
      throw ArgumentError.value(
        termMonths,
        'termMonths',
        'Term is not available for this loan product.',
      );
    }

    final principal = _roundMoney(amount);
    final interest = _roundMoney(principal * monthlyInterestRate * termMonths);
    final total = _roundMoney(principal + interest);
    return LoanQuote(
      principal: principal,
      interestAmount: interest,
      totalRepayment: total,
      monthlyPayment: _roundMoney(total / termMonths),
    );
  }

  static double _roundMoney(double value) => (value * 100).round() / 100;
}

class LoanQuote {
  const LoanQuote({
    required this.principal,
    required this.interestAmount,
    required this.totalRepayment,
    required this.monthlyPayment,
  });

  final double principal;
  final double interestAmount;
  final double totalRepayment;
  final double monthlyPayment;
}

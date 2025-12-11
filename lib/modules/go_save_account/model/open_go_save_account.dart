class GoSaveAccount {
  final double initialDeposit;
  final String plan;
  final double interestRate; // in %
  final int periodMonths;

  GoSaveAccount({
    required this.initialDeposit,
    required this.plan,
    required this.interestRate,
    required this.periodMonths,
  });
}

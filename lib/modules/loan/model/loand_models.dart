class LoanModels {
  final double amount;
  final int period; // in months
  final double monthlyInterestRate;
  final double principal;
  final double interestAmount;
  final double paymentAmount;
  final DateTime disbursementDate;
  final String? frontIdPath;
  final String? backIdPath;
  final String? selfiePath;

  LoanModels({
    required this.amount,
    required this.period,
    required this.monthlyInterestRate,
    required this.principal,
    required this.interestAmount,
    required this.paymentAmount,
    required this.disbursementDate,
    this.frontIdPath,
    this.backIdPath,
    this.selfiePath,
  });
}

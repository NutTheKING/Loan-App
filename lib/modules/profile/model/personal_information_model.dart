class UserProfile {
  String profileUrl;
  String phoneNumber;

  String actualName;
  String idCardNumber;
  bool showFullId; // toggle

  String gender;
  String currentJob;
  double stableIncome;
  String loanPurpose;

  String currentAddress;
  String guarantorName;
  String guarantorPhone;

  double borrowingAmount;
  int months;
  double monthlyPayment;

  UserProfile({
    required this.profileUrl,
    required this.phoneNumber,
    required this.actualName,
    required this.idCardNumber,
    this.showFullId = false,
    required this.gender,
    required this.currentJob,
    required this.stableIncome,
    required this.loanPurpose,
    required this.currentAddress,
    required this.guarantorName,
    required this.guarantorPhone,
    required this.borrowingAmount,
    required this.months,
    required this.monthlyPayment,
  });
}

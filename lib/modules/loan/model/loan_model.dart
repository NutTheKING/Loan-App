enum LoanStatus { pending, approved, rejected }

class LoanModel {
  String id;
  double amount;
  DateTime createdAt;
  LoanStatus status;
  String? documentSelfie;
  String? idFront;
  String? idBack;

  LoanModel({
    required this.id,
    required this.amount,
    required this.createdAt,
    this.status = LoanStatus.pending,
    this.documentSelfie,
    this.idFront,
    this.idBack,
  });
}

class Beneficiary {
  String fullName;
  String phoneNumber;
  String idCard;
  bool showFullId;

  String relationship;
  String address;

  Beneficiary({
    required this.fullName,
    required this.phoneNumber,
    required this.idCard,
    this.showFullId = false,
    required this.relationship,
    required this.address,
  });
}

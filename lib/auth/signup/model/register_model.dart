class RegisterModel {
  String fullName;
  String sex;
  DateTime dob;
  String email;
  String idNumber;
  String? profilePath;
  String? idFrontPath;
  String? idBackPath;

  RegisterModel({
    required this.fullName,
    required this.sex,
    required this.dob,
    required this.email,
    required this.idNumber,
    this.profilePath,
    this.idFrontPath,
    this.idBackPath,
  });
}

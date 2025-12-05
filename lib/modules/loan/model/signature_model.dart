class SignatureModel {
  final double loanAmount;
  final int period;
  final bool agreedContract;
  final String signatureBase64; // stored as Base64 PNG

  SignatureModel({
    required this.loanAmount,
    required this.period,
    required this.agreedContract,
    required this.signatureBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      "loanAmount": loanAmount,
      "period": period,
      "agreedContract": agreedContract,
      "signatureBase64": signatureBase64,
    };
  }

  factory SignatureModel.fromJson(Map<String, dynamic> json) {
    return SignatureModel(
      loanAmount: json["loanAmount"] ?? 0,
      period: json["period"] ?? 0,
      agreedContract: json["agreedContract"] ?? false,
      signatureBase64: json["signatureBase64"] ?? "",
    );
  }
}

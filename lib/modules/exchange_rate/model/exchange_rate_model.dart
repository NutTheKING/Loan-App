class ExchangeRate {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime updatedAt;

  ExchangeRate({required this.fromCurrency, required this.toCurrency, required this.rate, required this.updatedAt});
}

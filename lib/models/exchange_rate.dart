class ExchangeRate {
  final Map<String, dynamic> rates;

  ExchangeRate({required this.rates});

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      rates: json['conversion_rates'] as Map<String, dynamic>,
    );
  }
}
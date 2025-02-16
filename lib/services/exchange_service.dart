import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeService {
  Map<String, dynamic>? _exchangeRate;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get exchangeRate => _exchangeRate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchExchangeRates() async {
    _isLoading = true;
    _errorMessage = null;

    final String apiKey = "18e85c40aea034c90691634d";
    final String apiUrl = "https://v6.exchangerate-api.com/v6/$apiKey/latest/USD";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("API Yanıtı: $data");

        if (data['result'] == 'success') {
          _exchangeRate = data['conversion_rates'];
        } else {
          _errorMessage = "API'den veri çekilemedi. Hata: ${data['error']}";
        }
      } else {
        _errorMessage = "API'den veri çekilemedi. Hata: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Veri yüklenirken hata oluştu: $e";
    }

    _isLoading = false;
  }
}
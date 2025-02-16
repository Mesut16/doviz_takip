import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ExchangeProvider with ChangeNotifier {
  Map<String, dynamic>? _exchangeRate;
  List<String> _favoriteCurrencies = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchText = "";

  Map<String, dynamic>? get exchangeRate => _exchangeRate;
  List<String> get favoriteCurrencies => _favoriteCurrencies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchText => _searchText;

  ExchangeProvider() {
    _loadFavorites();
  }


  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteCurrencies = prefs.getStringList('favorites') ?? [];
    notifyListeners();
  }


  void addToFavorites(String currencyCode) async {
    if (!_favoriteCurrencies.contains(currencyCode)) {
      _favoriteCurrencies.add(currencyCode);
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('favorites', _favoriteCurrencies);
      notifyListeners();
    }
  }


  void removeFromFavorites(String currencyCode) async {
    _favoriteCurrencies.remove(currencyCode);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', _favoriteCurrencies);
    notifyListeners();
  }


  Future<void> fetchExchangeRates() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

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
    notifyListeners();
  }


  void filterRates(String text) {
    _searchText = text;
    notifyListeners();
  }


  List<MapEntry<String, dynamic>> getFilteredRates() {
    if (_exchangeRate == null) return [];
    return _exchangeRate!.entries.where((entry) {
      return entry.key.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();
  }
}
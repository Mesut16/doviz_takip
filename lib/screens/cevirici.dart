import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exchange_provider.dart';

class CeviriciScreen extends StatefulWidget {
  @override
  _CeviriciScreenState createState() => _CeviriciScreenState();
}

class _CeviriciScreenState extends State<CeviriciScreen> {
  String? _selectedFromCurrency;
  String? _selectedToCurrency;
  double _amount = 0;
  double _convertedAmount = 0;

  @override
  void initState() {
    super.initState();

    final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    final currencies = exchangeProvider.exchangeRate?.keys.toList();

    if (currencies != null && currencies.isNotEmpty) {
      setState(() {
        _selectedFromCurrency = currencies[0];
        _selectedToCurrency = currencies.length > 1 ? currencies[1] : currencies[0];
      });
    }
  }

  void _convertCurrency() {
    if (_selectedFromCurrency != null && _selectedToCurrency != null) {
      final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
      final fromRate = exchangeProvider.exchangeRate?[_selectedFromCurrency] ?? 1;
      final toRate = exchangeProvider.exchangeRate?[_selectedToCurrency] ?? 1;
      setState(() {
        _convertedAmount = (_amount / fromRate) * toRate;
      });
    }
  }

  void _swapCurrencies() {
    if (_selectedFromCurrency != null && _selectedToCurrency != null) {
      setState(() {
        final temp = _selectedFromCurrency;
        _selectedFromCurrency = _selectedToCurrency;
        _selectedToCurrency = temp;
      });
      _convertCurrency();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.blue.shade800,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.currency_exchange, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text(
              "Döviz Çevirici",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildCurrencySelector("Çevrilecek Birim", _selectedFromCurrency, true)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: IconButton(
                    onPressed: _swapCurrencies,
                    icon: Icon(Icons.swap_horiz, color: Colors.blue.shade700, size: 32),
                  ),
                ),
                Expanded(child: _buildCurrencySelector("Çevrilen Birim", _selectedToCurrency, false)),
              ],
            ),
            SizedBox(height: 20),
            _buildAmountInput(),
            SizedBox(height: 20),
            _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(String title, String? selectedValue, bool isFromCurrency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue[800])),
        SizedBox(height: 5),
        InkWell(
          onTap: () => _showCurrencySearch(context, isFromCurrency),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue.shade300),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.blue.shade100, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedValue ?? "Birim Seçin",
                  style: TextStyle(fontSize: 16, color: selectedValue != null ? Colors.blue[800] : Colors.grey),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.blue[800]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
        boxShadow: [
          BoxShadow(color: Colors.blue.shade100, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          labelText: "Miktar",
          border: InputBorder.none,
          labelStyle: TextStyle(color: Colors.blue.shade800),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            _amount = double.tryParse(value) ?? 0;
            _convertCurrency();
          });
        },
      ),
    );
  }

  Widget _buildResultCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue[800],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Sonuç",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            SizedBox(height: 10),
            Text(
              "$_convertedAmount",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCurrencySearch(BuildContext context, bool isFromCurrency) async {
    final exchangeProvider = Provider.of<ExchangeProvider>(context, listen: false);
    final currencies = exchangeProvider.exchangeRate?.keys.toList() ?? [];
    String searchText = "";

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Döviz Ara...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (text) {
                      setState(() {
                        searchText = text;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: currencies.length,
                      itemBuilder: (context, index) {
                        final currency = currencies[index];
                        if (searchText.isEmpty || currency.toLowerCase().contains(searchText.toLowerCase())) {
                          return ListTile(
                            title: Text(currency),
                            onTap: () {
                              setState(() {
                                if (isFromCurrency) {
                                  _selectedFromCurrency = currency;
                                } else {
                                  _selectedToCurrency = currency;
                                }
                              });
                              _convertCurrency();
                              Navigator.pop(context);
                            },
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

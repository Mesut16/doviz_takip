import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exchange_provider.dart';

class TakipListesiScreen extends StatefulWidget {
  @override
  _TakipListesiScreenState createState() => _TakipListesiScreenState();
}

class _TakipListesiScreenState extends State<TakipListesiScreen> {
  @override
  Widget build(BuildContext context) {
    final exchangeProvider = Provider.of<ExchangeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Center(
          child: Text(
            "Takip Listesi",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: exchangeProvider.favoriteCurrencies.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 60, color: Colors.grey.shade400),
            SizedBox(height: 10),
            Text(
              "Takip ettiğiniz bir döviz veya altın bulunmamaktadır.",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: exchangeProvider.favoriteCurrencies.length,
        itemBuilder: (context, index) {
          final currencyCode = exchangeProvider.favoriteCurrencies[index];
          final currencyValue = exchangeProvider.exchangeRate?[currencyCode];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    currencyCode.substring(0, 2),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                  ),
                ),
                title: Text(
                  currencyCode,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                ),
                subtitle: Text(
                  currencyValue != null ? currencyValue.toString() : "-",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: IconButton(
                  iconSize: 30,
                  icon: Icon(
                    exchangeProvider.favoriteCurrencies.contains(currencyCode)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {

                    if (exchangeProvider.favoriteCurrencies.contains(currencyCode)) {
                      exchangeProvider.removeFromFavorites(currencyCode);
                    } else {
                      exchangeProvider.addToFavorites(currencyCode);
                    }
                    setState(() {});
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/exchange_provider.dart';
import 'takip_listesi.dart';
import 'cevirici.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomeContent(),
    CeviriciScreen(),
    TakipListesiScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "MESUT ",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: Color.fromRGBO(0, 22, 76, 100),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: "YILDIZ",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2CCCAF), Color(0xAB1C508A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Ana Sayfa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: "Çevirici",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Takip Listesi",
          ),
        ],
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}


class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    final exchangeProvider = Provider.of<ExchangeProvider>(context);
    final TextEditingController _searchController = TextEditingController();


    if (!exchangeProvider.isLoading && exchangeProvider.exchangeRate == null) {
      exchangeProvider.fetchExchangeRates();
    }


    var filteredRates = exchangeProvider.getFilteredRates();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Arama yapın...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.search),
            ),
            style: TextStyle(fontSize: 16),
            onChanged: (text) {

              exchangeProvider.filterRates(text);
            },
          ),
        ),
        Expanded(
          child: exchangeProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : filteredRates.isEmpty
              ? Center(
            child: Text(
              "Bulunamadı",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          )
              : ListView.builder(
            itemCount: filteredRates.length,
            itemBuilder: (context, index) {
              final currencyCode = filteredRates[index].key;
              final currencyValue = filteredRates[index].value;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: exchangeProvider.favoriteCurrencies.contains(currencyCode)
                    ? Colors.blue[50] // Favori ise arka plan rengi değişir
                    : Colors.white,
                child: ListTile(
                  title: Text(
                    currencyCode,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    currencyValue != null ? currencyValue.toString() : "-",
                    style: TextStyle(fontSize: 16),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      exchangeProvider.favoriteCurrencies.contains(currencyCode)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: exchangeProvider.favoriteCurrencies.contains(currencyCode)
                          ? Colors.red
                          : Colors.grey,
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
              );
            },
          ),
        ),
      ],
    );
  }
}

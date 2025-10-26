import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum MarketType { forex, stocks, futures, crypto }

class MarketData {
  final String symbol;
  final double price;
  final double change;
  final double changePercent;
  final DateTime timestamp;

  MarketData({
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.timestamp,
  });

  factory MarketData.fromJson(Map<String, dynamic> json, String symbol) {
    return MarketData(
      symbol: symbol,
      price: json['price']?.toDouble() ?? 0.0,
      change: json['change']?.toDouble() ?? 0.0,
      changePercent: json['changePercent']?.toDouble() ?? 0.0,
      timestamp: DateTime.now(),
    );
  }
}

class MarketDataProvider with ChangeNotifier {
  MarketType _selectedMarket = MarketType.stocks;
  MarketData? _currentData;
  bool _isLoading = false;
  String? _error;

  MarketType get selectedMarket => _selectedMarket;
  MarketData? get currentData => _currentData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setMarket(MarketType market) {
    _selectedMarket = market;
    notifyListeners();
  }

  Future<void> fetchMarketData(String symbol) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Using Alpha Vantage API as an example - you'll need to get your own API key
      String apiKey = 'YOUR_API_KEY_HERE'; // Replace with actual API key
      String url;

      switch (_selectedMarket) {
        case MarketType.forex:
          url = 'https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=$symbol&to_currency=USD&apikey=$apiKey';
          break;
        case MarketType.stocks:
          url = 'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey';
          break;
        case MarketType.futures:
          // Futures might require different API or endpoint
          url = 'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey';
          break;
        case MarketType.crypto:
          url = 'https://www.alphavantage.co/query?function=CURRENCY_EXCHANGE_RATE&from_currency=$symbol&to_currency=USD&apikey=$apiKey';
          break;
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Parse the response based on market type
        Map<String, dynamic> quoteData;
        switch (_selectedMarket) {
          case MarketType.forex:
            quoteData = data['Realtime Currency Exchange Rate'] ?? {};
            _currentData = MarketData.fromJson({
              'price': double.tryParse(quoteData['5. Exchange Rate'] ?? '0'),
              'change': 0.0, // Forex APIs might not provide change directly
              'changePercent': 0.0,
            }, symbol);
            break;
          case MarketType.stocks:
            quoteData = data['Global Quote'] ?? {};
            _currentData = MarketData.fromJson({
              'price': double.tryParse(quoteData['05. price'] ?? '0'),
              'change': double.tryParse(quoteData['09. change'] ?? '0'),
              'changePercent': double.tryParse(quoteData['10. change percent']?.replaceAll('%', '') ?? '0'),
            }, symbol);
            break;
          case MarketType.futures:
            // Similar to stocks for now
            quoteData = data['Global Quote'] ?? {};
            _currentData = MarketData.fromJson({
              'price': double.tryParse(quoteData['05. price'] ?? '0'),
              'change': double.tryParse(quoteData['09. change'] ?? '0'),
              'changePercent': double.tryParse(quoteData['10. change percent']?.replaceAll('%', '') ?? '0'),
            }, symbol);
            break;
          case MarketType.crypto:
            quoteData = data['Realtime Currency Exchange Rate'] ?? {};
            _currentData = MarketData.fromJson({
              'price': double.tryParse(quoteData['5. Exchange Rate'] ?? '0'),
              'change': 0.0,
              'changePercent': 0.0,
            }, symbol);
            break;
        }
      } else {
        _error = 'Failed to fetch data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching data: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}

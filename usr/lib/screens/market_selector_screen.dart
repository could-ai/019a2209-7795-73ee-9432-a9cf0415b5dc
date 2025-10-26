import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_data_provider.dart';
import 'calculator_screen.dart';
import 'package:intl/intl.dart'; // For formatting

class MarketSelectorScreen extends StatefulWidget {
  const MarketSelectorScreen({super.key});

  @override
  State<MarketSelectorScreen> createState() => _MarketSelectorScreenState();
}

class _MarketSelectorScreenState extends State<MarketSelectorScreen> {
  final TextEditingController _symbolController = TextEditingController();

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }

  void _fetchData() {
    final symbol = _symbolController.text.trim().toUpperCase();
    if (symbol.isNotEmpty) {
      // Hide keyboard
      FocusScope.of(context).unfocus();
      context.read<MarketDataProvider>().fetchMarketData(symbol);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a symbol.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Calculator'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Select Market Type',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Consumer<MarketDataProvider>(
                    builder: (context, provider, child) {
                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: MarketType.values.map((market) {
                          return ChoiceChip(
                            label: Text(market.name.toUpperCase()),
                            selected: provider.selectedMarket == market,
                            onSelected: (selected) {
                              if (selected) {
                                provider.setMarket(market);
                              }
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '2. Enter Symbol & Fetch Data',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _symbolController,
                    decoration: const InputDecoration(
                      labelText: 'e.g., AAPL, EUR, BTC',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _fetchData(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      onPressed: _fetchData,
                      label: const Text('Fetch Live Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Consumer<MarketDataProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Card(
                  color: Colors.red.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: ${provider.error}',
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                );
              }

              if (provider.currentData != null) {
                final data = provider.currentData!;
                final priceFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
                final changeColor = data.change >= 0 ? Colors.green : Colors.red;

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Market Data',
                          style: theme.textTheme.titleLarge,
                        ),
                        const Divider(height: 24),
                        ListTile(
                          title: const Text('Symbol'),
                          trailing: Text(data.symbol, style: theme.textTheme.bodyLarge),
                        ),
                        ListTile(
                          title: const Text('Price'),
                          trailing: Text(priceFormat.format(data.price), style: theme.textTheme.bodyLarge),
                        ),
                        ListTile(
                          title: const Text('Change'),
                          trailing: Text(
                            '${data.change.toStringAsFixed(2)} (${data.changePercent.toStringAsFixed(2)}%)',
                            style: theme.textTheme.bodyLarge?.copyWith(color: changeColor),
                          ),
                        ),
                        ListTile(
                          title: const Text('Last Updated'),
                          trailing: Text(DateFormat.yMd().add_jms().format(data.timestamp), style: theme.textTheme.bodyMedium),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.calculate),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalculatorScreen(symbol: data.symbol),
                                ),
                              );
                            },
                            label: const Text('Open Calculator'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const Center(
                child: Text(
                  'Enter a symbol to see live market information.',
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

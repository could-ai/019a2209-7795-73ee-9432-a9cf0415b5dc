import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_data_provider.dart';
import 'calculator_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Market Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer<MarketDataProvider>(
              builder: (context, provider, child) {
                return Wrap(
                  spacing: 8.0,
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
            const SizedBox(height: 24),
            TextField(
              controller: _symbolController,
              decoration: const InputDecoration(
                labelText: 'Enter Symbol (e.g., AAPL for stocks, EUR for forex)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final symbol = _symbolController.text.trim().toUpperCase();
                if (symbol.isNotEmpty) {
                  context.read<MarketDataProvider>().fetchMarketData(symbol);
                }
              },
              child: const Text('Fetch Live Data'),
            ),
            const SizedBox(height: 24),
            Consumer<MarketDataProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }

                if (provider.currentData != null) {
                  final data = provider.currentData!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Symbol: ${data.symbol}'),
                          Text('Price: \\\$data.price.toStringAsFixed(2)}'),
                          Text('Change: \\\$data.change.toStringAsFixed(2)} (${data.changePercent.toStringAsFixed(2)}%)'),
                          Text('Last Updated: ${data.timestamp.toString()}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalculatorScreen(symbol: data.symbol),
                                ),
                              );
                            },
                            child: const Text('Open Calculator'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const Text('Enter a symbol and fetch data to see live market information.');
              },
            ),
          ],
        ),
      ),
    );
  }
}

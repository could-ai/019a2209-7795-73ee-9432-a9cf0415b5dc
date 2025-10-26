import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_data_provider.dart';
import '../models/calculation_result.dart';
import '../utils/calculations.dart';
import 'package:fl_chart/fl_chart.dart';

class CalculatorScreen extends StatefulWidget {
  final String symbol;

  const CalculatorScreen({super.key, required this.symbol});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _periodController = TextEditingController(text: '20');
  final TextEditingController _deviationController = TextEditingController(text: '2');
  CalculationResult? _result;

  @override
  void dispose() {
    _periodController.dispose();
    _deviationController.dispose();
    super.dispose();
  }

  void _calculate() {
    final provider = context.read<MarketDataProvider>();
    if (provider.currentData != null) {
      final period = int.tryParse(_periodController.text) ?? 20;
      final deviation = double.tryParse(_deviationController.text) ?? 2.0;
      
      // For demonstration, we'll use mock historical data
      // In a real app, you'd fetch historical data from API
      final historicalPrices = generateMockHistoricalData(provider.currentData!.price, period);
      
      _result = calculateMeanReversionAndZones(historicalPrices, period, deviation);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator - ${widget.symbol}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mean Reversion & Zone Strength Calculator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _periodController,
                decoration: const InputDecoration(
                  labelText: 'Lookback Period',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _deviationController,
                decoration: const InputDecoration(
                  labelText: 'Standard Deviation Multiplier',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculate,
                child: const Text('Calculate'),
              ),
              const SizedBox(height: 24),
              if (_result != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mean: ${_result!.mean.toStringAsFixed(4)}'),
                        Text('Standard Deviation: ${_result!.stdDev.toStringAsFixed(4)}'),
                        Text('Z-Score: ${_result!.zScore.toStringAsFixed(4)}'),
                        Text('Upper Band: ${_result!.upperBand.toStringAsFixed(4)}'),
                        Text('Lower Band: ${_result!.lowerBand.toStringAsFixed(4)}'),
                        Text('Supply Zone Strength: ${_result!.supplyZoneStrength.toStringAsFixed(2)}%'),
                        Text('Demand Zone Strength: ${_result!.demandZoneStrength.toStringAsFixed(2)}%'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Price Chart with Bollinger Bands',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _result!.priceSpots,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 2,
                        ),
                        LineChartBarData(
                          spots: _result!.upperBandSpots,
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 1,
                          dashArray: [5, 5],
                        ),
                        LineChartBarData(
                          spots: _result!.lowerBandSpots,
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 1,
                          dashArray: [5, 5],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

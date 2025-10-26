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
  void initState() {
    super.initState();
    // Perform initial calculation on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculate());
  }

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
      
      final historicalPrices = generateMockHistoricalData(provider.currentData!.price, period);
      
      setState(() {
        _result = calculateMeanReversionAndZones(historicalPrices, period, deviation);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator - ${widget.symbol}'),
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
                  Text('Calculation Settings', style: theme.textTheme.titleLarge),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      onPressed: _calculate,
                      label: const Text('Recalculate'),
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
          if (_result != null) ...[
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calculation Results', style: theme.textTheme.titleLarge),
                    const Divider(height: 24),
                    _buildResultTile('Mean (Average Price)', _result!.mean.toStringAsFixed(4)),
                    _buildResultTile('Standard Deviation', _result!.stdDev.toStringAsFixed(4)),
                    _buildResultTile('Z-Score', _result!.zScore.toStringAsFixed(4)),
                    _buildResultTile('Upper Band', _result!.upperBand.toStringAsFixed(4)),
                    _buildResultTile('Lower Band', _result!.lowerBand.toStringAsFixed(4)),
                    const SizedBox(height: 16),
                    _buildZoneStrengthIndicator(
                      'Supply Zone Strength', 
                      _result!.supplyZoneStrength,
                      Colors.orange
                    ),
                    const SizedBox(height: 16),
                    _buildZoneStrengthIndicator(
                      'Demand Zone Strength', 
                      _result!.demandZoneStrength,
                      Colors.lightBlue
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price Chart with Bollinger Bands', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: (_result!.priceSpots.length / 5).floorToDouble()))),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _result!.priceSpots,
                              isCurved: true,
                              color: theme.primaryColor,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: _result!.upperBandSpots,
                              isCurved: true,
                              color: Colors.red,
                              barWidth: 1.5,
                              dashArray: [5, 5],
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: _result!.lowerBandSpots,
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 1.5,
                              dashArray: [5, 5],
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      dense: true,
    );
  }

  Widget _buildZoneStrengthIndicator(String title, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ${value.toStringAsFixed(2)}%'),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: color.withOpacity(0.2),
          color: color,
          minHeight: 8,
        ),
      ],
    );
  }
}

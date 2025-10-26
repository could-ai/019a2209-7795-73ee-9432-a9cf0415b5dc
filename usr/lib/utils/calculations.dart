import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import '../models/calculation_result.dart';

// Generate mock historical data for demonstration
List<double> generateMockHistoricalData(double currentPrice, int period) {
  final random = Random();
  List<double> prices = [];
  double price = currentPrice;

  for (int i = period; i >= 0; i--) {
    // Add some randomness to simulate price movement
    double change = (random.nextDouble() - 0.5) * 0.02 * price;
    price += change;
    prices.add(price);
  }

  return prices;
}

CalculationResult calculateMeanReversionAndZones(
  List<double> prices, 
  int period, 
  double deviationMultiplier
) {
  // Calculate moving average and standard deviation
  double sum = 0;
  double sumSquares = 0;

  for (int i = 0; i < period; i++) {
    sum += prices[i];
    sumSquares += prices[i] * prices[i];
  }

  double mean = sum / period;
  double variance = (sumSquares / period) - (mean * mean);
  double stdDev = sqrt(variance);

  // Current price (last in the list)
  double currentPrice = prices.last;
  
  // Z-score for mean reversion
  double zScore = (currentPrice - mean) / stdDev;

  // Bollinger Bands
  double upperBand = mean + (deviationMultiplier * stdDev);
  double lowerBand = mean - (deviationMultiplier * stdDev);

  // Zone strength calculation (simplified)
  // Supply zone strength: how far current price is below mean relative to bands
  double supplyZoneStrength = max(0, min(100, 50 + (50 * (mean - currentPrice) / (upperBand - mean))));
  
  // Demand zone strength: how far current price is above mean relative to bands
  double demandZoneStrength = max(0, min(100, 50 + (50 * (currentPrice - mean) / (mean - lowerBand))));

  // Prepare chart data
  List<FlSpot> priceSpots = [];
  List<FlSpot> upperBandSpots = [];
  List<FlSpot> lowerBandSpots = [];

  for (int i = 0; i < prices.length; i++) {
    priceSpots.add(FlSpot(i.toDouble(), prices[i]));
    upperBandSpots.add(FlSpot(i.toDouble(), upperBand));
    lowerBandSpots.add(FlSpot(i.toDouble(), lowerBand));
  }

  return CalculationResult(
    mean: mean,
    stdDev: stdDev,
    zScore: zScore,
    upperBand: upperBand,
    lowerBand: lowerBand,
    supplyZoneStrength: supplyZoneStrength,
    demandZoneStrength: demandZoneStrength,
    priceSpots: priceSpots,
    upperBandSpots: upperBandSpots,
    lowerBandSpots: lowerBandSpots,
  );
}

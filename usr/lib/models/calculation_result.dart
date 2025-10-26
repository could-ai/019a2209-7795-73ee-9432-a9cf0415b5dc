import 'package:fl_chart/fl_chart.dart';

class CalculationResult {
  final double mean;
  final double stdDev;
  final double zScore;
  final double upperBand;
  final double lowerBand;
  final double supplyZoneStrength;
  final double demandZoneStrength;
  final List<FlSpot> priceSpots;
  final List<FlSpot> upperBandSpots;
  final List<FlSpot> lowerBandSpots;

  CalculationResult({
    required this.mean,
    required this.stdDev,
    required this.zScore,
    required this.upperBand,
    required this.lowerBand,
    required this.supplyZoneStrength,
    required this.demandZoneStrength,
    required this.priceSpots,
    required this.upperBandSpots,
    required this.lowerBandSpots,
  });
}
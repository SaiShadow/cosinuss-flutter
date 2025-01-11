import 'package:cosinuss/models/data/baseline_metrics.dart';
import 'package:cosinuss/models/data/session_data.dart';
import 'package:cosinuss/models/logic/calculator.dart';

class StressCalculator extends Calculator {
  /// Calculates stress based on the last set of session data and the baseline metrics.
  /// Returns a score between 0.0 (low stress) and 1.0 (high stress).
  double calculateStress(
      List<SessionData> recentData, BaselineMetrics baselineMetrics) {
    if (recentData.isEmpty) return 0.0;

    // Calculate deviations from baseline
    double heartRateDeviation =
        calculateHeartRateDeviation(recentData, baselineMetrics);

    double bodyTemperatureDeviation =
        calculateBodyTemperatureDeviation(recentData, baselineMetrics);

    // Score logic: Higher deviation = higher stress
    double heartRateScore = (heartRateDeviation > 10.0) ? 1.0 : 0.5;
    double temperatureScore = (bodyTemperatureDeviation > 0.5) ? 1.0 : 0.5;

    // Weighted average for final score
    return (heartRateScore * 0.7) + (temperatureScore * 0.3);
  }
}

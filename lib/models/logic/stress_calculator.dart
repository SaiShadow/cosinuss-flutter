import 'package:cosinuss/models/data/baseline_metrics.dart';
import 'package:cosinuss/models/data/session_data.dart';
import 'package:cosinuss/models/logic/calculator.dart';

class StressCalculator extends Calculator {
  /// Calculates stress based on the last set of session data and the baseline metrics.
  /// Returns a score between 0.0 (low stress) and 1.0 (high stress).
  double calculateStress(
      List<SessionData> recentData, BaselineMetrics baselineMetrics) {
    if (recentData.isEmpty) return 0.0;

    double heartRateDeviation =
        calculateHeartRateDeviation(recentData, baselineMetrics);
    double bodyTemperatureDeviation =
        calculateBodyTemperatureDeviation(recentData, baselineMetrics);

    // Use accelerometer data for stress scoring
    List<int> accData =
        recentData.expand((data) => [data.accX, data.accY, data.accZ]).toList();
    double movementVariance = calculateMovementVariance(accData);

    // Scoring: Higher deviation = higher stress
    double hrScore = (heartRateDeviation > 10.0)
        ? 1.0
        : (heartRateDeviation > 5.0)
            ? 0.7
            : 0.3;
    double tempScore = (bodyTemperatureDeviation > 0.5)
        ? 1.0
        : (bodyTemperatureDeviation > 0.2)
            ? 0.7
            : 0.3;
    double movementScore = (movementVariance > 10.0)
        ? 1.0
        : (movementVariance > 5.0)
            ? 0.7
            : 0.3;

    return (hrScore * 0.6) +
        (tempScore * 0.3) +
        (movementScore * 0.1); // Weighted
  }
}

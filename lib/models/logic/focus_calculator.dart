import 'package:cosinuss/models/data/baseline_metrics.dart';
import 'package:cosinuss/models/data/session_data.dart';
import 'package:cosinuss/models/logic/calculator.dart';

class FocusCalculator extends Calculator {
  /// Calculates focus based on the last set of session data and the baseline metrics.
  /// Returns a score between 0.0 (low focus) and 1.0 (high focus).
  double calculateFocus(
      List<SessionData> recentData, BaselineMetrics baselineMetrics) {
    if (recentData.isEmpty) return 0.0;

    double heartRateDeviation =
        calculateHeartRateDeviation(recentData, baselineMetrics);

    // Use accelerometer data for movement scoring
    List<int> accData =
        recentData.expand((data) => [data.accX, data.accY, data.accZ]).toList();
    double movementVariance = calculateMovementVariance(accData);

    // Calculate temperature stability
    List<double> temperatures =
        recentData.map((data) => data.bodyTemperature).toList();
    double tempStability = calculateTemperatureStability(temperatures);

    // Scoring: Lower deviation = higher focus
    double hrScore = (heartRateDeviation < 5.0)
        ? 1.0
        : (heartRateDeviation < 10.0)
            ? 0.7
            : 0.3;
    double movementScore = (movementVariance < 5.0)
        ? 1.0
        : (movementVariance < 10.0)
            ? 0.7
            : 0.3;
    double tempScore = (tempStability > 0.9)
        ? 1.0
        : (tempStability > 0.7)
            ? 0.7
            : 0.3;

    return (hrScore * 0.5) +
        (movementScore * 0.3) +
        (tempScore * 0.2); // Weighted
  }
}

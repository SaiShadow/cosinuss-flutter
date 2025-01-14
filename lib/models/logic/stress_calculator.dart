import 'package:cosinuss/models/data/baseline_metrics.dart';
import 'package:cosinuss/models/data/session_data.dart';
import 'package:cosinuss/models/logic/calculator.dart';

/// A class responsible for calculating stress levels based on session data and baseline metrics.
///
/// The stress calculation evaluates heart rate deviation, body temperature deviation,
/// and movement variance to compute a stress score between 0.0 (low stress) and 1.0 (high stress).
class StressCalculator extends Calculator {
  /// Calculates the stress score based on the last set of session data and baseline metrics.
  ///
  /// The stress score is determined by evaluating the following:
  /// - Heart rate deviation: Higher deviations indicate higher stress.
  /// - Body temperature deviation: Significant changes in temperature indicate higher stress.
  /// - Movement variance: More movement variance indicates higher stress.
  ///
  /// [recentData]: A list of session data points recorded during the current session.
  /// [baselineMetrics]: The baseline metrics against which deviations are measured.
  ///
  /// Returns a stress score between 0.0 and 1.0.
  double calculateStress(
      List<SessionData> recentData, BaselineMetrics baselineMetrics) {
    if (recentData.isEmpty) return 0.0;

    // Calculate heart rate deviation from baseline
    double heartRateDeviation =
        calculateHeartRateDeviation(recentData, baselineMetrics);

    // Calculate body temperature deviation from baseline
    double bodyTemperatureDeviation =
        calculateBodyTemperatureDeviation(recentData, baselineMetrics);

    // Use accelerometer data for movement variance calculation
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

    // Compute the final stress score using weighted metrics
    return (hrScore * 0.6) +
        (tempScore * 0.3) +
        (movementScore * 0.1); // Weighted
  }
}

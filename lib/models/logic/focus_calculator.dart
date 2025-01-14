import 'package:cosinuss/models/data/baseline_metrics.dart';
import 'package:cosinuss/models/data/session_data.dart';
import 'package:cosinuss/models/logic/calculator.dart';

/// A class responsible for calculating focus levels based on session data and baseline metrics.
///
/// The focus calculation uses a combination of heart rate deviation, movement variance,
/// and temperature stability to compute a focus score between 0.0 (low focus) and 1.0 (high focus).
class FocusCalculator extends Calculator {
  /// Calculates the focus score based on the last set of session data and baseline metrics.
  ///
  /// The focus score is determined by evaluating the following:
  /// - Heart rate deviation: Lower deviations indicate higher focus.
  /// - Movement variance: Less movement variance indicates higher focus.
  /// - Temperature stability: A stable temperature indicates higher focus.
  ///
  /// [recentData]: A list of session data points recorded during the current session.
  /// [baselineMetrics]: The baseline metrics against which deviations are measured.
  ///
  /// Returns a focus score between 0.0 and 1.0.
  double calculateFocus(
      List<SessionData> recentData, BaselineMetrics baselineMetrics) {
    if (recentData.isEmpty) return 0.0;

    // Calculate heart rate deviation from baseline
    double heartRateDeviation =
        calculateHeartRateDeviation(recentData, baselineMetrics);

    // Use accelerometer data for movement variance calculation
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

    // Compute the final focus score using weighted metrics
    return (hrScore * 0.5) +
        (movementScore * 0.3) +
        (tempScore * 0.2); // Weighted
  }
}

import 'package:cosinuss/models/data/baseline_metrics.dart';
import 'package:cosinuss/models/data/session_data.dart';
import 'package:cosinuss/models/logic/calculator.dart';

class FocusCalculator extends Calculator {
  /// Calculates focus based on the last set of session data and the baseline metrics.
  /// Returns a score between 0.0 (low focus) and 1.0 (high focus).
  double calculateFocus(
      List<SessionData> recentData, BaselineMetrics baselineMetrics) {
    if (recentData.isEmpty) return 0.0;

    // Calculate deviations from baseline
    double heartRateDeviation =
        calculateHeartRateDeviation(recentData, baselineMetrics);

    double movementDeviation = calculateMovementDeviation(
        recentData, baselineMetrics); // Normalize by 3 axes

    // Score logic: Lower deviation = higher focus
    double heartRateScore = (heartRateDeviation < 5.0) ? 1.0 : 0.5;
    double movementScore = (movementDeviation < 5.0) ? 1.0 : 0.5;

    // Weighted average for final score
    return (heartRateScore * 0.6) + (movementScore * 0.4);
  }
}

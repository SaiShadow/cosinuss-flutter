import 'package:cosinuss/models/data/baseline_metrics.dart';
import 'package:cosinuss/models/data/session_data.dart';

/// A utility class for calculating various metrics based on session data and baseline metrics.
class Calculator {
  /// Calculates the average deviation of heart rate values from the baseline.
  ///
  /// [recentData]: A list of recent session data points.
  /// [baselineMetrics]: The baseline metrics containing the average heart rate.
  ///
  /// Returns the average heart rate deviation.
  double calculateHeartRateDeviation(
      List<SessionData> recentData, BaselineMetrics baselineMetrics) {
    return recentData
            .map((data) =>
                (data.heartRate - baselineMetrics.averageHeartRate).abs())
            .reduce((a, b) => a + b) /
        recentData.length;
  }

  /// Calculates the average deviation of body temperature values from the baseline.
  ///
  /// [recentData]: A list of recent session data points.
  /// [baselineMetrics]: The baseline metrics containing the average body temperature.
  ///
  /// Returns the average body temperature deviation.
  double calculateBodyTemperatureDeviation(
      List<SessionData> recentData, BaselineMetrics baselineMetrics) {
    return recentData
            .map((data) =>
                (data.bodyTemperature - baselineMetrics.averageBodyTemperature)
                    .abs())
            .reduce((a, b) => a + b) /
        recentData.length;
  }

  /// Calculates the average deviation of accelerometer values (X, Y, Z) from the baseline.
  ///
  /// [recentData]: A list of recent session data points.
  /// [baselineMetrics]: The baseline metrics containing the average accelerometer values.
  ///
  /// Returns the average movement deviation, normalized across all axes.
  double calculateMovementDeviation(
      List<SessionData> recentData, BaselineMetrics baselineMetrics) {
    return recentData
            .map((data) =>
                (data.accX - baselineMetrics.averageAccX).abs() +
                (data.accY - baselineMetrics.averageAccY).abs() +
                (data.accZ - baselineMetrics.averageAccZ).abs())
            .reduce((a, b) => a + b) /
        (recentData.length * 3); // Normalize by 3 axes
  }

  /// Calculates the variance of accelerometer data.
  ///
  /// [accData]: A list of accelerometer values (X, Y, Z) over time.
  ///
  /// Returns the variance of the accelerometer data.
  double calculateMovementVariance(List<int> accData) {
    if (accData.isEmpty) return 0.0;

    double mean = accData.reduce((a, b) => a + b) / accData.length;
    double sumSquaredDiff =
        accData.fold(0, (prev, val) => prev + (val - mean) * (val - mean));
    return sumSquaredDiff / accData.length; // Variance
  }

  /// Calculates the stability of body temperature over a given period.
  ///
  /// [temperatures]: A list of body temperature values over time.
  ///
  /// Stability is defined as the proportion of temperature readings within ±0.5 °C of the mean.
  ///
  /// Returns a value between 0.0 (low stability) and 1.0 (high stability).
  double calculateTemperatureStability(List<double> temperatures) {
    if (temperatures.isEmpty) return 0.0;

    double mean = temperatures.reduce((a, b) => a + b) / temperatures.length;
    double stability =
        temperatures.where((temp) => (temp - mean).abs() < 0.5).length /
            temperatures.length;
    return stability;
  }
}

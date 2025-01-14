import 'package:cosinuss/models/data/session_data.dart';

/// Represents baseline metrics for heart rate, body temperature,
/// and accelerometer readings (X, Y, Z axes).
/// Used to calculate and update user-specific averages for personalized measurements.
class BaselineMetrics {
  /// The average heart rate (in bpm).
  final double averageHeartRate;

  /// The average body temperature (in °C).
  final double averageBodyTemperature;

  /// The average X-axis, Y-axis, Z-axis accelerometer value.
  final double averageAccX, averageAccY, averageAccZ;

  /// Constructs a `BaselineMetrics` instance with specified averages.
  ///
  /// [averageHeartRate]: The average heart rate.
  /// [averageBodyTemperature]: The average body temperature.
  /// [averageAccX], [averageAccY], [averageAccZ]: The average accelerometer readings.
  BaselineMetrics({
    required this.averageHeartRate,
    required this.averageBodyTemperature,
    required this.averageAccX,
    required this.averageAccY,
    required this.averageAccZ,
  });

  /// Factory method to create baseline metrics from a list of `SessionData`.
  ///
  /// [sessionData]: The list of session data used to compute the averages.
  ///
  /// Returns a new `BaselineMetrics` instance with averages calculated
  /// from the provided session data.
  factory BaselineMetrics.fromSessionData(List<SessionData> sessionData) {
    final int count = sessionData.length;

    final double avgHeartRate =
        sessionData.map((data) => data.heartRate).reduce((a, b) => a + b) /
            count;

    final double avgBodyTemperature = sessionData
            .map((data) => data.bodyTemperature)
            .reduce((a, b) => a + b) /
        count;

    final double avgAccX =
        sessionData.map((data) => data.accX).reduce((a, b) => a + b) / count;

    final double avgAccY =
        sessionData.map((data) => data.accY).reduce((a, b) => a + b) / count;

    final double avgAccZ =
        sessionData.map((data) => data.accZ).reduce((a, b) => a + b) / count;

    return BaselineMetrics(
      averageHeartRate: avgHeartRate,
      averageBodyTemperature: avgBodyTemperature,
      averageAccX: avgAccX,
      averageAccY: avgAccY,
      averageAccZ: avgAccZ,
    );
  }

  /// Dynamically updates the current baseline metrics with new metrics
  /// using a weighted average approach.
  ///
  /// [newMetrics]: The new metrics to incorporate into the current baseline.
  /// [currentWeight]: The weight assigned to the current baseline values
  /// (default is 0.8).
  /// [newWeight]: The weight assigned to the new metrics values (default is 0.2).
  ///
  /// Returns an updated `BaselineMetrics` instance with recalculated averages.
  BaselineMetrics updateWith(BaselineMetrics newMetrics,
      {double currentWeight = 0.8, double newWeight = 0.2}) {
    return BaselineMetrics(
      averageHeartRate: (averageHeartRate * currentWeight) +
          (newMetrics.averageHeartRate * newWeight),
      averageBodyTemperature: (averageBodyTemperature * currentWeight) +
          (newMetrics.averageBodyTemperature * newWeight),
      averageAccX:
          (averageAccX * currentWeight) + (newMetrics.averageAccX * newWeight),
      averageAccY:
          (averageAccY * currentWeight) + (newMetrics.averageAccY * newWeight),
      averageAccZ:
          (averageAccZ * currentWeight) + (newMetrics.averageAccZ * newWeight),
    );
  }
}

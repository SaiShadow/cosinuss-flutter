import 'package:cosinuss/models/data/session_data.dart';

class BaselineMetrics {
  final double averageHeartRate;
  final double averageBodyTemperature;
  final double averageAccX, averageAccY, averageAccZ;

  BaselineMetrics({
    required this.averageHeartRate,
    required this.averageBodyTemperature,
    required this.averageAccX,
    required this.averageAccY,
    required this.averageAccZ,
  });

  /// Calculate baseline metrics from a list of `SessionData`
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

  /// Update baseline metrics dynamically with a weighted average
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

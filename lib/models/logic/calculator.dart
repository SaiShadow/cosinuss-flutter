import 'package:cosinuss/models/data/baseline_metrics.dart';
import 'package:cosinuss/models/data/session_data.dart';

class Calculator {
  double calculateHeartRateDeviation(
      List<SessionData> recentData, BaselineMetrics baselineMetrics) {
    return recentData
            .map((data) =>
                (data.heartRate - baselineMetrics.averageHeartRate).abs())
            .reduce((a, b) => a + b) /
        recentData.length;
  }

  double calculateBodyTemperatureDeviation(
      List<SessionData> recentData, BaselineMetrics baselineMetrics) {
    return recentData
            .map((data) =>
                (data.bodyTemperature - baselineMetrics.averageBodyTemperature)
                    .abs())
            .reduce((a, b) => a + b) /
        recentData.length;
  }

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
}

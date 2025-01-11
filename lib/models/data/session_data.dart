import 'package:cosinuss/models/data/sensor_data.dart';

class SessionData {
  final DateTime timestamp;
  final int heartRate;
  final double bodyTemperature;
  final int accX, accY, accZ;

  SessionData({
    required this.timestamp,
    required this.heartRate,
    required this.bodyTemperature,
    required this.accX,
    required this.accY,
    required this.accZ,
  });

  /// Factory method to create `SessionData` from `SensorData`
  factory SessionData.fromSensorData(DateTime timeNow, SensorData sensorData) {
    return SessionData(
      timestamp: timeNow,
      heartRate: sensorData.rawHeartRate,
      bodyTemperature: sensorData.rawBodyTemperature,
      accX: sensorData.rawAccX,
      accY: sensorData.rawAccY,
      accZ: sensorData.rawAccZ,
    );
  }
}

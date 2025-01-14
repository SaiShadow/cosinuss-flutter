import 'package:cosinuss/models/data/sensor_data.dart';

/// Represents a single session data point collected from the sensor.
/// Contains heart rate, body temperature, and accelerometer data at a specific timestamp.
class SessionData {
  /// The timestamp when the session data was collected.
  final DateTime timestamp;

  /// The heart rate value (in bpm) at the time of collection.
  final int heartRate;

  /// The body temperature value (in °C) at the time of collection.
  final double bodyTemperature;

  /// The accelerometer X,Y,Z-axis value at the time of collection.
  final int accX, accY, accZ;

  /// Creates a new instance of `SessionData`.
  ///
  /// [timestamp]: The time when the data was collected.
  /// [heartRate]: The heart rate value (in bpm).
  /// [bodyTemperature]: The body temperature value (in °C).
  /// [accX]: The accelerometer X-axis value.
  /// [accY]: The accelerometer Y-axis value.
  /// [accZ]: The accelerometer Z-axis value.
  SessionData({
    required this.timestamp,
    required this.heartRate,
    required this.bodyTemperature,
    required this.accX,
    required this.accY,
    required this.accZ,
  });

  /// Factory method to create a `SessionData` object from `SensorData`.
  ///
  /// [timeNow]: The timestamp for the data point.
  /// [sensorData]: The sensor data containing heart rate, body temperature, and accelerometer values.
  ///
  /// Returns a `SessionData` instance with values extracted from `SensorData`.
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

import 'package:cosinuss/models/data/sensor_data.dart';

class FocusCalculator {
  static double calculateFocus(SensorData sensorData) {
    // Example logic: High focus = stable heart rate + stable movement
    int heartRate = sensorData.rawHeartRate;
    int accX = sensorData.rawAccX;
    int accY = sensorData.rawAccY;
    int accZ = sensorData.rawAccZ;

    // Normalize data ranges and compute a basic focus score
    double heartRateScore = (heartRate >= 60 && heartRate <= 100) ? 1.0 : 0.5;
    double movementScore =
        (accX.abs() < 5 && accY.abs() < 5 && accZ.abs() < 5) ? 1.0 : 0.5;

    // Calculate focus score as a weighted average
    return (heartRateScore * 0.6) + (movementScore * 0.4); // Range: 0.0 to 1.0
  }
}

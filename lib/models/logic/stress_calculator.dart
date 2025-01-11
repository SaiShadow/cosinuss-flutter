import 'package:cosinuss/models/data/sensor_data.dart';

class StressCalculator {
  static double calculateStress(SensorData sensorData) {
    // Example logic: High stress = elevated heart rate + high temperature
    int heartRate = sensorData.rawHeartRate;
    double bodyTemperature = sensorData.rawBodyTemperature;

    // Stress score: higher with abnormal heart rate or elevated temperature
    double heartRateScore = (heartRate > 100 || heartRate < 50) ? 1.0 : 0.5;
    double temperatureScore = (bodyTemperature > 37.5) ? 1.0 : 0.5;

    // Calculate stress score as a weighted average
    return (heartRateScore * 0.7) +
        (temperatureScore * 0.3); // Range: 0.0 to 1.0
  }
}

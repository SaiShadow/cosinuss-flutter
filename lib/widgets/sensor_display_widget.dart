import 'package:flutter/material.dart';

class SensorDataWidget extends StatelessWidget {
  final String focusLevel;
  final String stressLevel;
  final String heartRate;
  final String temperature;

  const SensorDataWidget({
    Key? key,
    required this.focusLevel,
    required this.stressLevel,
    required this.heartRate,
    required this.temperature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double gapSize = 20;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        // color: Colors.black.withOpacity(0.1), // Subtle background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildDataSection("Focus", focusLevel, Icons.psychology),
          const SizedBox(height: gapSize),
          _buildDataSection("Stress", stressLevel, Icons.thunderstorm),
          const SizedBox(height: gapSize),
          _buildDataSection("Heart Rate", heartRate, Icons.favorite),
          const SizedBox(height: gapSize),
          _buildDataSection("Temperature", temperature, Icons.thermostat),
        ],
      ),
    );
  }

  Widget _buildDataSection(String title, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          "$title: ",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500, // Semi-bold but not too heavy
            color: Colors.white70, // Soft white to reduce visual weight
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400, // Normal font weight
            color: Colors.white, // Slightly brighter for values
          ),
        ),
      ],
    );
  }
}

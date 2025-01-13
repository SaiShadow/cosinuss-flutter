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
      mainAxisSize: MainAxisSize
          .min, // Ensure the Row content takes up only as much space as needed
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "$title: ",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500, // Semi-bold
                    color: Colors.white70, // Soft white
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400, // Normal
                    color: Colors.white, // Bright white for values
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

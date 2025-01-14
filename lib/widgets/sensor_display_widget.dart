import 'package:flutter/material.dart';

/// A widget that displays sensor data such as focus level, stress level,
/// heart rate, and body temperature in a formatted and visually appealing layout.
class SensorDataWidget extends StatelessWidget {
  /// Focus level as a string.
  final String focusLevel;

  /// Stress level as a string.
  final String stressLevel;

  /// Heart rate as a string.
  final String heartRate;

  /// Body temperature as a string.
  final String temperature;

  /// Constructs a `SensorDataWidget` with the required sensor data.
  ///
  /// Parameters:
  /// - [focusLevel]: Current focus level.
  /// - [stressLevel]: Current stress level.
  /// - [heartRate]: Current heart rate.
  /// - [temperature]: Current body temperature.
  const SensorDataWidget({
    Key? key,
    required this.focusLevel,
    required this.stressLevel,
    required this.heartRate,
    required this.temperature,
  }) : super(key: key);

  /// Builds the widget tree for displaying sensor data.
  ///
  /// Returns a container with a structured display of the focus level, stress level,
  /// heart rate, and body temperature, each with corresponding icons and labels.
  @override
  Widget build(BuildContext context) {
    const double gapSize = 20; // Space between data sections.
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

  /// Helper method to build an individual data section.
  ///
  /// Parameters:
  /// - [title]: Title of the section (e.g., "Focus").
  /// - [value]: The value of the data to be displayed.
  /// - [icon]: An icon representing the data.
  ///
  /// Returns a `Row` widget containing the icon, title, and value.
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

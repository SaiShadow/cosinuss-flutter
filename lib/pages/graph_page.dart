import 'package:cosinuss/models/data/session_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A `GraphPage` widget that displays various graphs for focus, stress, heart rate,
/// and body temperature based on session and sensor data.
///
/// This page uses a tab-based layout to switch between graphs and visualizes the
/// data using the `fl_chart` library.
class GraphPage extends StatelessWidget {
  /// The session data containing timestamp, heart rate, body temperature, and accelerometer values.
  final List<SessionData> sessionData;

  /// A list of focus data containing timestamp-value pairs.
  final List<Map<String, dynamic>> focusData;

  /// A list of stress data containing timestamp-value pairs.
  final List<Map<String, dynamic>> stressData;

  /// Creates a `GraphPage` widget.
  ///
  /// [sessionData] contains session-related data for graphing heart rate and temperature.
  /// [focusData] contains focus scores for graphing.
  /// [stressData] contains stress scores for graphing.
  const GraphPage({
    Key? key,
    required this.sessionData,
    required this.focusData,
    required this.stressData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Four tabs for focus, stress, heart, and temperature graphs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Graphs"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.psychology), text: "Focus"),
              Tab(icon: Icon(Icons.thunderstorm), text: "Stress"),
              Tab(icon: Icon(Icons.favorite), text: "Heart"),
              Tab(icon: Icon(Icons.thermostat), text: "Temp"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGraph(focusData, "Focus Scores"),
            _buildGraph(stressData, "Stress Scores"),
            _buildGraph(
              sessionData
                  .map((data) => {
                        "timestamp":
                            data.timestamp.millisecondsSinceEpoch.toDouble(),
                        "value": data.heartRate.toDouble(),
                      })
                  .toList(),
              "Heart Rate (bpm)",
            ),
            _buildGraph(
              sessionData
                  .map((data) => {
                        "timestamp":
                            data.timestamp.millisecondsSinceEpoch.toDouble(),
                        "value": data.bodyTemperature.toDouble(),
                      })
                  .toList(),
              "Body Temperature (°C)",
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a graph widget for the given data and title.
  ///
  /// [data] is a list of timestamp-value pairs used to plot the graph.
  /// [title] is the title of the graph to be displayed.
  Widget _buildGraph(List<Map<String, dynamic>> data, String title) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          "No data available for $title.\n\n"
          "Please connect your Cosinuss-Earable, and\nstart a Pomodoro Session.",
        ),
      );
    }

    // Filter out invalid data
    final validData = data.where((entry) {
      return entry["timestamp"] != null && entry["value"] != null;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final DateTime timestamp =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
          ),
          gridData: const FlGridData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: validData.map((entry) {
                return FlSpot(
                  (entry["timestamp"] as double) /
                      1000, // Convert timestamp to seconds
                  entry["value"] as double,
                );
              }).toList(),
              isCurved: true,
              belowBarData: BarAreaData(show: true),
              dotData: const FlDotData(show: false),
              gradient:
                  const LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
              barWidth: 4,
            ),
          ],
        ),
      ),
    );
  }
}

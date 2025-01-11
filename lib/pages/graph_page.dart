import 'package:cosinuss/models/data/session_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphPage extends StatelessWidget {
  final List<SessionData> sessionData;
  final List<Map<String, dynamic>> focusData;
  final List<Map<String, dynamic>> stressData;

  const GraphPage({
    Key? key,
    required this.sessionData,
    required this.focusData,
    required this.stressData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Add one more tab for temperature
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Graphs"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.psychology), text: "Focus"), // Sun icon
              Tab(
                  icon: Icon(Icons.self_improvement),
                  text: "Stress"), // Stress icon
              Tab(icon: Icon(Icons.favorite), text: "Heart"), // Heart icon
              Tab(
                  icon: Icon(Icons.thermostat),
                  text: "Temp"), // Thermometer icon
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

  Widget _buildGraph(List<Map<String, dynamic>> data, String title) {
    if (data.isEmpty) {
      return Center(
        child: Text(
            "No data available for $title.\nPlease start a Pomodoro Session."),
      );
    }

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
                      DateTime.fromMillisecondsSinceEpoch(
                          (value * 1000).toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0), // Add spacing
                    child: Text(
                      "${timestamp.hour}:${timestamp.minute}",
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
                    padding: const EdgeInsets.only(right: 8.0), // Add spacing
                    child: Text(
                      value.toString(),
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
              spots: data.map((entry) {
                return FlSpot(entry["timestamp"] / 1000, entry["value"]);
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

import 'package:flutter/material.dart';

class SensorDataCard extends StatelessWidget {
  final String title; // The title of the data (e.g., "Heart Rate")
  final String value; // The actual value (e.g., "72 bpm")

  const SensorDataCard(
      { //
      required this.title, //
      required this.value, //
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        leading: const Icon(
          Icons.insights, // Placeholder icon; can be customized
          color: Colors.blue,
          size: 32,
        ),
      ),
    );
  }
}

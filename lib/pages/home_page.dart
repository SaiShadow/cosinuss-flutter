import 'package:cosinuss/data/sensor_data.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String title;
  final SensorData sensorData;

  const HomePage({Key? key, required this.sensorData, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(children: [
              const Text(
                'Status: ',
              ),
              Text(sensorData.connectionStatus),
            ]),
            Row(children: [
              const Text('Heart Rate: '),
              Text(sensorData.heartRate),
            ]),
            Row(children: [
              const Text('Body Temperature: '),
              Text(sensorData.bodyTemperature),
            ]),
            Row(children: [
              const Text('Accelerometer X: '),
              Text(sensorData.accX),
            ]),
            Row(children: [
              const Text('Accelerometer Y: '),
              Text(sensorData.accY),
            ]),
            Row(children: [
              const Text('Accelerometer Z: '),
              Text(sensorData.accZ),
            ]),
            Row(children: [
              const Text('PPG Raw Red: '),
              Text(sensorData.ppgRed),
            ]),
            Row(children: [
              const Text('PPG Raw Green: '),
              Text(sensorData.ppgGreen),
            ]),
            Row(children: [
              const Text('PPG Ambient: '),
              Text(sensorData.ppgAmbient),
            ]),
            const Row(children: [
              Text(
                  '\nNote: You have to insert the earbud in your  \n ear in order to receive heart rate values.')
            ]),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    '\nNote: Accelerometer and PPG have unknown units. \nThey were reverse engineered. \nUse with caution!',
                    softWrap: true, // Ensures text wraps properly
                    textAlign: TextAlign
                        .start, // Aligns the text to the start of the row
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

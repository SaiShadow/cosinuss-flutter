import 'package:cosinuss/sensor/sensor_data.dart';
import 'package:cosinuss/utils/bluetooth_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SensorData _sensorData = SensorData();
  late final BLEManager _bluetoothManager;

  @override
  void initState() {
    super.initState();

    _bluetoothManager = BLEManager(
        updateConnectionStatus: (status) => setState(() {
              _sensorData.updateConnectionStatus(status);
            }),
        updateHeartRate: (data) => setState(() {
              _sensorData.updateHeartRate(data);
            }),
        updateBodyTemperature: (data) => setState(() {
              _sensorData.updateBodyTemperature(data);
            }),
        updatePPGRaw: (data) => setState(() {
              _sensorData.updatePPGRaw(data);
            }),
        updateAccelerometer: (data) => setState(() {
              _sensorData.updateAccelerometer(data);
            }));
  }

  void _connect() {
    _bluetoothManager.connect();
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
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
                Text(_sensorData.connectionStatus),
              ]),
              Row(children: [
                const Text('Heart Rate: '),
                Text(_sensorData.heartRate),
              ]),
              Row(children: [
                const Text('Body Temperature: '),
                Text(_sensorData.bodyTemperature),
              ]),
              Row(children: [
                const Text('Accelerometer X: '),
                Text(_sensorData.accX),
              ]),
              Row(children: [
                const Text('Accelerometer Y: '),
                Text(_sensorData.accY),
              ]),
              Row(children: [
                const Text('Accelerometer Z: '),
                Text(_sensorData.accZ),
              ]),
              Row(children: [
                const Text('PPG Raw Red: '),
                Text(_sensorData.ppgRed),
              ]),
              Row(children: [
                const Text('PPG Raw Green: '),
                Text(_sensorData.ppgGreen),
              ]),
              Row(children: [
                const Text('PPG Ambient: '),
                Text(_sensorData.ppgAmbient),
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
      ),
      floatingActionButton: Visibility(
        visible: !_sensorData.isConnected,
        child: FloatingActionButton(
          onPressed: _connect,
          tooltip: 'Increment',
          child: const Icon(Icons.bluetooth_searching_sharp),
        ),
      ),
    );
  }
}

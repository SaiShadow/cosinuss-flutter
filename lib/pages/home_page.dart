import 'package:cosinuss/sensor/sensor_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

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
  final SensorData sensorData = SensorData();

  String _connectionStatus = "Disconnected";

  bool _isConnected = false;

  bool earConnectFound = false;

  void _connect() {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    // start scanning
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    // listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) async {
      // do something with scan results
      for (ScanResult r in results) {
        if (r.device.name == "earconnect" && !earConnectFound) {
          earConnectFound =
              true; // avoid multiple connects attempts to same device

          await flutterBlue.stopScan();

          r.device.state.listen((state) {
            // listen for connection state changes
            setState(() {
              _isConnected = state == BluetoothDeviceState.connected;
              _connectionStatus = (_isConnected) ? "Connected" : "Disconnected";
            });
          });

          await r.device.connect();

          var services = await r.device.discoverServices();

          for (var service in services) {
            // iterate over services
            for (var characteristic in service.characteristics) {
              // iterate over characterstics
              switch (characteristic.uuid.toString()) {
                case "0000a001-1212-efde-1523-785feabcd123":
                  print("Starting sampling ...");
                  await characteristic.write([
                    0x32,
                    0x31,
                    0x39,
                    0x32,
                    0x37,
                    0x34,
                    0x31,
                    0x30,
                    0x35,
                    0x39,
                    0x35,
                    0x35,
                    0x30,
                    0x32,
                    0x34,
                    0x35
                  ]);
                  await Future.delayed(const Duration(
                      seconds:
                          2)); // short delay before next bluetooth operation otherwise BLE crashes
                  characteristic.value.listen((rawData) {
                    updateAccelerometer(rawData);
                    updatePPGRaw(rawData);
                  });
                  await characteristic.setNotifyValue(true);
                  await Future.delayed(const Duration(seconds: 2));
                  break;

                case "00002a37-0000-1000-8000-00805f9b34fb":
                  characteristic.value.listen((rawData) {
                    updateHeartRate(rawData);
                  });
                  await characteristic.setNotifyValue(true);
                  await Future.delayed(const Duration(
                      seconds:
                          2)); // short delay before next bluetooth operation otherwise BLE crashes
                  break;

                case "00002a1c-0000-1000-8000-00805f9b34fb":
                  characteristic.value.listen((rawData) {
                    updateBodyTemperature(rawData);
                  });
                  await characteristic.setNotifyValue(true);
                  await Future.delayed(const Duration(
                      seconds:
                          2)); // short delay before next bluetooth operation otherwise BLE crashes
                  break;
              }
            }
          }
        }
      }
    });
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
                Text(_connectionStatus),
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
      ),
      floatingActionButton: Visibility(
        visible: !_isConnected,
        child: FloatingActionButton(
          onPressed: _connect,
          tooltip: 'Increment',
          child: const Icon(Icons.bluetooth_searching_sharp),
        ),
      ),
    );
  }
}

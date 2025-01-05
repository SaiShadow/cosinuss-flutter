import 'package:cosinuss/services/ble_manager.dart';
import 'package:cosinuss/ui/sensor_data_card.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Cosinuss° One - Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BLEManager _bleManager = BLEManager();

  String _connectionStatus = "Disconnected";
  String _heartRate = "- bpm";
  String _bodyTemperature = '- °C';

  String _accX = "-";
  String _accY = "-";
  String _accZ = "-";

  String _ppgGreen = "-";
  String _ppgRed = "-";
  String _ppgAmbient = "-";

  bool _isConnected = false;

  bool earConnectFound = false;

  void updateHeartRate(rawData) {
    Uint8List bytes = Uint8List.fromList(rawData);

    // based on GATT standard
    var bpm = bytes[1];
    if (!((bytes[0] & 0x01) == 0)) {
      bpm = (((bpm >> 8) & 0xFF) | ((bpm << 8) & 0xFF00));
    }

    var bpmLabel = "- bpm";
    if (bpm != 0) {
      bpmLabel = bpm.toString() + " bpm";
    }

    setState(() {
      _heartRate = bpmLabel;
    });
  }

  void updateBodyTemperature(rawData) {
    var flag = rawData[0];

    // based on GATT standard
    double temperature = twosComplimentOfNegativeMantissa(
            ((rawData[3] << 16) | (rawData[2] << 8) | rawData[1]) & 16777215) /
        100.0;
    if ((flag & 1) != 0) {
      temperature = ((98.6 * temperature) - 32.0) *
          (5.0 / 9.0); // convert Fahrenheit to Celsius
    }

    setState(() {
      _bodyTemperature =
          temperature.toString() + " °C"; // todo update body temp
    });
  }

  void updatePPGRaw(rawData) {
    Uint8List bytes = Uint8List.fromList(rawData);

    // corresponds to the raw reading of the PPG sensor from which the heart rate is computed
    //
    // example plot https://e2e.ti.com/cfs-file/__key/communityserver-discussions-components-files/73/Screen-Shot-2019_2D00_01_2D00_24-at-19.30.24.png
    // (image just for illustration purpose, obtained from a different sensor! Sensor value range differs.)

    var ppgRed = bytes[0] |
        bytes[1] << 8 |
        bytes[2] << 16 |
        bytes[3] << 32; // raw green color value of PPG sensor
    var ppgGreen = bytes[4] |
        bytes[5] << 8 |
        bytes[6] << 16 |
        bytes[7] << 32; // raw red color value of PPG sensor

    var ppgGreenAmbient = bytes[8] |
        bytes[9] << 8 |
        bytes[10] << 16 |
        bytes[11] <<
            32; // ambient light sensor (e.g., if sensor is not placed correctly)

    setState(() {
      _ppgGreen = ppgRed.toString() + " (unknown unit)";
      _ppgRed = ppgGreen.toString() + " (unknown unit)";
      _ppgAmbient = ppgGreenAmbient.toString() + " (unknown unit)";
    });
  }

  void updateAccelerometer(rawData) {
    Int8List bytes = Int8List.fromList(rawData);

    // description based on placing the earable into your right ear canal
    int accX = bytes[14];
    int accY = bytes[16];
    int accZ = bytes[18];

    setState(() {
      _accX = accX.toString() + " (unknown unit)";
      _accY = accY.toString() + " (unknown unit)";
      _accZ = accZ.toString() + " (unknown unit)";
    });
  }

  int twosComplimentOfNegativeMantissa(int mantissa) {
    if ((4194304 & mantissa) != 0) {
      return (((mantissa ^ -1) & 16777215) + 1) * -1;
    }

    return mantissa;
  }

  void _connect() {
    _bleManager.startScan((device) async {
      setState(() {
        _connectionStatus = "Connected to ${device.name}";
        _isConnected = true;
      });

      // Keep service and characteristic logic here for now
      var services = await device.discoverServices();
      for (var service in services) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SensorDataCard(
                  title: "Connection Status", value: _connectionStatus),
              SensorDataCard(title: "Heart Rate", value: _heartRate),
              SensorDataCard(
                  title: "Body Temperature", value: _bodyTemperature),
              SensorDataCard(title: "Accelerometer X", value: _accX),
              SensorDataCard(title: "Accelerometer Y", value: _accY),
              SensorDataCard(title: "Accelerometer Z", value: _accZ),
              const SizedBox(height: 20), // Add some spacing
              ElevatedButton(
                onPressed: _isConnected ? _disconnect : null,
                child: const Text("Disconnect"),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isConnected ? _disconnect : _connect,
        backgroundColor: _isConnected ? Colors.red : Colors.green,
        child: Icon(_isConnected
            ? Icons.bluetooth_disabled
            : Icons.bluetooth_searching),
      ),
    );
  }

  void _disconnect() async {
    await _bleManager.disconnect();
    setState(() {
      _connectionStatus = "Disconnected";
      _isConnected = false;
      earConnectFound = false;
    });
  }
}

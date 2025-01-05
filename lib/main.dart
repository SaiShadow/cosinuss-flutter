import 'package:cosinuss/sensor/sensor_graph.dart';
import 'package:cosinuss/services/ble_manager.dart';
import 'package:cosinuss/sensor/sensor_data_card.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosinuss° One - Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Cosinuss° One - Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BLEManager _bleManager = BLEManager();

  String _connectionStatus = "Disconnected";
  String _heartRate = "- bpm";
  String _bodyTemperature = "- °C";

  String _accX = "-";
  String _accY = "-";
  String _accZ = "-";

  bool _isConnected = false;
  bool _isRecording = false;

  // Real-time data
  final List<double> _heartRateData = [];
  final List<double> _bodyTemperatureData = [];
  final List<double> _accXData = [];
  final List<double> _accYData = [];
  final List<double> _accZData = [];

  // Session data
  final List<double> _sessionHeartRateData = [];
  final List<double> _sessionBodyTemperatureData = [];
  final List<double> _sessionAccXData = [];
  final List<double> _sessionAccYData = [];
  final List<double> _sessionAccZData = [];

  void updateHeartRate(rawData) {
    Uint8List bytes = Uint8List.fromList(rawData);

    var bpm = bytes[1];
    if (!((bytes[0] & 0x01) == 0)) {
      bpm = (((bpm >> 8) & 0xFF) | ((bpm << 8) & 0xFF00));
    }

    setState(() {
      _heartRate = bpm != 0 ? "$bpm bpm" : "- bpm";

      _heartRateData.add(bpm.toDouble());
      if (_heartRateData.length > 50) _heartRateData.removeAt(0);

      if (_isRecording) _sessionHeartRateData.add(bpm.toDouble());
    });
  }

  void updateBodyTemperature(rawData) {
    var flag = rawData[0];
    double temperature = twosComplimentOfNegativeMantissa(
            ((rawData[3] << 16) | (rawData[2] << 8) | rawData[1]) & 16777215) /
        100.0;
    if ((flag & 1) != 0) {
      temperature = ((98.6 * temperature) - 32.0) *
          (5.0 / 9.0); // convert Fahrenheit to Celsius
    }

    setState(() {
      _bodyTemperature = "$temperature °C";

      _bodyTemperatureData.add(temperature);
      if (_bodyTemperatureData.length > 50) _bodyTemperatureData.removeAt(0);

      if (_isRecording) _sessionBodyTemperatureData.add(temperature);
    });
  }

  void updateAccelerometer(rawData) {
    Int8List bytes = Int8List.fromList(rawData);

    int accX = bytes[14];
    int accY = bytes[16];
    int accZ = bytes[18];

    setState(() {
      _accX = "$accX";
      _accY = "$accY";
      _accZ = "$accZ";

      _accXData.add(accX.toDouble());
      _accYData.add(accY.toDouble());
      _accZData.add(accZ.toDouble());

      if (_accXData.length > 50) _accXData.removeAt(0);
      if (_accYData.length > 50) _accYData.removeAt(0);
      if (_accZData.length > 50) _accZData.removeAt(0);

      if (_isRecording) {
        _sessionAccXData.add(accX.toDouble());
        _sessionAccYData.add(accY.toDouble());
        _sessionAccZData.add(accZ.toDouble());
      }
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SensorDataCard(
                    title: "Connection Status", value: _connectionStatus),
                SensorDataCard(title: "Heart Rate", value: _heartRate),
                SensorDataCard(
                    title: "Body Temperature", value: _bodyTemperature),
                SensorDataCard(title: "Accelerometer X", value: _accX),
                SensorDataCard(title: "Accelerometer Y", value: _accY),
                SensorDataCard(title: "Accelerometer Z", value: _accZ),
                const SizedBox(height: 16),
                SensorGraph(data: _heartRateData, title: "Heart Rate"),
                SensorGraph(
                    data: _bodyTemperatureData, title: "Body Temperature"),
                SensorGraph(data: _accXData, title: "Accelerometer X"),
                SensorGraph(data: _accYData, title: "Accelerometer Y"),
                SensorGraph(data: _accZData, title: "Accelerometer Z"),
              ],
            ),
          ),
        ],
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
    });
  }
}

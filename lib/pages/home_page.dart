import 'package:cosinuss/models/data/sensor_data.dart';
import 'package:cosinuss/utils/bluetooth_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String title;
  final SensorData sensorData;
  final BLEManager bluetoothManager;

  const HomePage({
    Key? key,
    required this.sensorData,
    required this.title,
    required this.bluetoothManager,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Local state indicating if connect button has been pressed.
  bool _isConnecting = false;

  void _connect() {
    setState(() {
      _isConnecting = true;
    });

    widget.bluetoothManager.connect();
  }

  Widget _buildSensorStatusRow(String label, String value,
      [String? status, IconData? icon]) {
    bool isValid = value != widget.sensorData.defaultSensorValue &&
        widget.sensorData.isConnected;

    bool isLoading = _isConnecting && !isValid;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.black, size: 20),
                const SizedBox(width: 8), // Add spacing between icon and text
              ],
              Text(
                label,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Row(
            children: [
              if (status != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.sensorData.isConnected
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              if (isLoading)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              else
                Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  color: isValid ? Colors.green : Colors.red,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color getConsistentColor() {
    return Colors.lightBlue;
  }

  @override
  Widget build(BuildContext context) {
    Color consistentColor = getConsistentColor();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home Page",
        ),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Device Status",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: consistentColor,
                ),
              ),
              _buildSensorStatusRow(
                "Connection Status",
                widget.sensorData.connectionStatus,
                widget.sensorData.connectionStatus,
                Icons.bluetooth,
              ),
              const Divider(),
              Text(
                "Vital Signs",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: consistentColor,
                ),
              ),
              _buildSensorStatusRow(
                "Heart Rate",
                widget.sensorData.heartRate,
                null,
                Icons.favorite,
              ),
              _buildSensorStatusRow(
                "Body Temperature",
                widget.sensorData.bodyTemperature,
                null,
                Icons.thermostat,
              ),
              const Divider(),
              Text(
                "Motion Data",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: consistentColor,
                ),
              ),
              _buildSensorStatusRow(
                "Accelerometer X",
                widget.sensorData.accX,
                null,
                Icons.directions_run_sharp,
              ),
              _buildSensorStatusRow(
                "Accelerometer Y",
                widget.sensorData.accY,
                null,
                Icons.directions_run_sharp,
              ),
              _buildSensorStatusRow(
                "Accelerometer Z",
                widget.sensorData.accZ,
                null,
                Icons.directions_run_sharp,
              ),

              /// PPG not needed ///
              // const Divider(),
              // Text(
              //   "PPG Data",
              //   style: TextStyle(
              //     fontSize: 19,
              //     fontWeight: FontWeight.bold,
              //     color: consistentColor,
              //   ),
              // ),
              // _buildSensorStatusRow(
              //   "PPG Raw Red",
              //   widget.sensorData.ppgRed,
              // ),
              // _buildSensorStatusRow(
              //   "PPG Raw Green",
              //   widget.sensorData.ppgGreen,
              // ),
              // _buildSensorStatusRow(
              //   "PPG Ambient",
              //   widget.sensorData.ppgAmbient,
              // ),
              const SizedBox(height: 20),
              const ExpansionTile(
                title: Text(
                  "Notes & Instructions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      infoText,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          )),
      floatingActionButton: Visibility(
        visible: !_isConnecting,
        child: FloatingActionButton(
          onPressed: _connect,
          tooltip: 'Connect to Device',
          backgroundColor: Colors.green,
          child: const Icon(Icons.bluetooth_searching_sharp),
        ),
      ),
    );
  }

  static const String infoText =
      "- Insert the earbud in your ear to receive heart rate values.\n"
      "- It takes about 3-5min for the app to calculate your own personal baseline metrics for a unique focus and stress calculation based on your personal qualities.\n"
      "- So please be patient for the first 5min of the Pomodoro Session start";
}

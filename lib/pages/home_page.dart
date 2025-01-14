import 'package:cosinuss/models/data/sensor_data.dart';
import 'package:cosinuss/utils/bluetooth_service.dart';
import 'package:flutter/material.dart';

/// A `HomePage` widget that provides the main interface for displaying
/// the status of the connected Cosinuss device, including vital signs,
/// motion data, and connection status.
class HomePage extends StatefulWidget {
  /// The title of the home page.
  final String title;

  /// An instance of `SensorData` that provides real-time sensor data
  /// from the connected Cosinuss device.
  final SensorData sensorData;

  /// An instance of `BLEManager` responsible for managing Bluetooth
  /// connectivity and device interactions.
  final BLEManager bluetoothManager;

  /// Creates a `HomePage` widget.
  ///
  /// [title] represents the page title.
  /// [sensorData] provides access to sensor data.
  /// [bluetoothManager] manages Bluetooth connections and services.
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
  /// Local state indicating whether the connection process is active.
  bool _isConnecting = false;

  /// Initiates the connection process to the Cosinuss device.
  void _connect() {
    setState(() {
      _isConnecting = true;
    });

    widget.bluetoothManager.connect();
  }

  /// Builds a sensor status row to display connection, vital sign, or motion data.
  ///
  /// [label] represents the label of the data being displayed.
  /// [value] is the value of the sensor data.
  /// [status] (optional) is the current status of the sensor or connection.
  /// [icon] (optional) is the icon to be displayed next to the label.
  ///
  /// Returns a styled `Row` widget containing the sensor information.
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

  /// Retrieves a consistent color used throughout the page for styling.
  ///
  /// Returns a light blue color.
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

  /// Instructions displayed in the "Notes & Instructions" section.
  static const String infoText =
      "- Insert the earbud in your ear to receive heart rate values.\n"
      "- Ensure the device is properly connected via Bluetooth before starting a Pomodoro Session.\n"
      "- It takes about 3-5 minutes for the app to calculate your own personal baseline metrics. These metrics are used to calculate unique focus and stress levels tailored to your personal qualities.\n"
      "- Be patient during the initial baseline calibration period.\n"
      "- Focus levels are calculated based on stable heart rate, minimal movement, and consistent body temperature.\n"
      "- Stress levels are calculated based on deviations in heart rate, body temperature, and excessive movement.\n"
      "- During a Pomodoro session:\n"
      "   - The app uses colors and sounds to alert you about transitions between work and break periods.\n"
      "   - Green indicates work periods, while blue indicates break periods.\n"
      "   - A sound notification will be played at the end of each session to indicate the transition.\n"
      "- You can view your session's focus and stress metrics in the Graphs tab, which provides detailed visualizations.\n"
      "- Make sure to take regular breaks to optimize productivity and reduce stress.\n";
}

import 'package:cosinuss/models/data/sensor_data.dart';
import 'package:cosinuss/models/data/session_data.dart';
import 'package:cosinuss/pages/home_page.dart';
import 'package:cosinuss/pages/pomodoro_timer_page.dart';
import 'package:cosinuss/pages/graph_page.dart';
import 'package:cosinuss/utils/bluetooth_service.dart';
import 'package:flutter/material.dart';

/// The `MainPage` widget serves as the primary entry point for the application,
/// providing navigation between the Home, Pomodoro Timer, and Graph pages.
class MainPage extends StatefulWidget {
  /// The title displayed in the AppBar.
  final String title;

  const MainPage({Key? key, required this.title}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final SensorData _sensorData = SensorData();
  late final BLEManager _bluetoothManager;
  int _currentPageIndex = 0;

  /// The current color of the Pomodoro Timer Page's navigation bar.
  Color _pomodoroColor = Colors.deepOrange;

  // Shared data for the GraphPage
  List<SessionData> _sessionData = [];
  List<Map<String, dynamic>> _focusData = [];
  List<Map<String, dynamic>> _stressData = [];

  /// Updates the navigation bar color dynamically based on the Pomodoro Timer Page's state.
  void _updateNavBarColor(Color newColor) {
    setState(() {
      _pomodoroColor = newColor;
    });
  }

  @override
  void initState() {
    super.initState();
    _bluetoothManager = _initializeBluetoothManager();
  }

  /// Updates the session data shared with the Graph Page.
  void _updateSessionData(List<SessionData> sessionData) {
    setState(() {
      _sessionData = sessionData;
    });
  }

  /// Updates the focus data shared with the Graph Page.
  void _updateFocusData(List<Map<String, dynamic>> focusData) {
    setState(() {
      _focusData = focusData;
    });
  }

  /// Updates the stress data shared with the Graph Page.
  void _updateStressData(List<Map<String, dynamic>> stressData) {
    setState(() {
      _stressData = stressData;
    });
  }

  /// Initializes the Bluetooth Manager with callbacks for updating sensor data.
  BLEManager _initializeBluetoothManager() {
    return BLEManager(
      updateConnectionStatus: _onConnectionStatusUpdated,
      updateHeartRate: _onHeartRateUpdated,
      updateBodyTemperature: _onBodyTemperatureUpdated,
      updatePPGRaw: _onPPGDataUpdated,
      updateAccelerometer: _onAccelerometerUpdated,
    );
  }

  /// Updates the connection status in the `SensorData` model.
  void _onConnectionStatusUpdated(bool status) {
    setState(() {
      _sensorData.updateConnectionStatus(status);
    });
  }

  /// Updates the heart rate in the `SensorData` model.
  void _onHeartRateUpdated(dynamic data) {
    setState(() {
      _sensorData.updateHeartRate(data);
    });
  }

  /// Updates the body temperature in the `SensorData` model.
  void _onBodyTemperatureUpdated(dynamic data) {
    setState(() {
      _sensorData.updateBodyTemperature(data);
    });
  }

  /// Updates the PPG raw data in the `SensorData` model.
  void _onPPGDataUpdated(dynamic data) {
    setState(() {
      _sensorData.updatePPGRaw(data);
    });
  }

  /// Updates the accelerometer data in the `SensorData` model.
  void _onAccelerometerUpdated(dynamic data) {
    setState(() {
      _sensorData.updateAccelerometer(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show the title only when the home page is selected.
      // Conditionally include the AppBar only for the home page.
      appBar: _currentPageIndex == 0 // Show the title only for the home page
          ? AppBar(
              title: Text(widget.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 29)),
            )
          : null, // No AppBar for other pages
      body: IndexedStack(
        index: _currentPageIndex,
        children: [
          HomePage(
            title: widget.title,
            sensorData: _sensorData,
            bluetoothManager: _bluetoothManager,
          ),
          PomodoroTimerPage(
            sensorData: _sensorData,
            onSessionDataUpdate: _updateSessionData,
            onFocusDataUpdate: _updateFocusData,
            onStressDataUpdate: _updateStressData,
            onUpdateNavBarColor: _updateNavBarColor,
          ),
          GraphPage(
            sessionData: _sessionData,
            focusData: _focusData,
            stressData: _stressData,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
        backgroundColor: _currentPageIndex == 1
            ? _pomodoroColor // Use dynamic Pomodoro color for Pomodoro Timer Page
            : null, // Default color for other pages
        fixedColor: _currentPageIndex == 1
            ? Colors.white // Use dynamic Pomodoro color for Pomodoro Timer Page
            : null,
        unselectedItemColor:
            _pomodoroColor == Colors.black ? Colors.blueGrey : null,
        onTap: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Pomodoro Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_sharp),
            label: 'Graphs',
          ),
        ],
      ),
    );
  }
}

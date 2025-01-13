import 'package:cosinuss/models/data/sensor_data.dart';
import 'package:cosinuss/models/data/session_data.dart';
import 'package:cosinuss/pages/home_page.dart';
import 'package:cosinuss/pages/pomodoro_timer_page.dart';
import 'package:cosinuss/pages/graph_page.dart';
import 'package:cosinuss/utils/bluetooth_service.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final SensorData _sensorData = SensorData();
  late final BLEManager _bluetoothManager;
  int _currentPageIndex = 0;

  Color _pomodoroColor = Colors.deepOrange;

  // Shared data for the GraphPage
  List<SessionData> _sessionData = [];
  List<Map<String, dynamic>> _focusData = [];
  List<Map<String, dynamic>> _stressData = [];

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

  void _updateSessionData(List<SessionData> sessionData) {
    setState(() {
      _sessionData = sessionData;
    });
  }

  void _updateFocusData(List<Map<String, dynamic>> focusData) {
    setState(() {
      _focusData = focusData;
    });
  }

  void _updateStressData(List<Map<String, dynamic>> stressData) {
    setState(() {
      _stressData = stressData;
    });
  }

  BLEManager _initializeBluetoothManager() {
    return BLEManager(
      updateConnectionStatus: _onConnectionStatusUpdated,
      updateHeartRate: _onHeartRateUpdated,
      updateBodyTemperature: _onBodyTemperatureUpdated,
      updatePPGRaw: _onPPGDataUpdated,
      updateAccelerometer: _onAccelerometerUpdated,
    );
  }

  void _onConnectionStatusUpdated(bool status) {
    setState(() {
      _sensorData.updateConnectionStatus(status);
    });
  }

  void _onHeartRateUpdated(dynamic data) {
    setState(() {
      _sensorData.updateHeartRate(data);
    });
  }

  void _onBodyTemperatureUpdated(dynamic data) {
    setState(() {
      _sensorData.updateBodyTemperature(data);
    });
  }

  void _onPPGDataUpdated(dynamic data) {
    setState(() {
      _sensorData.updatePPGRaw(data);
    });
  }

  void _onAccelerometerUpdated(dynamic data) {
    setState(() {
      _sensorData.updateAccelerometer(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // Show the title only when the home page is selected.
      // Conditionally include the AppBar only for the home page.
      appBar: _currentPageIndex == 0
          ? AppBar(
              title: Text(widget.title,
                  style: const TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 29)), // Show the title only for the home page
            )
          : null, // No AppBar for other pagesx
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

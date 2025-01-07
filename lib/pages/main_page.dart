import 'package:cosinuss/pages/home_page.dart';
import 'package:cosinuss/pages/pomodoro_timer_page.dart';
import 'package:cosinuss/pages/stopwatch_page.dart';
import 'package:cosinuss/data/sensor_data.dart';
import 'package:cosinuss/utils/bluetooth_service.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final SensorData _sensorData = SensorData();
  late final BLEManager _bluetoothManager;
  int _currentPageIndex = 0;

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
      body: IndexedStack(
        index: _currentPageIndex,
        children: [
          HomePage(title: 'Cosinuss° One - Demo', sensorData: _sensorData),
          PomodoroTimerPage(
            sensorData: _sensorData,
          ),
          StopwatchPage(
            sensorData: _sensorData,
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: !_sensorData.isConnected &&
            _currentPageIndex == 0, // Button is only visible on the home tab.,
        child: FloatingActionButton(
          onPressed: _connect,
          tooltip: 'Increment',
          child: const Icon(Icons.bluetooth_searching_sharp),
        ),
      ),
      // Inside the Scaffold widget, add this:
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPageIndex,
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
            icon: Icon(Icons.av_timer),
            // icon: Icon(Icons.timelapse),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Stopwatch',
          ),
        ],
      ),
    );
  }
}

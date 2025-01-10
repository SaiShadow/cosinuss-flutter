import 'package:cosinuss/models/data/sensor_data.dart';
import 'package:cosinuss/models/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PomodoroTimerPage extends StatefulWidget {
  final SensorData sensorData;

  const PomodoroTimerPage({Key? key, required this.sensorData})
      : super(key: key);

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  static const int _pomodoroTimerAmount = 25;
  static const int _shortBreakAmount = 5;
  static const String _workSessionLabel = 'Work Session';
  static const String _breakSessionLabel = 'Break Time';
  static const String _title = 'Pomodoro Timer';
  static const String _timerLabel = 'Remaining Time';
  static const String _startButtonLabel = 'Start';
  static const String _stopButtonLabel = 'Stop';

  late Session _currentSession;

  bool _isRunning = false;
  late Duration _remainingTime;
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();

    _currentSession = Session.work;
    _remainingTime = const Duration(minutes: _pomodoroTimerAmount);
    _stopwatch = Stopwatch();

    _ticker = Ticker((Duration elapsed) {
      if (_stopwatch.isRunning) {
        setState(() {
          _remainingTime = const Duration(minutes: _pomodoroTimerAmount) -
              _stopwatch.elapsed;
          if (_remainingTime <= Duration.zero) {
            _completeTimer();
          }
        });
      }
    });
  }

  void _stopTimer() {
    _stopwatch.stop();
    _ticker.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _startTimer() {
    _stopwatch.start();
    _ticker.start();
    setState(() {
      _isRunning = true;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _stopwatch.stop();
      _stopwatch.reset();
      _remainingTime = const Duration(minutes: _pomodoroTimerAmount);
      _isRunning = false;
    });
  }

  void _completeTimer() {
    _stopTimer();
    setState(() {
      if (_currentSession == Session.work) {
        _currentSession = Session.shortBreak;
        _remainingTime = const Duration(minutes: _shortBreakAmount);
      } else {
        _currentSession = Session.work;
        _remainingTime = const Duration(minutes: _pomodoroTimerAmount);
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose(); // Clean up the Ticker
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Color _getBackgroundColor() {
    if (_isRunning) {
      return Colors.black; // Dark mode when running
    }
    return _currentSession == Session.work ? Colors.red : Colors.blue;
  }

  Widget _buildSensorData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Heart Rate: ${widget.sensorData.heartRate}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          'Temperature: ${widget.sensorData.bodyTemperature}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          'Accelerometer: X: ${widget.sensorData.accX}, Y: ${widget.sensorData.accY}, Z: ${widget.sensorData.accZ}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  String _getTimerLabel() {
    return _currentSession == Session.work
        ? _workSessionLabel
        : _breakSessionLabel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
      ),
      body: Column(
        children: [
          // Stopwatch Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Timer Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        _timerLabel,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatDuration(_remainingTime),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Start/Stop and Reset Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_isRunning) {
                          _stopTimer();
                        } else {
                          _startTimer();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRunning ? Colors.red : Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                      ),
                      child: Text(
                        _isRunning ? _stopButtonLabel : _startButtonLabel,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _resetTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:cosinuss/models/data/sensor_data.dart';
import 'package:cosinuss/models/pomodoro_session_type.dart';
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
  static const String _startButtonLabel = 'Start';
  static const String _stopButtonLabel = 'Pause';
  static const String _skipButtonLabel = 'Skip';

  late Session _currentSession;

  bool _isRunning = false;
  late Duration _remainingTime;
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;
  late int _sessionDuration;

  @override
  void initState() {
    super.initState();

    _currentSession = Session.work;
    _sessionDuration = _getSessionDuration();
    _remainingTime = Duration(minutes: _sessionDuration);
    _stopwatch = Stopwatch();

    _ticker = Ticker((Duration elapsed) {
      if (_stopwatch.isRunning) {
        setState(() {
          _remainingTime =
              Duration(minutes: _sessionDuration) - _stopwatch.elapsed;

          if (_remainingTime <= Duration.zero) {
            _completeTimer();
          }
        });
      }
    });
  }

  int _getSessionDuration() {
    return _currentSession == Session.work
        ? _pomodoroTimerAmount
        : _shortBreakAmount;
  }

  void _startTimer() {
    setState(() {
      _stopwatch.start();
      _ticker.start();
      _isRunning = true;
    });
  }

  void _stopTimer() {
    setState(() {
      _stopwatch.stop();
      _ticker.stop();
      _isRunning = false;
    });
  }

  void _skipToNextSession() {
    _stopTimer();
    setState(() {
      _stopwatch.reset();

      // Switch sessions and update the session duration
      if (_currentSession == Session.work) {
        _currentSession = Session.shortBreak;
      } else {
        _currentSession = Session.work;
      }
      _sessionDuration = _getSessionDuration(); // Update session duration
      _remainingTime =
          Duration(minutes: _sessionDuration); // Reset remaining time
    });
  }

  void _completeTimer() {
    _skipToNextSession();
  }

  // void _resetTimer() {
  //   _stopTimer();
  //   setState(() {
  //     _stopwatch.stop();
  //     _stopwatch.reset();
  //     _remainingTime = const Duration(minutes: _pomodoroTimerAmount);
  //     _isRunning = false;
  //   });
  // }

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

  Color _getPageBackgroundColor() {
    if (_isRunning) {
      return _getRunningBackgroundColor(); // Dark mode when running
    }
    return _currentSession == Session.work ? Colors.deepOrange : Colors.blue;
  }

  Color _getRunningBackgroundColor() {
    return Colors.black; // Dark mode when running
  }

  Color _getTimerBackgroundColor() {
    if (_isRunning) {
      return _getRunningBackgroundColor(); // Dark mode when running
    }

    return _currentSession == Session.work
        ? Colors.deepOrange.shade400
        : Colors.lightBlue;
  }

  Widget _buildSensorData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Heart Rate: ${widget.sensorData.heartRate}\n',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          'Temperature: ${widget.sensorData.bodyTemperature}\n',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          'Accelerometer: \n X: ${widget.sensorData.accX} \nY: ${widget.sensorData.accY}\nZ: ${widget.sensorData.accZ}',
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
        // Only show when not running
        title: _isRunning
            ? null
            : const Text(
                _title,
                style: TextStyle(color: Colors.white),
              ),
        backgroundColor: _getPageBackgroundColor(),
      ),
      body: Container(
        color: _getPageBackgroundColor(),
        child: Column(
          children: [
            // Timer Section
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
                      color: _getTimerBackgroundColor(),
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
                        Text(
                          _getTimerLabel(),
                          style: TextStyle(
                            fontSize: 20,
                            color:
                                Colors.white.withOpacity(0.8), // Adjust opacity
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatDuration(_remainingTime),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Buttons
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
                          backgroundColor:
                              _isRunning ? Colors.red : Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                        ),
                        child: Text(
                          _isRunning ? _stopButtonLabel : _startButtonLabel,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _skipToNextSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                        ),
                        child: const Text(
                          _skipButtonLabel,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Sensor Data Section
            _buildSensorData(),
          ],
        ),
      ),
    );
  }
}

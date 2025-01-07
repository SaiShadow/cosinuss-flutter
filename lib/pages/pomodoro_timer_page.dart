import 'package:cosinuss/data/sensor_data.dart';
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
  static const int pomodoroTimerAmount = 25;

  // TODO: Add short and long break amounts into calculation
  static const int shortBreakAmount = 5;
  static const int longBreakAmount = 15;

  bool _isRunning = false;

  late Duration _remainingTime;
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;
  @override
  void initState() {
    super.initState();

    _remainingTime = const Duration(minutes: pomodoroTimerAmount);
    _stopwatch = Stopwatch();

    _ticker = Ticker((Duration elapsed) {
      if (_stopwatch.isRunning) {
        setState(() {
          _remainingTime =
              const Duration(minutes: pomodoroTimerAmount) - elapsed;
        });
      }
      if (_remainingTime <= Duration.zero) {
        _stopwatch.stop();
        _ticker.stop();
        setState(() {
          _isRunning = false;
        });
        // You can add a notification or alert here.
      }
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      // Stop the timer
      _stopwatch.stop();
      _ticker.stop();
      setState(() {
        _isRunning = false;
      });
    } else {
      // Start the timer
      _stopwatch.start();
      _ticker.start();
      setState(() {
        _isRunning = true;
      });
    }
  }

  void _resetTimer() {
    setState(() {
      _stopwatch.stop();
      _stopwatch.reset();
      _remainingTime = const Duration(minutes: pomodoroTimerAmount);
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
      ),
      body: Center(
        child: Padding(
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
                      'Remaining Time',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatDuration(_remainingTime),
                      style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
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
                    onPressed: _toggleTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRunning ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                    ),
                    child: Text(
                      _isRunning ? 'Stop' : 'Start',
                      style: const TextStyle(fontSize: 18),
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
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

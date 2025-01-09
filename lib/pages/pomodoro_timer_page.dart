import 'package:cosinuss/data/sensor_data.dart';
import 'package:cosinuss/pages/task_page.dart';
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
  static const int shortBreakAmount = 5;
  // static const int longBreakAmount = 15;

  bool _isRunning = false;
  late Duration _remainingTime;
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;

  // Selected task name to display
  String? selectedTaskName;

  // Progress value for the progress bar
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _remainingTime = const Duration(minutes: pomodoroTimerAmount);
    _stopwatch = Stopwatch();

    _ticker = Ticker((Duration elapsed) {
      if (_stopwatch.isRunning) {
        setState(() {
          _remainingTime =
              const Duration(minutes: pomodoroTimerAmount) - _stopwatch.elapsed;
          _progress =
              1 - (_remainingTime.inSeconds / (pomodoroTimerAmount * 60));

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
    if (selectedTaskName == null) {
      // Prompt user to select a task
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a task before starting the timer.'),
        ),
      );
      return;
    }
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
      _remainingTime = const Duration(minutes: pomodoroTimerAmount);
      _isRunning = false;
    });
  }

  void _completeTimer() {
    _stopwatch.stop();
    _ticker.stop();
    setState(() {
      _remainingTime = Duration.zero;
      _isRunning = false;
    });
    // Add any completion logic here, like showing a notification or moving to a break.
    // Example:
    // _startBreak(shortBreakAmount); // Placeholder for break logic
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void setSelectedTask(String? taskName) {
    setState(() {
      selectedTaskName = taskName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
      ),
      body: Stack(
        children: [
          // Main UI (Task List and Timer)
          Visibility(
            visible: !_isRunning, // Only visible when the timer is not running
            child: Column(
              children: [
                // Timer Section (Unchanged)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Timer Box (Unchanged)
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
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
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

                      // Buttons (Unchanged)
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
                              _isRunning ? 'Stop' : 'Start',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.white),
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
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Task Page
                Expanded(
                  child: TaskPage(
                    onSelectTask: setSelectedTask,
                  ),
                ),
              ],
            ),
          ),

          // Darkened Overlay when Timer is Running
          if (_isRunning)
            Container(
              color: Colors.black.withOpacity(0.9), // Darkened background
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Task Progress Bar
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[800],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  ),
                  const SizedBox(height: 40),

                  // Selected Task Name
                  Text(
                    selectedTaskName ?? 'No Task Selected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Timer Display
                  Text(
                    _formatDuration(_remainingTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Stop Button
                  ElevatedButton(
                    onPressed: _stopTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                    ),
                    child: const Text(
                      'Stop',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

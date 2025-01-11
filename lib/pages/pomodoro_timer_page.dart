import 'dart:async';

import 'package:cosinuss/models/data/baseline_metrics.dart';
import 'package:cosinuss/models/data/sensor_data.dart';
import 'package:cosinuss/models/data/session_data.dart';
import 'package:cosinuss/models/logic/focus_calculator.dart';
import 'package:cosinuss/models/logic/stress_calculator.dart';
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

  // Times
  static const int periodicFocusAndStressCalculationTime = 60;
  static const int _breakExtensionTime = 2; // 2min
  static const int _focusExtensionTime = 5; // 5min
  static const int _focusReductionTime = 5; // 5min

  static const double veryHighValue = 0.9;
  static const double highValue = 0.7;
  static const double mediumValue = 0.4;

  String _currentFocusLevel = "Unknown";
  String _currentStressLevel = "Unknown";

  late Session _currentSession;

  bool _isRunning = false;
  late Duration _remainingTime;
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;
  late int _sessionDuration;

// Stores all sensor data for the session
  final List<SessionData> _sessionData = [];
  // Focus values with timestamps
  final List<Map<String, dynamic>> _focusData = [];
  // Stress values with timestamps
  final List<Map<String, dynamic>> _stressData = [];

  // Store user's average baseline values
  static const int baselineCalculationTime =
      180; // 3min, but could increase to 5min if needed
  BaselineMetrics? _baselineMetrics;
  bool _isBaselineSet = false;

  // Instance-based calculators
  final StressCalculator _stressCalculator = StressCalculator();
  final FocusCalculator _focusCalculator = FocusCalculator();

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

  // Append current sensor readings to _sessionData
  void _collectSensorData() {
    _sessionData
        .add(SessionData.fromSensorData(DateTime.now(), widget.sensorData));
  }

  void _calculateFocusAndStress() {
    if (_baselineMetrics == null || !_isBaselineSet || _sessionData.isEmpty) {
      debugPrint("Baseline not set or insufficient data for calculations.");
      return;
    }

    // Get the last 1 minute of session data
    final cutoffTime = DateTime.now().subtract(
        const Duration(seconds: periodicFocusAndStressCalculationTime));
    final recentData = _sessionData
        .where((data) => data.timestamp.isAfter(cutoffTime))
        .toList();

    if (recentData.isNotEmpty) {
      // Calculate focus and stress
      final double focusScore =
          _focusCalculator.calculateFocus(recentData, _baselineMetrics!);
      final double stressScore =
          _stressCalculator.calculateStress(recentData, _baselineMetrics!);

      // Save focus and stress values with timestamps
      saveFocusAndStressValues(focusScore, stressScore);

      // Log the values for debugging
      print("Focus Score: $focusScore, Stress Score: $stressScore");

      // Adjust session dynamically based on scores
      _adjustSessionDurations(focusScore, stressScore);
    }
  }

  void saveFocusAndStressValues(double focusScore, double stressScore) {
    // Save focus and stress values with timestamps
    _focusData.add({
      "timestamp": DateTime.now(),
      "focusScore": focusScore,
    });
    _stressData.add({
      "timestamp": DateTime.now(),
      "stressScore": stressScore,
    });

    // Update UI with the latest levels
    setState(() {
      _currentFocusLevel = _getFocusLevel(focusScore);
      _currentStressLevel = _getStressLevel(stressScore);
      // debugPrint(
      print(
          "UI Updated: Focus Level=$_currentFocusLevel, Stress Level=$_currentStressLevel");
    });
  }

  String _getFocusLevel(double focusScore) {
    if (focusScore >= veryHighValue) {
      return "Very High";
    } else if (focusScore >= highValue) {
      return "High";
    } else if (focusScore >= mediumValue) {
      return "Moderate";
    } else {
      return "Low";
    }
  }

  String _getStressLevel(double stressScore) {
    if (stressScore >= veryHighValue) {
      return "Very High";
    } else if (stressScore >= highValue) {
      return "High";
    } else if (stressScore >= mediumValue) {
      return "Moderate";
    } else {
      return "Low";
    }
  }

  void _adjustSessionDurations(double focusScore, double stressScore) {
    if (_currentSession == Session.work) {
      if (stressScore > veryHighValue) {
        // Very high stress: Reduce work time dynamically
        _reduceWorkTime();
      } else if (_remainingTime.inMinutes <= 1 && focusScore > highValue) {
        // High focus: Extend work time at the end of the session
        _extendWorkTime();
      }
    } else if (_currentSession == Session.shortBreak) {
      if (stressScore > highValue) {
        // High stress: Extend break time
        _extendBreakTime();
      }
      // High focus during breaks doesn't reduce break time; we passively monitor it.
    }
  }

  void _extendWorkTime() {
    setState(() {
      _sessionDuration += _focusExtensionTime; // Extend work by 5 minutes
      _remainingTime =
          Duration(minutes: _sessionDuration); // Reset remaining time
      print("Work time extended to $_sessionDuration minutes");
    });
  }

  void _reduceWorkTime() {
    if (_sessionDuration > 10) {
      // Minimum work duration threshold
      setState(() {
        _sessionDuration -= _focusReductionTime; // Reduce work by 5 minutes
        _remainingTime =
            Duration(minutes: _sessionDuration) - _stopwatch.elapsed;
        print("Work time reduced to $_sessionDuration minutes");
      });
    }
  }

  void _extendBreakTime() {
    setState(() {
      _sessionDuration += _breakExtensionTime; // Extend break by 2 minutes
      print("Break time extended to $_sessionDuration minutes");
    });
  }

  void _calculateBaseline() {
    if (_sessionData.isNotEmpty) {
      _baselineMetrics = BaselineMetrics.fromSessionData(_sessionData);
      _isBaselineSet = true;
      print("Initial Baseline Set: $_baselineMetrics");
    }
  }

  int _getSessionDuration() {
    return _currentSession == Session.work
        ? _pomodoroTimerAmount
        : _shortBreakAmount;
  }

  void _startSensorDataCollection() {
    // Timer for data collection every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
      } else {
        _collectSensorData(); // Collect sensor data every second

        // Check if baseline is set and calculate if needed
        if (!_isBaselineSet && _sessionData.length >= baselineCalculationTime) {
          _calculateBaseline();
        }
      }
    });

    // Timer for focus and stress calculation every minute
    Timer.periodic(
        const Duration(seconds: periodicFocusAndStressCalculationTime),
        (timer) {
      if (!_isRunning) {
        timer.cancel();
      } else {
        _calculateFocusAndStress(); // Calculate focus and stress every minute
      }
    });
  }

  void _startTimer() {
    // Ensure previous data is cleared
    _sessionData.clear();

    // Start periodic sensor data collection
    _startSensorDataCollection();

    // Start the main timer
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
    _updateBaselineAtSessionEnd(); // Dynamically update baseline at the end of the session
    _skipToNextSession();
  }

  void _updateBaselineAtSessionEnd() {
    if (_sessionData.isNotEmpty && _isBaselineSet) {
      final updatedMetrics = BaselineMetrics.fromSessionData(_sessionData);

      setState(() {
        // Update baseline metrics dynamically using the new method
        _baselineMetrics = _baselineMetrics!.updateWith(updatedMetrics);
      });

      print("Baseline dynamically updated: $_baselineMetrics");
    }
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

  Widget _buildSensorData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Focus Level: $_currentFocusLevel',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          'Stress Level: $_currentStressLevel',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 20), // Add some spacing
        Text(
          'Heart Rate: ${widget.sensorData.heartRate}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          'Temperature: ${widget.sensorData.bodyTemperature}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          'Accelerometer: \n X: ${widget.sensorData.accX} \nY: ${widget.sensorData.accY}\nZ: ${widget.sensorData.accZ}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }
}

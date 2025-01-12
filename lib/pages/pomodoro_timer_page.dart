import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cosinuss/models/data/baseline_metrics.dart';
import 'package:cosinuss/models/data/sensor_data.dart';
import 'package:cosinuss/models/data/session_data.dart';
import 'package:cosinuss/models/logic/focus_calculator.dart';
import 'package:cosinuss/models/logic/stress_calculator.dart';
import 'package:cosinuss/models/pomodoro_focus_modes.dart';
import 'package:cosinuss/models/pomodoro_session_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PomodoroTimerPage extends StatefulWidget {
  final SensorData sensorData;

  final Function(List<SessionData>) onSessionDataUpdate;
  final Function(List<Map<String, dynamic>>) onFocusDataUpdate;
  final Function(List<Map<String, dynamic>>) onStressDataUpdate;

  const PomodoroTimerPage({
    Key? key,
    required this.sensorData,
    required this.onSessionDataUpdate,
    required this.onFocusDataUpdate,
    required this.onStressDataUpdate,
  }) : super(key: key);

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  static const int _pomodoroTimerAmount = 25;
  static const int _shortBreakAmount = 5;
  static const String _workSessionLabel = 'Work Session';
  static const String _breakSessionLabel = 'Break Time';
  static const String _title = 'Pomodoro Focus';
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

  // Sound for when session ends
  late final AudioPlayer _audioPlayer;

  late FocusMode _selectedFocusMode;

  @override
  void initState() {
    super.initState();

    _selectedFocusMode = FocusMode.extremeFocus;
    _audioPlayer = AudioPlayer();
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
    // Collect sensor data
    final sessionData =
        SessionData.fromSensorData(DateTime.now(), widget.sensorData);
    setState(() {
      _sessionData.add(sessionData);
    });

    // Notify parent about updated session data
    widget.onSessionDataUpdate(_sessionData);
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
    _focusData.add({
      "timestamp": DateTime.now().millisecondsSinceEpoch.toDouble(),
      "value": focusScore,
    });
    _stressData.add({
      "timestamp": DateTime.now().millisecondsSinceEpoch.toDouble(),
      "value": stressScore,
    });

    // Notify parent about updated focus and stress data
    widget.onFocusDataUpdate(_focusData);
    widget.onStressDataUpdate(_stressData);

    // Update UI with the latest levels
    setState(() {
      _currentFocusLevel = _getFocusLevel(focusScore);
      _currentStressLevel = _getStressLevel(stressScore);
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
      _handleWorkSessionAdjustments(focusScore, stressScore);
    } else if (_currentSession == Session.shortBreak) {
      _handleBreakSessionAdjustments(stressScore);
    }
  }

  void _handleWorkSessionAdjustments(double focusScore, double stressScore) {
    if (_selectedFocusMode == FocusMode.lowStress) {
      if (stressScore > veryHighValue) {
        // Low Stress mode: Reduce work time if stress is very high
        _reduceWorkTime();
      }
    }

    if (_remainingTime.inMinutes <= 1 && focusScore > highValue) {
      // Extend work time at the end of the session if focus is high
      _extendWorkTime();
    }
  }

  void _handleBreakSessionAdjustments(double stressScore) {
    if (_selectedFocusMode == FocusMode.lowStress && //
        stressScore > highValue) {
      // Low Stress mode: Extend break time if stress is high and in low stress mode
      _extendBreakTime();
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
    if (_currentSession == Session.work) {
      // Ensure previous data is cleared
      _sessionData.clear();
    }

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
    _playSound(); // Play the sound when the timer ends
    _updateUserBaselineMeasurement(); // Dynamically update baseline at the end of the session
    _skipToNextSession();
  }

  void _playSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/timer_end.mp3'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void _updateUserBaselineMeasurement() {
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
    _audioPlayer.dispose();
    _ticker.dispose();
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
                            color: Colors.white.withOpacity(0.8),
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
                          backgroundColor: _isRunning
                              ? Colors.blueGrey.shade900
                              : Colors.blueGrey,
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
                  const SizedBox(height: 20),
                  // Focus Mode Toggle
                  if (!_isRunning)
                    ToggleButtons(
                      isSelected: [
                        _selectedFocusMode == FocusMode.extremeFocus,
                        _selectedFocusMode == FocusMode.lowStress,
                      ],
                      onPressed: (index) {
                        setState(() {
                          _selectedFocusMode = index == 0
                              ? FocusMode.extremeFocus
                              : FocusMode.lowStress;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      selectedColor: Colors.white,
                      fillColor: _currentSession == Session.work
                          ? Colors.blue
                          : Colors.red,
                      color: Colors.white,
                      selectedBorderColor: Colors.black,
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            "Extreme Focus",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            "Low Stress",
                            style: TextStyle(fontWeight: FontWeight.bold),
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

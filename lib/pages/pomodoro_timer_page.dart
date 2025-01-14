import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cosinuss/models/data/baseline_metrics.dart';
import 'package:cosinuss/models/data/sensor_data.dart';
import 'package:cosinuss/models/data/session_data.dart';
import 'package:cosinuss/models/logic/focus_calculator.dart';
import 'package:cosinuss/models/logic/stress_calculator.dart';
import 'package:cosinuss/models/pomodoro_focus_modes.dart';
import 'package:cosinuss/models/pomodoro_session_type.dart';
import 'package:cosinuss/widgets/sensor_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A StatefulWidget that implements the Pomodoro Timer page.
///
/// This page is the core functionality of the app, handling the Pomodoro Timer,
/// sensor data collection, dynamic session adjustments, and visualization of
/// focus and stress levels.
///
/// [PomodoroTimerPage] receives sensor data and updates for session, focus, and stress
/// values, and communicates these updates back to the parent via callback functions.
class PomodoroTimerPage extends StatefulWidget {
  /// The current sensor data being collected from the Cosinuss Earable.
  final SensorData sensorData;

  /// Callback to send the updated session data back to the parent widget.
  /// The session data contains heart rate, temperature, and motion data collected
  /// during a Pomodoro session.
  final Function(List<SessionData>) onSessionDataUpdate;

  /// Callback to send the updated focus data back to the parent widget.
  /// This data represents focus scores calculated periodically during the session.
  final Function(List<Map<String, dynamic>>) onFocusDataUpdate;

  /// Callback to send the updated stress data back to the parent widget.
  /// This data represents stress scores calculated periodically during the session.
  final Function(List<Map<String, dynamic>>) onStressDataUpdate;

  /// Callback to update the navigation bar color dynamically based on the current
  /// session type (work or break) and running status.
  final Function(Color) onUpdateNavBarColor;

  /// Constructs a [PomodoroTimerPage] widget.
  ///
  /// The widget is initialized with the required [sensorData] and callback
  /// functions to handle updates for session, focus, stress data, and navigation bar color.
  const PomodoroTimerPage({
    Key? key,
    required this.sensorData,
    required this.onSessionDataUpdate,
    required this.onFocusDataUpdate,
    required this.onStressDataUpdate,
    required this.onUpdateNavBarColor,
  }) : super(key: key);

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

/// The state class for [PomodoroTimerPage].
///
/// Manages the core Pomodoro Timer functionality, sensor data collection,
/// session adjustments, focus/stress calculations, and user interaction.
class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  // Constants representing default durations and labels for sessions.
  static const int _pomodoroTimerAmount = 25;
  static const int _shortBreakAmount = 5;
  static const String _workSessionLabel = 'Work Session';
  static const String _breakSessionLabel = 'Break Time';
  static const String _title = 'Pomodoro Focus';
  static const String _startButtonLabel = 'Start';
  static const String _stopButtonLabel = 'Pause';
  static const String _skipButtonLabel = 'Skip';

  // Timing constants for session adjustments.
  static const int periodicFocusAndStressCalculationTime = 60; // seconds
  static const int _breakExtensionTime = 1; // minutes
  static const int _focusExtensionTime = 3; // minutes
  static const int _focusReductionTime = _focusExtensionTime;

  // Threshold values for focus and stress levels.
  static const double veryHighValue = 0.9;
  static const double highValue = 0.7;
  static const double mediumValue = 0.4;

  // Variables for UI display of current focus and stress levels.
  String _currentFocusLevel = "Calculating...";
  String _currentStressLevel = "Calculating...";

  // Tracks the current session type (work or break).
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

  // To store user's average baseline values
  static const int baselineCalculationTime =
      180; // 3min, but could increase to 5min if needed
  BaselineMetrics? _baselineMetrics;
  bool _isBaselineSet = false;

  // Calculators
  final StressCalculator _stressCalculator = StressCalculator();
  final FocusCalculator _focusCalculator = FocusCalculator();

  // Audio player to play sound when the session ends ie. when timer goes to zero.
  late final AudioPlayer _audioPlayer;

  // User's selected focus mode (e.g., Extreme Focus or Low Stress).
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

  double _calculateProgress() {
    final totalSeconds = _sessionDuration * 60;
    final elapsedSeconds = totalSeconds - _remainingTime.inSeconds;
    return elapsedSeconds / totalSeconds;
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
      debugPrint("Focus Score: $focusScore, Stress Score: $stressScore");

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
      debugPrint(
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
      debugPrint("Work time extended to $_sessionDuration minutes");
    });
  }

  void _reduceWorkTime() {
    if (_sessionDuration > 10) {
      // Minimum work duration threshold
      setState(() {
        _sessionDuration -= _focusReductionTime; // Reduce work by 5 minutes
        _remainingTime =
            Duration(minutes: _sessionDuration) - _stopwatch.elapsed;
        debugPrint("Work time reduced to $_sessionDuration minutes");
      });
    }
  }

  void _extendBreakTime() {
    setState(() {
      _sessionDuration += _breakExtensionTime; // Extend break
      debugPrint("Break time extended to $_sessionDuration minutes");
    });
  }

  void _calculateBaseline() {
    if (_sessionData.isNotEmpty) {
      _baselineMetrics = BaselineMetrics.fromSessionData(_sessionData);
      _isBaselineSet = true;
      debugPrint("Initial Baseline Set: $_baselineMetrics");
    }
  }

  int _getSessionDuration() {
    return _currentSession == Session.work
        ? _pomodoroTimerAmount
        : _shortBreakAmount;
  }

  bool _shouldStopSensorCollection() {
    return (!_isRunning || !widget.sensorData.isConnected);
  }

  void _startSensorDataCollection() {
    // Timer for data collection every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_shouldStopSensorCollection()) {
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
      if (_shouldStopSensorCollection()) {
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
    _updateNavBarColor();
  }

  void _stopTimer() {
    setState(() {
      _stopwatch.stop();
      _ticker.stop();
      _isRunning = false;
    });
    _updateNavBarColor();
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

    _updateNavBarColor();
  }

  void _completeTimer() {
    _playSound(); // Play the sound when the timer ends
    _updateUserBaselineMeasurement(); // Dynamically update baseline at the end of the session
    _skipToNextSession();
  }

  void _playSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/timer_end.mp3'));
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

      debugPrint("Baseline dynamically updated: $_baselineMetrics");
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

  void _updateNavBarColor() {
    widget.onUpdateNavBarColor(_getPageBackgroundColor());
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
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: _calculateProgress(),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _currentSession == Session.work
                          ? Colors.green
                          : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sensor Data Section
                  _buildSensorData(),
                  const SizedBox(height: 30),

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
                      color: Colors.white54,
                      selectedBorderColor: Colors.black,
                      constraints: const BoxConstraints(
                        minWidth: 150, // Set fixed width for equal size
                        minHeight: 50, // Set fixed height for equal size
                      ),
                      children: const [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt, size: 20, color: Colors.white),
                            SizedBox(height: 4),
                            Text(
                              "Extreme Focus",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.self_improvement_sharp,
                                size: 20, color: Colors.white),
                            SizedBox(height: 4),
                            Text(
                              "Low Stress",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(
                      height: 35), // Reduced space between timer and buttons

                  // Buttons Section
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: _isRunning
                              ? const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 15)
                              : const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 25),
                          elevation: 4,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isRunning ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isRunning ? _stopButtonLabel : _startButtonLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _skipToNextSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: _isRunning
                              ? const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 15)
                              : const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 25),
                          elevation: 4,
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.skip_next,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              _skipButtonLabel,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorData() {
    return SensorDataWidget(
      focusLevel: _currentFocusLevel,
      stressLevel: _currentStressLevel,
      heartRate: widget.sensorData.heartRate.toString(),
      temperature: widget.sensorData.bodyTemperature.toString(),
    );
  }
}

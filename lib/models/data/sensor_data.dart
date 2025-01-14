import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Represents data collected from the sensor, including heart rate,
/// body temperature, accelerometer values, and PPG signals.
class SensorData {
  static const String _defaultConnectionStatus = "Not Connected";
  static const String _defaultSensorValue = "-";

  /// Default sensor value when no data is available.
  String get defaultSensorValue => _defaultSensorValue;

  /// Tracks whether the sensor is connected.
  bool _isConnected = false;

  /// Connection status message for the sensor.
  String _connectionStatus = _defaultConnectionStatus;

  /// The current heart rate value (in bpm).
  int _heartRate = 0;

  /// The heart rate as a formatted string.
  String _heartRateString = _defaultSensorValue;

  /// The current body temperature value (in °C).
  double _bodyTemperature = 0.0;

  /// The body temperature as a formatted string.
  String _bodyTemperatureString = _defaultSensorValue;

  /// Accelerometer X-axis value.
  int _accX = 0;

  /// Accelerometer Y-axis value.
  int _accY = 0;

  /// Accelerometer Z-axis value.
  int _accZ = 0;

  /// Formatted accelerometer X-axis value.
  String _accXString = _defaultSensorValue;

  /// Formatted accelerometer Y-axis value.
  String _accYString = _defaultSensorValue;

  /// Formatted accelerometer Z-axis value.
  String _accZString = _defaultSensorValue;

  /// Raw PPG green light value.
  int _ppgGreen = 0;

  /// Raw PPG red light value.
  int _ppgRed = 0;

  /// Raw PPG ambient light value.
  int _ppgAmbient = 0;

  /// Formatted PPG green light value.
  String _ppgGreenString = _defaultSensorValue;

  /// Formatted PPG red light value.
  String _ppgRedString = _defaultSensorValue;

  /// Formatted PPG ambient light value.
  String _ppgAmbientString = _defaultSensorValue;

  /// Returns the raw heart rate value.
  int get rawHeartRate => _heartRate;

  /// Returns the heart rate as a formatted string.
  String get heartRate => _heartRateString;

  /// Returns the raw body temperature value.
  double get rawBodyTemperature => _bodyTemperature;

  /// Returns the body temperature as a formatted string.
  String get bodyTemperature => _bodyTemperatureString;

  /// Returns the raw accelerometer X-axis value.
  int get rawAccX => _accX;

  /// Returns the raw accelerometer Y-axis value.
  int get rawAccY => _accY;

  /// Returns the raw accelerometer Z-axis value.
  int get rawAccZ => _accZ;

  /// Returns the formatted accelerometer X-axis value.
  String get accX => _accXString;

  /// Returns the formatted accelerometer Y-axis value.
  String get accY => _accYString;

  /// Returns the formatted accelerometer Z-axis value.
  String get accZ => _accZString;

  /// Returns the raw PPG green light value.
  int get rawPPGGreen => _ppgGreen;

  /// Returns the raw PPG red light value.
  int get rawPPGRed => _ppgRed;

  /// Returns the raw PPG ambient light value.
  int get rawPPGAmbient => _ppgAmbient;

  /// Returns the formatted PPG green light value.
  String get ppgGreen => _ppgGreenString;

  /// Returns the formatted PPG red light value.
  String get ppgRed => _ppgRedString;

  /// Returns the formatted PPG ambient light value.
  String get ppgAmbient => _ppgAmbientString;

  /// Returns the current connection status message.
  String get connectionStatus => _connectionStatus;

  /// Indicates whether the sensor is connected.
  bool get isConnected => _isConnected;

  /// Updates the connection status of the sensor.
  ///
  /// [status]: A boolean indicating if the sensor is connected.
  void updateConnectionStatus(bool status) {
    _isConnected = status;
    _connectionStatus = (_isConnected) ? "Connected" : _defaultConnectionStatus;
  }

  /// Updates the heart rate value using raw data from the sensor.
  ///
  /// [rawData]: A list of bytes representing heart rate data.
  /// Logs an error message if the data is invalid or insufficient.
  void updateHeartRate(rawData) {
    if (rawData == null || rawData.length < 2) {
      debugPrint("Invalid or insufficient data for heart rate update.");
      return;
    }
    Uint8List bytes = Uint8List.fromList(rawData);

    // Based on GATT standard
    int bpm = bytes[1];
    if (!((bytes[0] & 0x01) == 0)) {
      bpm = (((bpm >> 8) & 0xFF) | ((bpm << 8) & 0xFF00));
    }

    _heartRate = bpm;
    _heartRateString = "$_heartRate bpm";
  }

  /// Updates the body temperature value using raw data from the sensor.
  ///
  /// [rawData]: A list of bytes representing body temperature data.
  /// Logs an error message if the data is invalid or insufficient.
  void updateBodyTemperature(rawData) {
    if (rawData == null || rawData.length < 4) {
      debugPrint("Invalid or insufficient data for body temperature update.");
      return;
    }
    int flag = rawData[0];

    // Based on GATT standard
    double temperature = twosComplimentOfNegativeMantissa(
            ((rawData[3] << 16) | (rawData[2] << 8) | rawData[1]) & 16777215) /
        100.0;
    if ((flag & 1) != 0) {
      temperature =
          ((98.6 * temperature) - 32.0) * (5.0 / 9.0); // Fahrenheit to Celsius
    }

    _bodyTemperature = temperature;
    _bodyTemperatureString = _bodyTemperature.toStringAsFixed(1) + " °C";
  }

  /// Updates the PPG values using raw data from the sensor.
  ///
  /// [rawData]: A list of bytes representing PPG data.
  /// Logs an error message if the data is invalid or insufficient.
  void updatePPGRaw(rawData) {
    if (rawData == null || rawData.length < 12) {
      debugPrint("Invalid or insufficient data for PPG update.");
      return;
    }

    Uint8List bytes = Uint8List.fromList(rawData);

    _ppgGreen = bytes[0] | bytes[1] << 8 | bytes[2] << 16 | bytes[3] << 32;
    _ppgRed = bytes[4] | bytes[5] << 8 | bytes[6] << 16 | bytes[7] << 32;
    _ppgAmbient = bytes[8] | bytes[9] << 8 | bytes[10] << 16 | bytes[11] << 32;

    _ppgGreenString = "$_ppgGreen";
    _ppgRedString = "$_ppgRed";
    _ppgAmbientString = "$_ppgAmbient";
  }

  /// Updates the accelerometer values using raw data from the sensor.
  ///
  /// [rawData]: A list of bytes representing accelerometer data.
  /// Logs an error message if the data is invalid or insufficient.
  void updateAccelerometer(rawData) {
    if (rawData == null || rawData.length < 19) {
      debugPrint("Invalid or insufficient data for accelerometer update.");
      return;
    }

    Int8List bytes = Int8List.fromList(rawData);

    // Description based on placing the earable into your right ear canal
    _accX = bytes[14];
    _accY = bytes[16];
    _accZ = bytes[18];

    _accXString = "$_accX";
    _accYString = "$_accY";
    _accZString = "$_accZ";
  }

  /// Converts a two's complement mantissa value to its decimal representation.
  ///
  /// [mantissa]: The raw mantissa value.
  ///
  /// Returns the converted value.
  int twosComplimentOfNegativeMantissa(int mantissa) {
    if ((4194304 & mantissa) != 0) {
      return (((mantissa ^ -1) & 16777215) + 1) * -1;
    }

    return mantissa;
  }
}

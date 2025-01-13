import 'dart:typed_data';

class SensorData {
  static const String _defaultConnectionStatus = "Not Connected";
  static const String _defaultSensorValue = "-";

  String get defaultSensorValue => _defaultSensorValue;

  bool _isConnected = false;

  String _connectionStatus = _defaultConnectionStatus;

  int _heartRate = 0;
  String _heartRateString = _defaultSensorValue;

  double _bodyTemperature = 0.0;
  String _bodyTemperatureString = _defaultSensorValue;

  int _accX = 0;
  String _accXString = _defaultSensorValue;
  int _accY = 0;
  String _accYString = _defaultSensorValue;
  int _accZ = 0;
  String _accZString = _defaultSensorValue;

  int _ppgGreen = 0;
  String _ppgGreenString = _defaultSensorValue;
  int _ppgRed = 0;
  String _ppgRedString = _defaultSensorValue;
  int _ppgAmbient = 0;
  String _ppgAmbientString = _defaultSensorValue;

// Getter for heart rate
  int get rawHeartRate => _heartRate; // Raw value as integer
  String get heartRate => _heartRateString; // String with unit

// Getter for body temperature
  double get rawBodyTemperature => _bodyTemperature;
  String get bodyTemperature => _bodyTemperatureString;

// Getters for accelerometer values
  int get rawAccX => _accX;
  int get rawAccY => _accY;
  int get rawAccZ => _accZ;

  String get accX => _accXString;
  String get accY => _accYString;
  String get accZ => _accZString;

// Getters for PPG values
  int get rawPPGGreen => _ppgGreen;
  int get rawPPGRed => _ppgRed;
  int get rawPPGAmbient => _ppgAmbient;

  String get ppgGreen => _ppgGreenString;
  String get ppgRed => _ppgRedString;
  String get ppgAmbient => _ppgAmbientString;

// Getter for connection status
  String get connectionStatus => _connectionStatus;
  bool get isConnected => _isConnected;

  void updateConnectionStatus(bool status) {
    _isConnected = status;
    _connectionStatus = (_isConnected) ? "Connected" : _defaultConnectionStatus;
  }

  void updateHeartRate(rawData) {
    if (rawData == null || rawData.length < 2) {
      print("Invalid or insufficient data for heart rate update.");
      return; // Early exit if data is null or too short, please wait a few seconds.
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

  void updateBodyTemperature(rawData) {
    if (rawData == null || rawData.length < 4) {
      print("Invalid or insufficient data for body temperature update.");
      return; // Early exit if data is null or too short, please wait a few seconds.
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

  void updatePPGRaw(rawData) {
    if (rawData == null || rawData.length < 12) {
      print("Invalid or insufficient data for PPG update.");
      return; // Early exit if data is null or too short, please wait a few seconds.
    }

    Uint8List bytes = Uint8List.fromList(rawData);

    _ppgGreen = bytes[0] | bytes[1] << 8 | bytes[2] << 16 | bytes[3] << 32;
    _ppgRed = bytes[4] | bytes[5] << 8 | bytes[6] << 16 | bytes[7] << 32;
    _ppgAmbient = bytes[8] | bytes[9] << 8 | bytes[10] << 16 | bytes[11] << 32;

    _ppgGreenString = "$_ppgGreen";
    _ppgRedString = "$_ppgRed";
    _ppgAmbientString = "$_ppgAmbient";
  }

  void updateAccelerometer(rawData) {
    if (rawData == null || rawData.length < 19) {
      print("Invalid or insufficient data for accelerometer update.");
      return; // Early exit if data is null or too short, please wait a few seconds.
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

  int twosComplimentOfNegativeMantissa(int mantissa) {
    if ((4194304 & mantissa) != 0) {
      return (((mantissa ^ -1) & 16777215) + 1) * -1;
    }

    return mantissa;
  }
}

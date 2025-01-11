import 'dart:typed_data';

class SensorData {
  bool _isConnected = false;
  String _connectionStatus = "Disconnected";

  int _heartRate = 0;
  double _bodyTemperature = 0.0;

  int _accX = 0;
  int _accY = 0;
  int _accZ = 0;

  int _ppgGreen = 0;
  int _ppgRed = 0;
  int _ppgAmbient = 0;

// Getter for heart rate
  int get rawHeartRate => _heartRate; // Raw value as integer
  String get heartRate => _heartRate != 0 ? "$_heartRate bpm" : "- bpm";

// Getter for body temperature
  double get rawBodyTemperature => _bodyTemperature; // Raw value
  String get bodyTemperature =>
      "${_bodyTemperature.toStringAsFixed(1)} °C"; // String with unit

// Getters for accelerometer values
  int get rawAccX => _accX;
  int get rawAccY => _accY;
  int get rawAccZ => _accZ;

  String get accX => "$_accX (unknown unit)";
  String get accY => "$_accY (unknown unit)";
  String get accZ => "$_accZ (unknown unit)";

// Getters for PPG values
  int get rawPPGGreen => _ppgGreen;
  int get rawPPGRed => _ppgRed;
  int get rawPPGAmbient => _ppgAmbient;

  String get ppgGreen => "$_ppgGreen (unknown unit)";
  String get ppgRed => "$_ppgRed (unknown unit)";
  String get ppgAmbient => "$_ppgAmbient (unknown unit)";

// Getter for connection status
  String get connectionStatus => _connectionStatus;
  bool get isConnected => _isConnected;

  void updateConnectionStatus(bool status) {
    _isConnected = status;
    _connectionStatus = (_isConnected) ? "Connected" : "Disconnected";
  }

  void updateHeartRate(rawData) {
    Uint8List bytes = Uint8List.fromList(rawData);

    // Based on GATT standard
    int bpm = bytes[1];
    if (!((bytes[0] & 0x01) == 0)) {
      bpm = (((bpm >> 8) & 0xFF) | ((bpm << 8) & 0xFF00));
    }

    _heartRate = bpm;
  }

  void updateBodyTemperature(rawData) {
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
  }

  void updatePPGRaw(rawData) {
    Uint8List bytes = Uint8List.fromList(rawData);

    _ppgGreen = bytes[0] | bytes[1] << 8 | bytes[2] << 16 | bytes[3] << 32;
    _ppgRed = bytes[4] | bytes[5] << 8 | bytes[6] << 16 | bytes[7] << 32;
    _ppgAmbient = bytes[8] | bytes[9] << 8 | bytes[10] << 16 | bytes[11] << 32;
  }

  void updateAccelerometer(rawData) {
    Int8List bytes = Int8List.fromList(rawData);

    // Description based on placing the earable into your right ear canal
    _accX = bytes[14];
    _accY = bytes[16];
    _accZ = bytes[18];
  }

  int twosComplimentOfNegativeMantissa(int mantissa) {
    if ((4194304 & mantissa) != 0) {
      return (((mantissa ^ -1) & 16777215) + 1) * -1;
    }

    return mantissa;
  }
}

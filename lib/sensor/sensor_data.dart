import 'dart:typed_data';

class SensorData {
  bool _isConnected = false;
  String _connectionStatus = "Disconnected";

  String _heartRate = "- bpm";
  String _bodyTemperature = '- °C';

  String _accX = "-";
  String _accY = "-";
  String _accZ = "-";

  String _ppgGreen = "-";
  String _ppgRed = "-";
  String _ppgAmbient = "-";

// Getter for heart rate
  String get heartRate => _heartRate;

// Getter for body temperature
  String get bodyTemperature => _bodyTemperature;

// Getters for accelerometer values
  String get accX => _accX;
  String get accY => _accY;
  String get accZ => _accZ;

// Getters for PPG values
  String get ppgGreen => _ppgGreen;
  String get ppgRed => _ppgRed;
  String get ppgAmbient => _ppgAmbient;

  // Getter for connection status
  String get connectionStatus => _connectionStatus;
  bool get isConnected => _isConnected;

  void updateConnectionStatus(bool status) {
    _isConnected = status;
    _connectionStatus = (_isConnected) ? "Connected" : "Disconnected";
  }

  void updateHeartRate(rawData) {
    Uint8List bytes = Uint8List.fromList(rawData);

    // based on GATT standard
    var bpm = bytes[1];
    if (!((bytes[0] & 0x01) == 0)) {
      bpm = (((bpm >> 8) & 0xFF) | ((bpm << 8) & 0xFF00));
    }

    var bpmLabel = "- bpm";
    if (bpm != 0) {
      bpmLabel = bpm.toString() + " bpm";
    }

    _heartRate = bpmLabel;
  }

  void updateBodyTemperature(rawData) {
    var flag = rawData[0];

    // based on GATT standard
    double temperature = twosComplimentOfNegativeMantissa(
            ((rawData[3] << 16) | (rawData[2] << 8) | rawData[1]) & 16777215) /
        100.0;
    if ((flag & 1) != 0) {
      temperature = ((98.6 * temperature) - 32.0) *
          (5.0 / 9.0); // convert Fahrenheit to Celsius
    }

    _bodyTemperature = temperature.toString() + " °C"; // todo update body temp
  }

  void updatePPGRaw(rawData) {
    Uint8List bytes = Uint8List.fromList(rawData);

    // corresponds to the raw reading of the PPG sensor from which the heart rate is computed
    //
    // example plot https://e2e.ti.com/cfs-file/__key/communityserver-discussions-components-files/73/Screen-Shot-2019_2D00_01_2D00_24-at-19.30.24.png
    // (image just for illustration purpose, obtained from a different sensor! Sensor value range differs.)

    var ppgRed = bytes[0] |
        bytes[1] << 8 |
        bytes[2] << 16 |
        bytes[3] << 32; // raw green color value of PPG sensor
    var ppgGreen = bytes[4] |
        bytes[5] << 8 |
        bytes[6] << 16 |
        bytes[7] << 32; // raw red color value of PPG sensor

    var ppgGreenAmbient = bytes[8] |
        bytes[9] << 8 |
        bytes[10] << 16 |
        bytes[11] <<
            32; // ambient light sensor (e.g., if sensor is not placed correctly)

    _ppgGreen = ppgRed.toString() + " (unknown unit)";
    _ppgRed = ppgGreen.toString() + " (unknown unit)";
    _ppgAmbient = ppgGreenAmbient.toString() + " (unknown unit)";
  }

  void updateAccelerometer(rawData) {
    Int8List bytes = Int8List.fromList(rawData);

    // description based on placing the earable into your right ear canal
    int accX = bytes[14];
    int accY = bytes[16];
    int accZ = bytes[18];

    _accX = accX.toString() + " (unknown unit)";
    _accY = accY.toString() + " (unknown unit)";
    _accZ = accZ.toString() + " (unknown unit)";
  }

  int twosComplimentOfNegativeMantissa(int mantissa) {
    if ((4194304 & mantissa) != 0) {
      return (((mantissa ^ -1) & 16777215) + 1) * -1;
    }

    return mantissa;
  }
}

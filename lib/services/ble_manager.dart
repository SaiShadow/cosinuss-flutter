import 'package:flutter_blue/flutter_blue.dart';

class BLEManager {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  bool earConnectFound = false;
  BluetoothDevice? connectedDevice;

  void startScan(Function onDeviceConnected) {
    flutterBlue.startScan(timeout: const Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.name == "earconnect" && !earConnectFound) {
          earConnectFound = true;
          await flutterBlue.stopScan();
          await r.device.connect();
          connectedDevice = r.device;
          onDeviceConnected(r.device);
        }
      }
    });
  }

  Future<void> disconnect() async {
    if (connectedDevice != null) {
      await connectedDevice?.disconnect();
      connectedDevice = null;
      earConnectFound = false; // Reset the flag to allow reconnection
    }
  }
}

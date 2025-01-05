import 'package:flutter_blue/flutter_blue.dart';

class BluetoothService {
  bool isConnected = false;
  bool earConnectFound = false;

  final FlutterBlue flutterBlue = FlutterBlue.instance;

  final Function(String) updateConnectionStatus;
  final Function(List<int>) updateHeartRate;
  final Function(List<int>) updateBodyTemperature;
  final Function(List<int>) updatePPGRaw;
  final Function(List<int>) updateAccelerometer;

  BluetoothService(
      {required this.updateConnectionStatus,
      required this.updateHeartRate,
      required this.updateBodyTemperature,
      required this.updatePPGRaw,
      required this.updateAccelerometer});

  void updateIsConnected(bool value) {
    isConnected = value;
  }

  void connect() {
    // start scanning
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    // listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) async {
      // do something with scan results
      for (ScanResult r in results) {
        if (r.device.name == "earconnect" && !earConnectFound) {
          earConnectFound =
              true; // avoid multiple connects attempts to same device

          await flutterBlue.stopScan();

          r.device.state.listen((state) {
            // listen for connection state changes
            setState(() {
              _isConnected = state == BluetoothDeviceState.connected;
              _connectionStatus = (_isConnected) ? "Connected" : "Disconnected";
            });
          });

          await r.device.connect();

          var services = await r.device.discoverServices();

          for (var service in services) {
            // iterate over services
            for (var characteristic in service.characteristics) {
              // iterate over characterstics
              switch (characteristic.uuid.toString()) {
                case "0000a001-1212-efde-1523-785feabcd123":
                  print("Starting sampling ...");
                  await characteristic.write([
                    0x32,
                    0x31,
                    0x39,
                    0x32,
                    0x37,
                    0x34,
                    0x31,
                    0x30,
                    0x35,
                    0x39,
                    0x35,
                    0x35,
                    0x30,
                    0x32,
                    0x34,
                    0x35
                  ]);
                  await Future.delayed(const Duration(
                      seconds:
                          2)); // short delay before next bluetooth operation otherwise BLE crashes
                  characteristic.value.listen((rawData) {
                    updateAccelerometer(rawData);
                    updatePPGRaw(rawData);
                  });
                  await characteristic.setNotifyValue(true);
                  await Future.delayed(const Duration(seconds: 2));
                  break;

                case "00002a37-0000-1000-8000-00805f9b34fb":
                  characteristic.value.listen((rawData) {
                    updateHeartRate(rawData);
                  });
                  await characteristic.setNotifyValue(true);
                  await Future.delayed(const Duration(
                      seconds:
                          2)); // short delay before next bluetooth operation otherwise BLE crashes
                  break;

                case "00002a1c-0000-1000-8000-00805f9b34fb":
                  characteristic.value.listen((rawData) {
                    updateBodyTemperature(rawData);
                  });
                  await characteristic.setNotifyValue(true);
                  await Future.delayed(const Duration(
                      seconds:
                          2)); // short delay before next bluetooth operation otherwise BLE crashes
                  break;
              }
            }
          }
        }
      }
    });
  }
}

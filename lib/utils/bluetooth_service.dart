import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

/// A class responsible for managing Bluetooth Low Energy (BLE) connections
/// and interacting with the Cosinuss earable device.
class BLEManager {
  /// Indicates whether the Cosinuss earable device has been found.
  bool earConnectFound = false;

  /// Instance of FlutterBlue for BLE operations.
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  /// Callback to update the connection status.
  final Function(bool) updateConnectionStatus;

  /// Callback to update heart rate data.
  final Function(List<int>) updateHeartRate;

  /// Callback to update body temperature data.
  final Function(List<int>) updateBodyTemperature;

  /// Callback to update PPG raw data.
  final Function(List<int>) updatePPGRaw;

  /// Callback to update accelerometer data.
  final Function(List<int>) updateAccelerometer;

  /// Constructor for `BLEManager` to initialize callback functions.
  ///
  /// - [updateConnectionStatus]: Callback to handle connection status changes.
  /// - [updateHeartRate]: Callback to handle heart rate updates.
  /// - [updateBodyTemperature]: Callback to handle body temperature updates.
  /// - [updatePPGRaw]: Callback to handle PPG raw data updates.
  /// - [updateAccelerometer]: Callback to handle accelerometer data updates.
  BLEManager({
    required this.updateConnectionStatus,
    required this.updateHeartRate,
    required this.updateBodyTemperature,
    required this.updatePPGRaw,
    required this.updateAccelerometer,
  });

  /// Initiates a connection to the Cosinuss earable device.
  ///
  /// Starts scanning for BLE devices and attempts to connect to a device
  /// with the name "earconnect".
  void connect() {
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    // Listen to scan results and handle connection.
    var subscription = flutterBlue.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.name == "earconnect" && !earConnectFound) {
          earConnectFound = true; // Prevent multiple connection attempts.

          await flutterBlue.stopScan();
          debugPrint("Device found: ${r.device.name}");

          BluetoothDevice device = await _connectToDevice(r.device) //
              .catchError((e) {
            // catch errors
            debugPrint("Error when connecting to Earable: $e");
          });
          debugPrint("Connected to: ${device.name}");

          await _manageServices(device) //
              .catchError((e) {
            // catch errors
            debugPrint("Error when managing services: $e");
          });
        }
      }
    }, onError: (e) {
      debugPrint("Error when scanning for Earable: $e");
    });
  }

  /// Connects to the specified Bluetooth device.
  ///
  /// - [device]: The Bluetooth device to connect to.
  ///
  /// Returns the connected `BluetoothDevice`.
  Future<BluetoothDevice> _connectToDevice(BluetoothDevice device) async {
    device.state.listen((state) {
      updateConnectionStatus(state == BluetoothDeviceState.connected);
    });

    await device.connect();
    return device;
  }

  /// Manages the services and characteristics of the connected device.
  ///
  /// - [device]: The connected Bluetooth device.
  ///
  /// Discovers services, writes necessary configuration, and listens to characteristic updates.
  Future<void> _manageServices(BluetoothDevice device) async {
    var services = await device.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        switch (characteristic.uuid.toString()) {
          case "0000a001-1212-efde-1523-785feabcd123":
            debugPrint("Starting sampling...");
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
              0x35,
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

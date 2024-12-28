import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:get/get.dart';

class BleController extends GetxController {
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? inputCharacteristic;

  // Function to scan devices
  Future<void> scanDevices() async {
    // Request Bluetooth and location permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothScan]?.isGranted == true &&
        statuses[Permission.bluetoothConnect]?.isGranted == true &&
        statuses[Permission.location]?.isGranted == true) {
      // Start scanning for BLE devices with a timeout of 15 seconds
      FlutterBluePlus.startScan(timeout: Duration(seconds: 15));
      print("Scanning for devices...");
    } else {
      print("Permissions not granted. Unable to scan.");
    }
  }

  // Function to connect to a device
  Future<void> connectToDevice(
      BuildContext context, BluetoothDevice device) async {
    try {
      // Connect to the device
      await device.connect();
      connectedDevice = device;

      // Optionally, discover services and characteristics
      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) {
        print('Discovered service: ${service.uuid}');
        service.characteristics.forEach((characteristic) {
          print('Discovered characteristic: ${characteristic.uuid}');
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.name}'),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      print("Error connecting to device: $e");

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to ${device.remoteId.toString()}'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // Function to write data to the connected device
  Future<void> sendData(String data) async {
    if (connectedDevice == null || inputCharacteristic == null) {
      print("Device not connected or characteristic not found");
      return;
    }

    // Convert the string data to bytes (you can send other types of data as well)
    List<int> bytes = utf8.encode(data);

    try {
      // Write data to the input characteristic
      await inputCharacteristic?.write(bytes);
      print("Data sent: $data");
    } catch (e) {
      print("Error sending data: $e");
    }
  }

  // Getter to provide a stream of scan results
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}

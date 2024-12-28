import 'package:flutter/material.dart';
import 'package:flutter_ble_app/ble_controller.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class BleScanner extends StatefulWidget {
  const BleScanner({super.key});

  @override
  _BleScannerState createState() => _BleScannerState();
}

class _BleScannerState extends State<BleScanner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GetBuilder<BleController>(
        init: BleController(),
        builder: (BleController controller) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => controller.scanDevices(),
                  child: Text("Scan Devices"),
                ),
                StreamBuilder<List<ScanResult>>(
                  stream: controller.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            // Your code to build each item
                            final scanResult = snapshot.data![index];
                            return ListTile(
                              title: Text(
                                  scanResult.device.platformName.isNotEmpty
                                      ? scanResult.device.platformName
                                      : 'Unknown Device'),
                              subtitle:
                                  Text(scanResult.device.remoteId.toString()),
                              trailing:
                                  Text('RSSI: ${scanResult.rssi.toString()}'),
                              onTap: () async {
                                // Connect to the selected device
                                await controller.connectToDevice(
                                    context, scanResult.device);
                              },
                            );
                          },
                        ),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else {
                      return Text('No devices found');
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

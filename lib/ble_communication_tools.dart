import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BleCommunicationTools {

  BluetoothDevice? connectedCar;
  bool isConnected = false;

  Future<bool> scanForSelectedCar(String targetBleId) async {
    bool found = false;
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    print('🔍 Scanning...');

    await for (var scanResults in FlutterBluePlus.scanResults) {
      for (var result in scanResults) {
        if (result.device.remoteId.str == targetBleId) {
          print("✅ Car Found: ${result.device.remoteId.str}");
          found = true;
        }
      }
      if (found) break;
    }

    await FlutterBluePlus.stopScan();
    return found;
  }

  Future<bool> sendCommand(String command) async {
    if (connectedCar == null || !isConnected) {
      print("❌ Car not connected!");
      return false;
    }

    try {
      var services = await connectedCar!.discoverServices();
      var characteristic = services
          .expand((service) => service.characteristics)
          .firstWhere((c) => c.uuid.toString().contains("abcd1234"));

      await characteristic.write(command.codeUnits);

      print("📩 Command Sent: $command");
      return true;
    } catch (e) {
      print("❌ Failed to send command: $e");
      return false;
    }
  }

  Future<bool> connectToCar(String bleDeviceId) async {
    try {
      print("🔍 Scanning for car...");

      if (bleDeviceId == 'none') {
        print('Car is none');
        return false;
      }

      List<BluetoothDevice> connectedDevices =
      await FlutterBluePlus.connectedDevices;
      BluetoothDevice device = connectedDevices.firstWhere(
            (d) => d.remoteId.str == bleDeviceId,
        orElse: () => BluetoothDevice(remoteId: DeviceIdentifier(bleDeviceId)),
      );

      if (!device.isConnected) {
        await device.connect();
      }

      connectedCar = device;
      isConnected = true;
      print("✅ Connected to car: ${device.remoteId.str}");

      final prefs = await SharedPreferences.getInstance();
      bool isEnabled = prefs.getBool('automatic_connection') ?? false;

      if (isEnabled) {
        sendCommand('AUTO_OPEN_ON');
      } else {
        sendCommand('AUTO_OPEN_OFF');
      }

      return true;
    } catch (e) {
      print("❌ Connection Failed: $e");
      return false;
    }
  }
}
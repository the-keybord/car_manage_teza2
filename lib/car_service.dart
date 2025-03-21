import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarService {
  BluetoothDevice? _connectedCar;
  bool isConnected = false;

  BluetoothDevice? get connectedCar => _connectedCar;

  Future<bool> connectToCar(String bleDeviceId) async {
    try {
      print("🔍 Scanning for car...");

      if (bleDeviceId == 'none') {
        print('Car is none');
        return false;
      }
      List<BluetoothDevice> connectedDevices =
          await FlutterBluePlus.connectedDevices;
      _connectedCar = connectedDevices.firstWhere(
        (d) => d.remoteId.str == bleDeviceId,
        orElse: () => BluetoothDevice(remoteId: DeviceIdentifier(bleDeviceId)),
      );

      if (!_connectedCar!.isConnected) {
        await _connectedCar!.connect();
      }

      isConnected = true;
      print("✅ Connected to car: ${_connectedCar!.remoteId.str}");

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

  Future<void> disconnectCar() async {
    if (_connectedCar != null && isConnected) {
      await _connectedCar!.disconnect();
      isConnected = false;
      print("🔌 Car Disconnected");
    }
  }

  Future<bool> sendCommand(String command) async {
    if (_connectedCar == null || !isConnected) {
      print("❌ Car not connected!");
      return false;
    }

    try {
      var services = await _connectedCar!.discoverServices();
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

  Future<bool> isBluetoothEnabled() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  Future<bool> scanForSelectedCar(String targetBleId) async {
    bool found = false;
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
    print('scanned');
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
}

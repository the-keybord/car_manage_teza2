import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ble_communication_tools.dart';

class CarController extends GetxController {
  Rx<BluetoothDevice?> connectedCar = Rx<BluetoothDevice?>(null);
  RxBool isConnected = false.obs;
  final BleCommunicationTools bleTool = BleCommunicationTools();

  // ✅ Connect to Car
  Future<bool> connectToCar(String bleDeviceId) async {
    var x = await bleTool.connectToCar(bleDeviceId);
      connectedCar.value = bleTool.connectedCar;
      isConnected.value = bleTool.isConnected;
      return x;
  }

  // ✅ Disconnect Car
  Future<void> disconnectCar() async {
    if (connectedCar.value != null && isConnected.value) {
      await connectedCar.value!.disconnect();
      isConnected.value = false;
      connectedCar.value = null;
      print("🔌 Car Disconnected");
    }
  }

  // ✅ Send BLE Command
  Future<bool> sendCommand(String command) async {
    return await bleTool.sendCommand(command);
  }

  // ✅ Check Bluetooth Status
  Future<bool> isBluetoothEnabled() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  // ✅ Scan for the selected car
  Future<bool> scanForSelectedCar(String targetBleId) async {
    return await bleTool.scanForSelectedCar(targetBleId);
  }
}

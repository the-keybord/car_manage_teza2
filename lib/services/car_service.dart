import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/car_controller.dart';

class CarService {
  final CarController _carController = Get.find<CarController>();

  // ✅ Get connected car
  String? get connectedCarId => _carController.connectedCar.value?.remoteId.str;

  // ✅ Connect to the selected car
  Future<bool> connectToSelectedCar() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedCarBleId = prefs.getString('selectedCarBleId');

    if (savedCarBleId == null || savedCarBleId.isEmpty || savedCarBleId == 'none') {
      print("🚫 No car selected.");
      return false;
    }

    return await _carController.connectToCar(savedCarBleId);
  }

  // ✅ Disconnect from the car
  Future<void> disconnectCar() async {
    await _carController.disconnectCar();
  }

  // ✅ Send command
  Future<bool> sendCommand(String command) async {
    return await _carController.sendCommand(command);
  }

  // ✅ Scan for the selected car
  Future<bool> scanForSelectedCar() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedCarBleId = prefs.getString('selectedCarBleId');
    if (savedCarBleId == null || savedCarBleId.isEmpty) {
      print("🚫 No car selected.");
      return false;
    }
    return await _carController.scanForSelectedCar(savedCarBleId);
  }
}

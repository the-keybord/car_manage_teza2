import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'car_service.dart';

class SettingsController extends GetxController {
  RxBool automaticConnectionEnabled = false.obs;  // ✅ Compatible with previous structure
  RxString selectedCarBleId = "".obs; // ✅ Keeps the selected car ID

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();

    // ✅ Auto-sync settings with the background service
    ever(automaticConnectionEnabled, (enabled) => _notifyService());
    ever(selectedCarBleId, (carId) => _notifyService());
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    automaticConnectionEnabled.value = prefs.getBool('automatic_connection') ?? false;
    selectedCarBleId.value = prefs.getString('savedCarId') ?? "";
  }

  // ✅ Set auto-connection and store in SharedPreferences
  Future<void> setAutomaticConnection(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('automatic_connection', value);
    automaticConnectionEnabled.value = value;
  }

  // ✅ Set the selected car and store in SharedPreferences
  Future<void> setSelectedCar(String carBleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedCarId', carBleId);
    selectedCarBleId.value = carBleId;
  }

  // ✅ Notify the background service when settings change
  void _notifyService() {
    final service = FlutterBackgroundService();
    service.invoke('update_settings', {
      "automatic_connection": automaticConnectionEnabled.value,
      "selectedCarBleId": selectedCarBleId.value
    });
  }
}

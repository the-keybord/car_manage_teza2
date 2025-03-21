import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'car_service.dart';

final CarService carService = CarService();
Timer? _backgroundTimer;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  print("Initializing background service...");

  if (await service.isRunning()) {
    print("Background service already running.");
    return;
  }

  service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      autoStartOnBoot: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      autoStart: true,
    ),
  );

  bool success = await service.startService();
  if (success) {
    print("Background service started successfully!");
  } else {
    print("Failed to start background service.");
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  print("Background service is running!");

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  _backgroundTimer?.cancel();

  _backgroundTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
    final prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool('automatic_connection') ?? false;
    String savedCarBleId = prefs.getString('selectedBleDeviceId') ?? "";

    if (!isEnabled || savedCarBleId.isEmpty) {
      print("🔕 Notifications disabled or no car selected. Skipping... $isEnabled and $savedCarBleId");
      return;
    }

    print("🔍 Scanning for car: $savedCarBleId");

    bool carFound = await carService.scanForSelectedCar(savedCarBleId);

    if (carFound) {
      print("🚗 Car detected! Attempting to connect...");

      bool isConnected = await carService.connectToCar(savedCarBleId)
          .timeout(Duration(seconds: 10),onTimeout: (){print('timedOut');return false;});

      if (isConnected) {
        print("✅ Car successfully connected!");
        NotificationService.showNotification(
          "Car Connected",
          "You are now connected to your car.",
        );
      } else {
        print("❌ Failed to connect to car.");
      }
    } else {
      print("❌ Car not found.");
    }
  });

  service.on('update_settings').listen((event) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ✅ Handle BLE device change
    if (event?.containsKey('selectedBle') == true) {
      String newBleId = event!['selectedBle'];
      await prefs.setString('selectedBleDeviceId', newBleId);
      print("✅ Selected BLE device updated: $newBleId");
    }

    // ✅ Handle notifications toggle
    if (event?.containsKey('notifications') == true) {
      bool newSetting = event!['notifications'];
      await prefs.setBool('automatic_connection', newSetting);
      print(newSetting
          ? "🔔 Notifications ENABLED!"
          : "🔕 Notifications DISABLED!");
    }
  });

}

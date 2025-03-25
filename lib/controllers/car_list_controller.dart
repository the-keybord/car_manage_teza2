import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:convert';
import '../presentation/widgets/new_car_dialog.dart';


import 'auth_controller.dart';
import 'new_car_controller.dart';

class CarListController extends GetxController {
  @override
  void onInit() {
    print("📦 CarListController has been initialized");
    super.onInit();
    loadSelectedCar();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  RxString selectedCarId = ''.obs;
  RxString selectedCarName = ''.obs;
  RxString selectedBleDeviceId = ''.obs;

  /// Stream of cars owned by the logged-in user
  Stream<QuerySnapshot> get carStream {
    final user = _authController.firebaseUser.value;
    if (user == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('cars')
        .where('ownerId', isEqualTo: user.uid)
        .snapshots();
  }

  /// Load car from SharedPreferences
  Future<void> loadSelectedCar() async {
    final prefs = await SharedPreferences.getInstance();
    selectedCarId.value = prefs.getString('selectedCarId') ?? 'none';
    selectedCarName.value = prefs.getString('selectedCarName') ?? 'No Car';
    selectedBleDeviceId.value = prefs.getString('selectedBleDeviceId') ?? 'none';
  }

  /// Save selected car and notify background service
  Future<void> saveSelectedCar(String carId, String carName, String bleDeviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCarId', carId);
    await prefs.setString('selectedCarName', carName);
    await prefs.setString('selectedBleDeviceId', bleDeviceId);

    selectedCarId.value = carId;
    selectedCarName.value = carName;
    selectedBleDeviceId.value = bleDeviceId;

    final service = FlutterBackgroundService();
    print('📡 Sending BLE update to background service...');
    service.invoke('update_settings', {"selectedBle": bleDeviceId});
  }

  Future<void> checkToken(String tokenId) async {
    final user = _authController.firebaseUser.value;
    if (user == null) return;

    try {
      final tokenDoc = await _firestore.collection('sharing_tokens').doc(tokenId).get();
      if (!tokenDoc.exists) {
        Get.snackbar("Error", "Invalid or expired token");
        return;
      }

      final data = tokenDoc.data()!;
      if (data['usedBy'] != null) {
        Get.snackbar("Invalid", "This token has already been used.");
        return;
      }

      final carId = data['carId'];
      final permissions = data['permissions'] ?? {
        'canUnlock': true,
        'canStart': false,
      };

      // Grant access to car
      await _firestore.collection('cars').doc(carId).update({
        'sharedWith.${user.uid}': {
          ...permissions,
          'sharedAt': FieldValue.serverTimestamp(),
        }
      });

      // Mark token as used
      await tokenDoc.reference.update({
        'usedBy': user.uid,
        'usedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "You've been granted access to this car.");
    } catch (e) {
      Get.snackbar("Error", "Failed to claim token: $e");
    }
  }

  /// Claim a sharing token using a short code (manually entered)
  Future<void> checkShortCode(String shortCode) async {
    try {
      final query = await _firestore
          .collection('sharing_tokens')
          .where('shortCode', isEqualTo: shortCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        Get.snackbar("Not Found", "No token found for this short code.");
        return;
      }

      final tokenId = query.docs.first.id;
      await checkToken(tokenId);
    } catch (e) {
      Get.snackbar("Error", "Failed to check short code: $e");
    }
  }

  void handleScannedCode(String raw) async {
    try {
      final data = jsonDecode(raw);
      print("✅ Parsed data: $data");

      if (data is! Map || !data.containsKey('type')) {
        Get.snackbar("Error", "Unrecognized code format.");
        return;
      }

      final type = data['type'];
      print("📦 Detected QR type: $type");

      if (type == 'device' && data['name'] != null) {
        final deviceName = data['name'];
        print("📡 New device MAC: $deviceName");

        // Trigger pairing dialog (to be implemented)
        Get.dialog(
          NewCarDialog(deviceName: deviceName),
          barrierDismissible: false,
        ).then((_) {
          // ✅ Manually clean up the controller
          if (Get.isRegistered<NewCarController>()) {
            Get.delete<NewCarController>();
          }
          Get.back();
          Get.back();
        });

      } else if (type == 'token' && data['tokenId'] != null) {
        await checkToken(data['tokenId']);

      } else {
        Get.snackbar("Unknown Code", "No action available for this QR type.");
      }

    } catch (e) {
      Get.snackbar("Error", "Failed to read QR code: $e");
    }
  }

}




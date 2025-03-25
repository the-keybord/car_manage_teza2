import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'auth_controller.dart';

class NewCarController extends GetxController {
  final Guid pairingServiceUuid = Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid rxCharUuid = Guid("6e400002-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid txCharUuid = Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e");
  final RxString statusMessage = "Connecting to device...".obs;
  bool receivedKeys = false;

  RxMap<String, dynamic> keyData = <String, dynamic>{}.obs;
  BluetoothCharacteristic? _txChar;
  BluetoothCharacteristic? _rxChar;

  final String deviceName;

  NewCarController(this.deviceName);

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  late BluetoothDevice connectedDevice;
  bool found = false;

  @override
  void onInit() {
    super.onInit();
    _startPairing();
  }

  Future<void> requestPairingKeys() async {

    try {
      print("🔍 Discovering services...");
      List<BluetoothService> services = await connectedDevice.discoverServices();

      final pairingService = services.firstWhere(
            (s) => s.serviceUuid == pairingServiceUuid,
        orElse: () => throw Exception("Pairing service not found"),
      );

      _rxChar = pairingService.characteristics.firstWhere((c) => c.characteristicUuid == rxCharUuid);
      _txChar = pairingService.characteristics.firstWhere((c) => c.characteristicUuid == txCharUuid);

      await _txChar!.setNotifyValue(true);
      print("📡 Writing PAIR command...");
      await _rxChar!.write(Uint8List.fromList("PAIR".codeUnits));

      print("📡 Wrote PAIR command...");

      _txChar!.onValueReceived.listen((data) {
        print("📩 Raw bytes: $data");

        if (receivedKeys) return;
        receivedKeys = true;

        try {
          final response = utf8.decode(data);
          print("🧾 Decoded response: $response");

          final parsed = (jsonDecode(response) as Map).cast<String, dynamic>();

          if (parsed['aesKey'] != null && parsed['carKey'] != null) {
            print("✅ AES Key: ${parsed['aesKey']}, Car Key: ${parsed['carKey']}");
            keyData.value = parsed;
            isLoading.value = false;
          } else {
            print("❌ JSON missing expected keys");
            error.value = "Invalid pairing data.";
            isLoading.value = false;
          }
        } catch (e) {
          print("❌ Failed to decode or parse pairing data: $e");
          error.value = "Invalid JSON: $e";
          isLoading.value = false;
        }
      });
    } catch (e) {
      error.value = "Pairing failed: $e";
      isLoading.value = false;
    }
  }



  Future<void> _startPairing() async {
    try {
      isLoading.value = true;
      error.value = '';

      print("🔍 Starting BLE scan for device: $deviceName");

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 8),
        androidScanMode: AndroidScanMode.lowLatency,
      );

      // Listen to scan results stream
      FlutterBluePlus.scanResults.listen((results) async {
        for (final result in results) {
          final advName = result.advertisementData.advName;
          print("📡 Found device: ${result.device.remoteId.str}, name: ${advName ?? 'null'}");

          if (!found &&
              advName != null &&
              advName.toUpperCase().contains(deviceName.toUpperCase())) {
            found = true;

            connectedDevice = result.device;

            // Stop scanning
            await FlutterBluePlus.stopScan();
            _scanSubscription?.cancel();
            print("🛑 Scan stopped - target found");

            // Attempt connection
            await _connectToDevice();
          }
        }
      });
    } catch (e) {
      error.value = "Scan failed: $e";
      isLoading.value = false;
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> _connectToDevice() async {
    try {
      print("🔗 Connecting to ${connectedDevice.remoteId}");

      await connectedDevice.connect(timeout: const Duration(seconds: 10));
      await connectedDevice.requestMtu(100);
      print("✅ Successfully connected to ${connectedDevice.remoteId}");

      statusMessage.value = "Waiting for device response...";

      await requestPairingKeys();

      statusMessage.value = "Saving car...";

      // 🔜 Next steps: discover services and request keys...

      isLoading.value = false;
    } catch (e) {
      error.value = "Connection failed: $e";
      isLoading.value = false;
    }
  }

  Future<void> saveCarToFirestore({
    required String name,
    required String plate,
    required String model,
    required String color,
    File? image,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final user = Get.find<AuthController>().firebaseUser.value;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      try {
        if (connectedDevice.connectionState == BluetoothConnectionState.connected) {
          await connectedDevice.disconnect();
          print("🔌 Disconnected from ESP32");
        }
      } catch (e) {
        print("⚠️ Disconnect failed: $e");
      }

      String? photoUrl;

      // 🔼 Upload image if present
      if (image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("car_photos/${DateTime.now().millisecondsSinceEpoch}_${user.uid}.jpg");

        final uploadTask = await storageRef.putFile(image);
        photoUrl = await uploadTask.ref.getDownloadURL();
      }

      // 🧾 Build car document
      final carDoc = {
        "brand":"what?",
        "year": 0,
        "status": "what?",
        "ownerId": user.uid,
        "name": name,
        "plate": plate,
        "model": model,
        "color": color,
        "photoUrl": photoUrl,
        "aesKey": keyData['aesKey'],
        "carKey": keyData['carKey'],
        "advName": deviceName,
        "sharedWith": {},
        "createdAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('cars').add(carDoc);

      Get.back(); // ✅ Close the dialog
      Get.snackbar("Car Added", "Your car was successfully saved!");
    } catch (e) {
      error.value = "Failed to save car: $e";
    } finally {
      isLoading.value = false;
    }
  }


  @override
  void onClose() {
    _scanSubscription?.cancel();
    if (connectedDevice.connectionState == BluetoothConnectionState.connected) {
      connectedDevice.disconnect();
    }
    super.onClose();
  }
}

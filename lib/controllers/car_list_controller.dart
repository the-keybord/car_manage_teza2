import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class CarListController extends GetxController {
  @override
  void onInit() {
    print("📦 CarListController has been initialized");
    super.onInit();
    loadSelectedCar();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxString selectedCarId = ''.obs;
  RxString selectedCarName = ''.obs;
  RxString selectedBleDeviceId = ''.obs;

  Stream<QuerySnapshot> get carStream {
    final user = _auth.currentUser;
    return _firestore.collection('cars').where('ownerId', isEqualTo: user?.uid).snapshots();
  }

  Future<void> loadSelectedCar() async {
    final prefs = await SharedPreferences.getInstance();
    selectedCarId.value = prefs.getString('selectedCarId') ?? 'none';
    selectedCarName.value = prefs.getString('selectedCarName') ?? 'No Car';
    selectedBleDeviceId.value = prefs.getString('selectedBleDeviceId') ?? 'none';
  }

  Future<void> saveSelectedCar(String carId, String carName, String bleDeviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCarId', carId);
    await prefs.setString('selectedCarName', carName);
    await prefs.setString('selectedBleDeviceId', bleDeviceId);

    selectedCarId.value = carId;
    selectedCarName.value = carName;
    selectedBleDeviceId.value = bleDeviceId;

    final service = FlutterBackgroundService();
    print('try to invoke service');
    service.invoke('update_settings', {"selectedBle": bleDeviceId});
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import 'dart:math';

class CarSharingController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _authController = Get.find<AuthController>();
  final RxnString generatedTokenId = RxnString();
  final RxnString generatedShortCode = RxnString();

  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  /// Key: carId → Value: List of shared user info
  RxMap<String, List<Map<String, dynamic>>> sharedUsersByCar =
      <String, List<Map<String, dynamic>>>{}.obs;

  /// Load full shared user info (for dialog: email, photo, permissions)
  Future<void> loadSharedUsers(String carId) async {
    final carDoc = await _firestore.collection('cars').doc(carId).get();
    final sharedWith = carDoc.data()?['sharedWith'] ?? {};

    List<Map<String, dynamic>> users = [];

    for (var userId in sharedWith.keys) {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        users.add({
          'userId': userId, // ✅ add user ID here
          'email': userDoc['email'],
          'photoURL': userDoc['photoURL'],
          'canUnlock': sharedWith[userId]['canUnlock'] ?? false,
          'canStart': sharedWith[userId]['canStart'] ?? false,
        });
      }
    }

    sharedUsersByCar[carId] = users;
  }

  String _generateShortCode() {
    const length = 6;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure(); // More secure than Random()

    return 'SHR-' + List.generate(length, (_) {
      final index = rand.nextInt(chars.length);
      return chars[index];
    }).join();
  }

  Future<void> generateSharingToken(String carId) async {
    final user = _authController.firebaseUser.value;
    if (user == null) return;

    try {
      final shortCode = _generateShortCode();

      final docRef = await _firestore.collection('sharing_tokens').add({
        'carId': carId,
        'createdBy': user.uid,
        'usedBy': null,
        'permissions': {
          'canUnlock': true,
          'canStart': false,
        },
        'shortCode': shortCode,
        'createdAt': FieldValue.serverTimestamp(),
      });

      generatedTokenId.value = docRef.id;
      generatedShortCode.value = shortCode;
    } catch (e) {
      Get.snackbar("Error", "Failed to generate share token: $e");
    }
  }



  /// Load only avatar info for compact use (e.g., share button)
  Future<void> loadAvatars(String carId) async {
    final carDoc = await _firestore.collection('cars').doc(carId).get();
    final sharedWith = carDoc.data()?['sharedWith'] ?? {};

    List<Map<String, dynamic>> users = [];

    for (var userId in sharedWith.keys) {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        users.add({
          'email': userDoc['email'],
          'photoURL': userDoc['photoURL'],
        });
      }
    }

    sharedUsersByCar[carId] = users;
  }

  Future<void> shareCar({required String carId}) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      errorMessage.value = "Please enter an email address.";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        errorMessage.value = "User not found.";
        isLoading.value = false;
        return;
      }

      final sharedUserDoc = userQuery.docs.first;
      final sharedUserId = sharedUserDoc.id;

      await _firestore.collection('cars').doc(carId).update({
        'sharedWith.$sharedUserId': {
          'canUnlock': true,
          'canStart': false,
          'sharedAt': FieldValue.serverTimestamp(),
        }
      });

      emailController.clear();
      Get.back();
      Get.snackbar("Success", "Car shared with $email");

      // Refresh shared user list for this car
      await loadSharedUsers(carId);
    } catch (e) {
      errorMessage.value = "Error sharing car: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void clearGeneratedToken() {
    generatedTokenId.value = null;
    generatedShortCode.value = null;
  }

  Future<void> revokeAccess({
    required String carId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('cars').doc(carId).update({
        'sharedWith.$userId': FieldValue.delete(),
      });

      // Refresh the list for the dialog
      await loadSharedUsers(carId);
      Get.snackbar("Access Revoked", "User access has been removed.");
    } catch (e) {
      Get.snackbar("Error", "Failed to revoke access: $e");
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}

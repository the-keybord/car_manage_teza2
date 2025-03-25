import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/new_car_controller.dart';
import 'car_info_form.dart'; // adjust path if needed


class NewCarDialog extends StatelessWidget {
  final String deviceName;

  const NewCarDialog({super.key, required this.deviceName});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewCarController(deviceName));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(controller.statusMessage.value),
              ],
            );
          } else if (controller.error.value.isNotEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Error", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(controller.error.value),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                ),
              ],
            );
          } else if (controller.keyData.isNotEmpty) {
            return CarInfoForm(
              onSubmit: ({
                required String name,
                required String plate,
                required String model,
                required String color,
                File? image,
              }) {
                controller.saveCarToFirestore(
                  name: name,
                  plate: plate,
                  model: model,
                  color: color,
                  image: image,
                );
              },
            );
          } else {
            return const Text("✅ Connected! Waiting for keys...");
          }
        }),
      ),
    );
  }
}

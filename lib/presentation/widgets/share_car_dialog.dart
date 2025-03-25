import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../controllers/car_sharing_controller.dart';

class ShareCarDialog extends StatefulWidget {
  final String carId;

  const ShareCarDialog({super.key, required this.carId});

  @override
  State<ShareCarDialog> createState() => _ShareCarDialogState();
}

class _ShareCarDialogState extends State<ShareCarDialog> {
  final controller = Get.find<CarSharingController>();

  @override
  void initState() {
    super.initState();
    controller.generateSharingToken(widget.carId);
  }

  @override
  void dispose() {
    controller.clearGeneratedToken();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          final tokenId = controller.generatedTokenId.value;
          final shortCode = controller.generatedShortCode.value;

          if (tokenId == null || shortCode == null) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Share via QR Code",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              QrImageView(
                data: jsonEncode({'tokenId': tokenId}),
                version: QrVersions.auto,
                size: 200,
              ),

              const SizedBox(height: 16),
              Text("Or use this code:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              SelectableText(
                shortCode,
                style: const TextStyle(fontSize: 20, letterSpacing: 1.5),
              ),

              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              )
            ],
          );
        }),
      ),
    );
  }
}

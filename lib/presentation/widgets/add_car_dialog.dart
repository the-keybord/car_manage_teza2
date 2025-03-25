import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../controllers/car_list_controller.dart';

class AddCarDialog extends StatefulWidget {
  const AddCarDialog({super.key});

  @override
  State<AddCarDialog> createState() => _AddCarDialogState();
}

class _AddCarDialogState extends State<AddCarDialog> {
  final _shortCodeController = TextEditingController();
  final _controller = Get.find<CarListController>();

  String? scannedTokenId;

  @override
  void dispose() {
    _shortCodeController.dispose();
    super.dispose();
  }

  void _submit() {
    final shortCode = _shortCodeController.text.trim();

    if (shortCode.isNotEmpty) {
      _controller.checkShortCode(shortCode);
      Navigator.of(context).pop(); // Close dialog
    } else if (scannedTokenId != null) {
      _controller.checkToken(scannedTokenId!);
      Navigator.of(context).pop(); // Close dialog
    } else {
      Get.snackbar("Missing Input", "Please enter a code or scan a QR.");
    }
  }

  Future<void> _openQrScanner() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const _QrScannerDialog(),
    );

    if (result != null && result.isNotEmpty) {
      _controller.handleScannedCode(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenHint = scannedTokenId != null
        ? "QR scanned and ready!"
        : "Or scan a QR code instead";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Join a Shared Car", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _shortCodeController,
                    decoration: const InputDecoration(
                      labelText: "Enter Short Code",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: "Scan QR Code",
                  onPressed: _openQrScanner,
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(tokenHint, style: TextStyle(color: Colors.grey[600], fontSize: 13)),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text("Join"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class _QrScannerDialog extends StatelessWidget {
  const _QrScannerDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 400,
        child: Stack(
          children: [
            MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                final value = barcode.rawValue;
                if (value != null) {
                  Navigator.of(context).pop(value); // Return scanned value
                }
              },
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:car_manage_teza2/presentation/widgets/shared_user_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/car_sharing_controller.dart';
import '../widgets/share_car_dialog.dart'; // import your new dialog

class CarSharingDialog extends StatefulWidget {
  final String carId;
  final String carName;

  const CarSharingDialog({
    super.key,
    required this.carId,
    required this.carName,
  });

  @override
  State<CarSharingDialog> createState() => _CarSharingDialogState();
}

class _CarSharingDialogState extends State<CarSharingDialog> {
  late final CarSharingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CarSharingController>();
    controller.loadSharedUsers(widget.carId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Dialog(
      insetPadding: const EdgeInsets.all(16), // margins from screen edges
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: screenWidth > 600 ? 500 : screenWidth * 0.9, // responsive width
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            final shared = controller.sharedUsersByCar[widget.carId] ?? [];

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Share ${widget.carName}", style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge),

                const SizedBox(height: 20),

                // 🔹 Cards for each user
                ...shared.map((user) {
                  return SharedUserCard(
                    email: user['email'],
                    photoUrl: user['photoURL'],
                    canUnlock: user['canUnlock'] ?? false,
                    canStart: user['canStart'] ?? false,
                    userId: user['userId'],
                    carId: widget.carId,
                  );
                }),

                const SizedBox(height: 12),

                // ➕ Share button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text("Share Car"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius
                          .circular(12)),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ShareCarDialog(carId: widget.carId),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // ✖ Close
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}

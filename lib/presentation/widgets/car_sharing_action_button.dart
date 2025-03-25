import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/car_sharing_controller.dart';

class CarSharingActionButton extends StatefulWidget {
  final String carId;
  final VoidCallback onTap;

  const CarSharingActionButton({
    super.key,
    required this.carId,
    required this.onTap,
  });

  @override
  State<CarSharingActionButton> createState() => _CarSharingActionButtonState();
}

class _CarSharingActionButtonState extends State<CarSharingActionButton> {
  late final CarSharingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CarSharingController>();
    controller.loadAvatars(widget.carId); // Load only once
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Obx(() {
      final shared = controller.sharedUsersByCar[widget.carId] ?? [];

      return InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: widget.onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatars
              ...List.generate(
                shared.length.clamp(0, 3),
                    (index) {
                  final url = shared[index]['photoURL'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.white,
                      backgroundImage: url != null ? NetworkImage(url) : null,
                      child: url == null
                          ? const Icon(Icons.person, size: 12)
                          : null,
                    ),
                  );
                },
              ),

              if (shared.isNotEmpty)
                const SizedBox(width: 4),

              const Icon(Icons.share, size: 18, color: Colors.white),
            ],
          ),
        ),
      );
    });
  }
}

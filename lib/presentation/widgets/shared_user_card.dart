import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/car_sharing_controller.dart';

class SharedUserCard extends StatefulWidget {
  final String email;
  final String? photoUrl;
  final bool canUnlock;
  final bool canStart;
  final String userId; // 👈 New
  final String carId;  // 👈 New

  const SharedUserCard({
    super.key,
    required this.email,
    required this.photoUrl,
    required this.canUnlock,
    required this.canStart,
    required this.userId,
    required this.carId,
  });

  @override
  State<SharedUserCard> createState() => _SharedUserCardState();
}

class _SharedUserCardState extends State<SharedUserCard> {
  bool isExpanded = false;
  final controller = Get.find<CarSharingController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
              widget.photoUrl != null ? NetworkImage(widget.photoUrl!) : null,
              child: widget.photoUrl == null ? const Icon(Icons.person) : null,
            ),
            title: Text(widget.email),
            subtitle: Text(
              'Unlock: ${widget.canUnlock} • Start: ${widget.canStart}',
            ),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
            ),
          ),

          // 🔽 Expanded area
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🔧 Placeholder for future toggles or buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Options coming soon..."),
                      Icon(Icons.tune),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ❌ Revoke Access button
                  ElevatedButton.icon(
                    onPressed: () async {
                      await controller.revokeAccess(
                        carId: widget.carId,
                        userId: widget.userId,
                      );
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text("Revoke Access"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                  )
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

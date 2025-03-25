import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class AccountPopupButton extends StatelessWidget {
  const AccountPopupButton({super.key});

  void _showAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return const Center(
          child: AccountPopupCard(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final photoUrl = authController.photoURL.value;

      return IconButton(
        onPressed: () => _showAccountDialog(context),
        icon: photoUrl != null
            ? CircleAvatar(
          radius: 16, // Adjust as needed
          backgroundImage: NetworkImage(photoUrl),
          backgroundColor: Colors.transparent,
        )
            : const Icon(Icons.account_circle_rounded, size: 32),
        tooltip: "Account",
      );
    });
  }

}

class AccountPopupCard extends StatelessWidget {
  const AccountPopupCard({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.firebaseUser.value;

    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 10,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final url = authController.photoURL.value;

              return CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.primary,
                backgroundImage: url != null ? NetworkImage(url) : null,
                child: url == null
                    ? const Icon(Icons.person, size: 30, color: Colors.white)
                    : null,
              );
            }),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? "No Name",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user?.email ?? "no-email@example.com",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.outline),
            ),
            const Divider(height: 32),
            ListTile(
              leading: Icon(Icons.settings, color: colorScheme.primary),
              title: const Text("Account Settings"),
              onTap: () {
                Navigator.of(context).pop();
                // Optionally navigate to a settings page
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: colorScheme.primary),
              title: const Text("Privacy"),
              onTap: () {
                Navigator.of(context).pop();
                // Optionally navigate to privacy page
              },
            ),
            const Divider(height: 32),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Get.find<AuthController>().signOut(); // 👈 Logout via controller
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Logout", style: TextStyle(color: Colors.red)),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

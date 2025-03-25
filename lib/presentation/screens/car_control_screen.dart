import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/car_controller.dart';
import '../widgets/car_card.dart';

class CarControlScreen extends StatelessWidget {
  final String carName;
  final String carId;

  CarControlScreen({
    required this.carName,
    required this.carId,
  });

  final CarController carController = Get.find<CarController>();

  void _sendCommand(BuildContext context, String command) async {
    bool success = await carController.sendCommand(command);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 300),
        content: Text(success ? "✅ Command Sent" : "❌ Failed to Send Command"),
      ),
    );
  }

  Widget circularButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    double size = 80,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(0),
            ),
            child: Icon(icon, size: size / 2),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          // 🔷 Jumătatea de sus: Card cu info mașină
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CarCard(
                carId: carId, // make sure you have this available in the screen
                name: carName,
                plate: 'plate',
                model: 'model',
                color: 'color',
                photoUrl: 'https://firebasestorage.googleapis.com/v0/b/car-manage2.firebasestorage.app/o/car_photos%2F1742940155750_pZvO5663LsXpvvKOW0Vk53SXFF12.jpg?alt=media&token=1d006a77-fb0f-4299-813f-9527c5e3607e', // or null if not available
                expanded: true, // this is control screen, so go expanded
              ),
            ),
          ),


          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 0,
                          child: circularButton(
                            icon: Icons.play_arrow,
                            label: 'Start',
                            onPressed: () => _sendCommand(context, "LOCK"),
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          left: 0,
                          child: circularButton(
                            icon: Icons.lock,
                            label: 'Lock',
                            onPressed: () => _sendCommand(context, "LOCK"),
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          right: 0,
                          child: circularButton(
                            icon: Icons.lock_open,
                            label: 'Unlock',
                            onPressed: () => _sendCommand(context, "UNLOCK"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔻 Buton mic jos dreapta
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: TextButton.icon(
                    onPressed: () => carController.disconnectCar(),
                    icon: const Icon(Icons.logout),
                    label: const Text("Disconnect"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text(carName)),
  //     body: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         ElevatedButton(
  //           onPressed: () => _sendCommand(context, "LOCK"),
  //           child: Text("🔒 Lock Car"),
  //         ),
  //         SizedBox(height: 20),
  //         ElevatedButton(
  //           onPressed: () => _sendCommand(context, "UNLOCK"),
  //           child: Text("🔓 Unlock Car"),
  //         ),
  //         SizedBox(height: 20),
  //         ElevatedButton(
  //           onPressed: () => carController.disconnectCar(),
  //           child: Text("🔌 Disconnect"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

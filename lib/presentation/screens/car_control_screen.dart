import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/car_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(carName)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _sendCommand(context, "LOCK"),
            child: Text("🔒 Lock Car"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _sendCommand(context, "UNLOCK"),
            child: Text("🔓 Unlock Car"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => carController.disconnectCar(),
            child: Text("🔌 Disconnect"),
          ),
        ],
      ),
    );
  }
}

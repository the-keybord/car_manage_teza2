import 'package:flutter/material.dart';
import '../car_service.dart';

class CarControlScreen extends StatefulWidget {
  final CarService carService; // ✅ Use CarService
  final String carName;
  final String carId;

  CarControlScreen({
    required this.carService,
    required this.carName,
    required this.carId,
  });

  @override
  _CarControlScreenState createState() => _CarControlScreenState();
}

class _CarControlScreenState extends State<CarControlScreen> {
  Future<void> _sendCommand(String command) async {
    bool success = await widget.carService.sendCommand(command);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(milliseconds: 300),content: Text(success ? "✅ Command Sent" : "❌ Failed to Send Command")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.carName)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _sendCommand("LOCK"),
            child: Text("🔒 Lock Car"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _sendCommand("UNLOCK"),
            child: Text("🔓 Unlock Car"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.carService.disconnectCar,
            child: Text("🔌 Disconnect"),
          ),
        ],
      ),
    );
  }
}

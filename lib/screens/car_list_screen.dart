import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class CarListScreen extends StatefulWidget {
  final Function(String carId, String carName, String bleDeviceId) onCarSelected;

  CarListScreen({required this.onCarSelected});

  @override
  _CarListScreenState createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedCarId; // Stores the selected car ID
  String? selectedCarName;
  String? selectedBleDeviceId;

  @override
  void initState() {
    super.initState();
    _loadSelectedCar(); // Load previously selected car from SharedPreferences
  }

  // Load the selected car from SharedPreferences
  Future<void> _loadSelectedCar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCarId = prefs.getString('selectedCarId');
      selectedCarName = prefs.getString('selectedCarName');
      selectedBleDeviceId = prefs.getString('selectedBleDeviceId');
      print(selectedBleDeviceId);
    });
  }

  // Save the selected car to SharedPreferences
  Future<void> _saveSelectedCar(String carId, String carName, String bleDeviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCarId', carId);
    await prefs.setString('selectedCarName', carName);
    await prefs.setString('selectedBleDeviceId', bleDeviceId);
    final service = FlutterBackgroundService();
    service.invoke('update_settings', {"selectedBle": bleDeviceId});
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) return Center(child: Text("Please log in"));

    return Scaffold(
      appBar: AppBar(title: Text("My Cars")),
      body: StreamBuilder(
        stream: _firestore.collection('cars').where('ownerId', isEqualTo: user.uid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No cars found"));
          }

          final cars = snapshot.data!.docs;


          return ListView.builder(
            itemCount: cars.length + 1, // +1 for the placeholder
            itemBuilder: (context, index) {
              // 👇 Index 0 is our placeholder
              if (index == 0) {
                return ListTile(
                  title: Text("🚫 No Car Selected"),
                  subtitle: Text("Tap to deselect current car"),
                  tileColor: selectedCarId == 'none' ? Colors.blue.withOpacity(0.2) : null,
                  onTap: () {
                    setState(() {
                      selectedCarId = 'none';
                      selectedCarName = 'No Car';
                      selectedBleDeviceId = 'none';
                    });

                    _saveSelectedCar('none', 'No Car', 'none');
                    widget.onCarSelected('none', 'No Car', 'none');
                  },
                );
              }

              // 👇 Adjust index for the rest of the cars
              var car = cars[index - 1].data() as Map<String, dynamic>;
              String carId = cars[index - 1].id;
              String carName = car['name'] ?? "Unknown Car";
              String bleDeviceId = car['bleDeviceId'] ?? "";

              return ListTile(
                title: Text(carName),
                subtitle: Text("${car['brand']} - ${car['year']}"),
                trailing: Text(car['status']),
                tileColor: selectedCarId == carId ? Colors.blue.withOpacity(0.2) : null,
                onTap: () {
                  if (bleDeviceId.isNotEmpty) {
                    setState(() {
                      selectedCarId = carId;
                      selectedCarName = carName;
                      selectedBleDeviceId = bleDeviceId;
                    });

                    _saveSelectedCar(carId, carName, bleDeviceId);
                    widget.onCarSelected(carId, carName, bleDeviceId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("⚠ No BLE device linked to this car")),
                    );
                  }
                },
              );
            },
          );

        },
      ),
    );
  }
}

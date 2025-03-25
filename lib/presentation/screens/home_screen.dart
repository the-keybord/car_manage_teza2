import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../services/car_service.dart';
import 'car_list_screen.dart';
import 'car_control_screen.dart';
import 'options_screen.dart';
import '../widgets/account_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthController authController = Get.find<AuthController>();
  final CarService carService = CarService();

  String? selectedCarName;
  String? selectedCarId;

  @override
  void initState() {
    super.initState();
    // No need to listen to auth here — it's handled globally via AuthWrapper
  }

  // Called when user selects a car
  Future<void> _onCarSelected(String carId, String carName, String bleDeviceId) async {
    bool success = await carService.connectToSelectedCar();
    selectedCarId = carId;
    selectedCarName = carName;
    if (success) {
      setState(() {
        _selectedIndex = 1; // Switch to Control Screen
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Could not connect to car")),
      );
    }
  }

  List<Widget> _getScreens() {
    return [
      CarListScreen(onCarSelected: _onCarSelected),
      CarControlScreen(
        carName: selectedCarName ?? "Unknown",
        carId: selectedCarId ?? "",
      ),
      OptionsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Manager"),
        actions: const [
          AccountPopupButton(),
        ],
      ),
      body: _getScreens()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Cars"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_remote), label: "Control"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Options"),
        ],
      ),
    );
  }
}

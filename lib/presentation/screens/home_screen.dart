import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';
import 'car_list_screen.dart';
import 'car_control_screen.dart';
import 'options_screen.dart'; // ✅ Added Options Screen
import '../../services/car_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CarService carService = CarService(); // ✅ Use CarService
  String? selectedCarName;
  String? selectedCarId;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
      }
    });
  }

  // ✅ Called when user selects a car from `CarListScreen`
  Future<void> _onCarSelected(String carId, String carName, String bleDeviceId) async {
    bool success = await carService.connectToSelectedCar();
    if (success) {
      setState(() {
        selectedCarId = carId;
        selectedCarName = carName;
        _selectedIndex = 1; // ✅ Switch to CarControlScreen
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Could not connect to car")),
      );
    }
  }

  // ✅ Screens for the Bottom Navigation Bar
  List<Widget> _getScreens() {
    return [
      CarListScreen(onCarSelected: _onCarSelected), // ✅ Select Car
      CarControlScreen(
        carName: selectedCarName ?? "Unknown",
        carId: selectedCarId ?? "",
      ),
      OptionsScreen(), // ✅ Added Options Screen
    ];
  }

  // ✅ Logout Function
  void _logout() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return AuthScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Car Manager"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Cars"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_remote), label: "Control"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Options"), // ✅ Options added
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'auth_screen.dart';
import 'background_service.dart';
import 'notification_service.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  Get.put(SettingsController());

  //await initializeService();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthCheck(),  // ✅ Check if user is logged in
    );
  }
}

// ✅ This widget decides which screen to show
class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),  // 🔍 Listen for auth state
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());  // Loading state
        }
        if (snapshot.hasData) {
          return HomeScreen();  // ✅ User is logged in → Go to HomeScreen
        }
        return AuthScreen();  // ❌ No user → Show Login Screen
      },
    );
  }
}

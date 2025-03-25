import 'package:car_manage_teza2/controllers/car_sharing_controller.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:car_manage_teza2/background_service.dart';
import 'services/notification_service.dart';
import 'package:get/get.dart';
import 'controllers/car_controller.dart';
import 'controllers/car_list_controller.dart';
import 'controllers/auth_controller.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/auth_screen.dart';
import 'package:dynamic_color/dynamic_color.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  await initializeService();

  // Initialize all controllers here
  Get.put(AuthController());
  Get.put(CarController());
  Get.put(CarListController());
  Get.put(CarSharingController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme lightColorScheme =
            lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue);
        final ColorScheme darkColorScheme = darkDynamic ??
            ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            );

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Car Management',
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: AuthWrapper(),
          getPages: [
            GetPage(name: '/auth', page: () => AuthScreen()), // 👈 This must exist!
            GetPage(name: '/home', page: () => HomeScreen()),
          ],
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (authController.firebaseUser.value == null) {
        return AuthScreen(); // Not logged in
      } else {
        print('wtf');
        return HomeScreen(); // Logged in
      }
    });
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class AuthScreen extends StatelessWidget {
  final AuthController authController = Get.find();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Obx(() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    authController.isLogin.value ? "Welcome Back" : "Create Account",
    style: Theme.of(context)
        .textTheme
        .displayMedium
        ?.copyWith(fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 10),
    Text(
    authController.isLogin.value
    ? "Login to your account"
        : "Sign up with your email",
    style: Theme.of(context).textTheme.bodyLarge,
    ),
    const SizedBox(height: 30),
    Form(
    key: _formKey,
    child: Column(
    children: [
    TextFormField(
    controller: emailController,
    decoration: InputDecoration(
    labelText: "Email",
    prefixIcon: Icon(Icons.email),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
    ),
    validator: (value) => value == null || value.isEmpty
    ? "Enter your email"
        : null,
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: passwordController,
    decoration: InputDecoration(
    labelText: "Password",
    prefixIcon: Icon(Icons.lock),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
    ),
    obscureText: true,
    validator: (value) =>
    value == null || value.length < 6 ? "Minimum 6 characters" : null,
    ),
    const SizedBox(height: 24),
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: authController.isLoading.value
    ? null
        : () {
    if (_formKey.currentState!.validate()) {
    authController.submitAuth(
    emailController.text.trim(),
    passwordController.text.trim(),
    );
    }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Get.theme.colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(5)),
    ),
    child: Text(
    authController.isLogin.value ? "Login" : "Sign Up",
    style: TextStyle(fontSize: 16),
    ),
    ),
    ),
    TextButton(
    onPressed: () => authController.toggleAuthMode(),
    child: Text(
    authController.isLogin.value
    ? "Create an account"
        : "Already have an account? Login",
    ),
    ),
    const SizedBox(height: 20),
    Divider(thickness: 1),
    const SizedBox(height: 16),
    ElevatedButton.icon(
    icon: Icon(Icons.account_circle),
    label: Text("Sign in with Google"),
    onPressed: authController.isLoading.value
    ? null
        : () => authController.signInWithGoogle(),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red.shade400,
    foregroundColor: Colors.white,

        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    ),
      if (authController.isLoading.value) ...[
        const SizedBox(height: 20),
        CircularProgressIndicator(),
      ]
    ],
    ),
    ),
          ],
        )),
    ),
    ),
    );
  }
}

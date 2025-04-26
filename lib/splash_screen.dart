import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import for Lottie animations
import 'package:treemate/controllers/user_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));
    // Check if the user is logged in
    bool isLoggedIn = await _userController.isLoggedIn();
    // Navigate to the appropriate screen based on login status
    if (isLoggedIn) {
      await _userController.loadUserDetails(context);
      Navigator.pushReplacementNamed(context, '/main_screen');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Size constants
    double height = MediaQuery.of(context).size.height;
    double gap = height * 0.015;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/splash.json',
              width: width * 0.5,
              height: height * 0.5,
              fit: BoxFit.contain,
            ),
            // SizedBox(height: gap),
            const Text(
              "Welcome to TREEmate",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(43, 147, 72, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

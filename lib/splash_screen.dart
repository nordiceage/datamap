import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:treemate/controllers/user_controller.dart';

/// SplashScreen is a StatefulWidget that displays an introductory animation
/// and checks the user's login status.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}
/// _SplashScreenState is the state class for the SplashScreen widget.
class _SplashScreenState extends State<SplashScreen> {
  /// _userController is an instance of UserController to manage user-related operations.
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    // Call _checkLoginStatus method when the widget initializes
    _checkLoginStatus();
  }
  /// _checkLoginStatus checks if the user is logged in and navigates to the appropriate screen.
  Future<void> _checkLoginStatus() async {
    // Delay for 3 seconds to show the splash screen
    await Future.delayed(const Duration(seconds: 3));
    // Check if the user is logged in using the user controller
    bool isLoggedIn = await _userController.isLoggedIn();
    // If the user is logged in
    if (isLoggedIn) {
      // Load the user details
      await _userController.loadUserDetails(context);
      // Navigate to the main screen
      Navigator.pushReplacementNamed(context, '/main_screen');
    } else {
      // Navigate to the login screen if not logged in
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen height for dynamic sizing
    double height = MediaQuery.of(context).size.height;
    // Get screen width for dynamic sizing
    double width = MediaQuery.of(context).size.width;

    // Scaffold is a basic layout structure
    return Scaffold(
      // Center widget positions its child in the middle of the screen
      body: Center(
        // Column widget arranges its children in a vertical sequence
        child: Column(
          // Center the column's children vertically
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie.asset displays an animated splash screen
            Lottie.asset(
              'assets/animations/splash.json',
              width: width * 0.5,
              height: height * 0.5,
              fit: BoxFit.contain,
            ),
            // SizedBox(height: gap),
            // Text widget to display the welcome message
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

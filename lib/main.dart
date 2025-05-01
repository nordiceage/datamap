// Import necessary Flutter packages.
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// Import project-specific files.
import 'package:treemate/main_pages/garden_page.dart';
import 'package:treemate/plant/controllers/plant_controller.dart';
import 'package:treemate/providers/user_provider.dart';
import 'package:treemate/splash_screen.dart';
import 'Auth_pages/auth.dart';
import 'theme.dart';
import 'main_screen.dart';
import 'profile/profile_edit.dart';
import 'services/u_checker.dart';
import 'controllers/scroll_controller.dart';

/// The main entry point for the Flutter application.
void main() async {
  // Ensure that the Flutter framework has been initialized.
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from the .env file.
  await dotenv.load(fileName: ".env"); 
  // Initialize the PlantsController instance.
  final plantsController = PlantsController();
  await plantsController.init();
  // Run the app and provide the ScrollControllers using ChangeNotifierProvider.
  runApp(
    ChangeNotifierProvider(
      // Create an instance of ScrollControllers.
      create: (context) => ScrollControllers(),
      // The root widget of the application.
      child: const MyApp(),
    ),
  );
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide multiple providers using MultiProvider.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'TREEmate',
        theme: AppTheme.themeData,
        home: const UpdateWrapper(child: SplashScreen()),
        // Define named routes for navigation.
        routes: {
          '/main_screen': (context) => const MainScreen(),
          '/Edit_Profile': (context) => const EditProfileWidget(),
          '/signup': (context) => const SignupPage(),
          '/login': (context) => const LoginPage(),
          '/otp': (context) => const OtpPage(),
          '/create-password': (context) => const CreatePasswordPage(),
          '/forget-password': (context) => const ForgetPasswordPage(),
          '/garden': (context) => const MyGardenPage(),
        },
      ),
    );
  }
}

/// A wrapper widget that checks for updates before displaying the child widget.
class UpdateWrapper extends StatefulWidget {
  final Widget child;

  /// Constructor for UpdateWrapper, requiring a child widget.
  const UpdateWrapper({super.key, required this.child});

  @override
  _UpdateWrapperState createState() => _UpdateWrapperState();
}

/// State class for UpdateWrapper.
class _UpdateWrapperState extends State<UpdateWrapper> {
  // State variables to track checking and proceeding status.
  bool _isChecking = true;
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    // Check for updates when the widget initializes.
    checkUpdate();
  }

  /// Method to check for updates using UpdateChecker.
  Future<void> checkUpdate() async {
    // Set _isChecking to true to indicate that the update check is in progress.
    setState(() {
      _isChecking = true;
    });
    // Try to check for updates.
    try {
      bool canProceed = await UpdateChecker.checkForUpdate(context);
      setState(() {
        _canProceed = canProceed;
        _isChecking = false;
      });
    } catch (e) {
      // Handle errors during the update check.
      print("Error checking for updates: $e");
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display a loading indicator while checking for updates.
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (!_canProceed) {
       // Display a message if unable to proceed and provide a retry button.
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                  'Unable to proceed. Please check your internet connection.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: checkUpdate,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    // If able to proceed, display the child widget.
    } else {
      return widget.child;
    }
  }
}

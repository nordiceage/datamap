import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:treemate/main_pages/garden_page.dart';
import 'package:treemate/plant/controllers/plant_controller.dart';
import 'package:treemate/providers/user_provider.dart';
import 'package:treemate/splash_screen.dart';
import 'Auth_pages/auth.dart';
import 'theme.dart';
import 'controllers/scroll_controller.dart';
import 'main_screen.dart';
import 'profile/profile_edit.dart';
import 'services/u_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure the environment variables are loaded before the app starts
  await dotenv.load(fileName: ".env");
  final plantsController = PlantsController();
  await plantsController.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ScrollControllers(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'TREEmate',
        theme: AppTheme.themeData,
        home: const UpdateWrapper(child: SplashScreen()),
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

class UpdateWrapper extends StatefulWidget {
  final Widget child;

  const UpdateWrapper({super.key, required this.child});

  @override
  _UpdateWrapperState createState() => _UpdateWrapperState();
}

class _UpdateWrapperState extends State<UpdateWrapper> {
  bool _isChecking = true;
  bool _canProceed = false;

  @override
  void initState() {
    super.initState();
    checkUpdate();
  }

  Future<void> checkUpdate() async {
    setState(() {
      _isChecking = true;
    });

    try {
      bool canProceed = await UpdateChecker.checkForUpdate(context);
      setState(() {
        _canProceed = canProceed;
        _isChecking = false;
      });
    } catch (e) {
      print("Error checking for updates: $e");
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (!_canProceed) {
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
    } else {
      return widget.child;
    }
  }
}

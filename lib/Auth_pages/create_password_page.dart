import 'package:flutter/material.dart';
import 'package:treemate/controllers/user_controller.dart';
import 'package:treemate/services/validator.dart';
import 'package:treemate/widgets/custom_button.dart';
import 'package:treemate/widgets/custom_text_field.dart';

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({super.key});

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  late final UserController _userController;

  @override
  void initState() {
    super.initState();
    _userController = UserController();
    _userController.init(context);
  }

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Received arguments
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String name = args['name'] ?? "";
    final String email = args['email'];
    final bool isResetPassword = args['resetPassword'] ?? false;

    // Size constants
    double pageHeight = MediaQuery.of(context).size.height;
    double pageWidth = MediaQuery.of(context).size.width;
    double pad = pageWidth * 0.05;
    double spaceBetween = pageHeight * 0.05;
    double buttonHeight = pageHeight * 0.06;
    double buttonWidth = pageWidth * 0.8;
    double textSize = pageHeight * 0.03;

    return GestureDetector(
      onTap: () {
        // Unfocus all input fields when tapping outside of them
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Image.asset('assets/image/create_password.png'),
                  SizedBox(height: spaceBetween),
                  Center(
                    child: Text(
                      'Create Password',
                      style: TextStyle(
                        fontSize: textSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: spaceBetween * 0.25),
                  Center(
                    child: Text(
                      'Secure your account',
                      style: TextStyle(
                        fontSize: textSize * 0.7,
                        color: const Color.fromRGBO(115, 115, 115, 1),
                      ),
                    ),
                  ),
                  SizedBox(height: spaceBetween),
                  CustomTextField(
                    icon: Icons.lock_open_outlined,
                    hintText: 'New Password',
                    textEditingController: passwordController,
                    isPassword: true,
                    inputType: TextInputType.text,
                    validator: Validators.validatePassword,
                  ),
                  SizedBox(height: spaceBetween * 0.5),
                  CustomTextField(
                    icon: Icons.lock_outline,
                    hintText: 'Confirm Password',
                    textEditingController: confirmPasswordController,
                    isPassword: true,
                    inputType: TextInputType.text,
                    validator: (value) {
                      // Check if the confirm password matches the new password
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return Validators.validatePassword(
                          value); // Also validate the password
                    },
                  ),
                  SizedBox(height: spaceBetween * 0.5),
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      'Password should contain a minimum of 8 characters, including a mix of letters  Capital and small, numbers, and symbols.',
                      style: TextStyle(
                        fontSize: textSize * 0.6,
                        color: const Color.fromRGBO(115, 115, 115, 1),
                      ),
                    ),
                  ),
                  SizedBox(height: spaceBetween),
                  CustomButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() == true) {
                        if (isResetPassword) {
                          final success = await _userController.resetPassword(
                              context, email, passwordController.text);
                          if (success) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (route) => false);
                          }
                        } else {
                          final success = await _userController.signUp(
                              context, email, passwordController.text, name);
                          if (success) {
                            final loginSuccess = await _userController.login(
                                context, email, passwordController.text);
                            if (loginSuccess) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/main_screen', (route) => false);
                            } else {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/login', (route) => false);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to sign up! Recheck your password'),
                              ),
                            );
                          }
                        }
                      }
                    },
                    buttonText: "Create",
                    buttonHeight: buttonHeight,
                    buttonWidth: buttonWidth,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

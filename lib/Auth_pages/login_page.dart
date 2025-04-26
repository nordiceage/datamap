import 'package:flutter/material.dart';
import 'package:treemate/services/validator.dart';
import 'package:treemate/widgets/custom_button.dart';
import 'package:treemate/widgets/custom_text_field.dart';
import 'package:treemate/controllers/user_controller.dart'; // Import your UserController

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final UserController _userController;

  @override
  void initState() {
    super.initState();
    _userController = UserController();
    _userController.init(context);
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                  Image.asset('assets/image/login.png'),
                  SizedBox(height: spaceBetween),
                  Center(
                    child: Text(
                      'Hello Again',
                      style: TextStyle(
                          fontSize: textSize, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: spaceBetween * 0.25),
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      'Welcome back, you have been missed!',
                      style: TextStyle(
                          fontSize: textSize * 0.7,
                          color: const Color.fromRGBO(115, 115, 115, 1)),
                    ),
                  ),
                  SizedBox(height: spaceBetween),
                  CustomTextField(
                    icon: Icons.email_outlined,
                    hintText: 'Email',
                    textEditingController: emailController,
                    inputType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  SizedBox(height: spaceBetween * 0.5),
                  CustomTextField(
                    icon: Icons.lock_outline,
                    hintText: 'Password',
                    textEditingController: passwordController,
                    isPassword: true,
                    inputType: TextInputType.text,
                  ),
                  SizedBox(height: spaceBetween * 0.5),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/forget-password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: textSize * 0.6),
                      ),
                    ),
                  ),
                  SizedBox(height: spaceBetween),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              setState(() {
                                _isLoading = true;
                              });

                              // Attempt login
                              bool success = await _userController.login(
                                context,
                                emailController.text,
                                passwordController.text,
                              );

                              setState(() {
                                _isLoading = false;
                              });

                              if (success) {
                                // Navigate to main screen
                                Navigator.pushReplacementNamed(
                                    context, '/main_screen');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Invalid login credentials. Please try again.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter valid details.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          buttonText: "Login",
                          buttonHeight: buttonHeight,
                          buttonWidth: buttonWidth,
                        ),
                  SizedBox(height: spaceBetween * 0.5),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Don\'t have an account? ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: textSize * 0.7,
                        ),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(context, '/signup');
                              },
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: textSize * 0.7,
                                  color: const Color.fromRGBO(43, 147, 72, 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

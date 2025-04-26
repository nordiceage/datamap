import 'package:flutter/material.dart';
import 'package:treemate/services/validator.dart';
import 'package:treemate/widgets/custom_button.dart';
import 'package:treemate/widgets/custom_text_field.dart';
import 'package:treemate/controllers/user_controller.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  _ForgetPasswordPageState createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  late final UserController _userController;

  @override
  void initState() {
    _userController = UserController();
    _userController.init(context);
    super.initState();
  }

  void _sendPasswordResetEmail() async {
    setState(() {
      _isLoading = true;
    });

    bool response =
        await _userController.forgotPassword(_emailController.text, context);

    setState(() {
      _isLoading = false;
    });
    if (response) {
      // Navigate to OTP verification page for forgot Pass
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {'email': _emailController.text, 'forgotPassword': true},
      );
    }
    // _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Size constants
    double pageHeight = MediaQuery.of(context).size.height;
    double pageWidth = MediaQuery.of(context).size.width;
    double padding = pageWidth * 0.05;
    double spacing = pageHeight * 0.05;
    double buttonHeight = pageHeight * 0.06;
    double buttonWidth = pageWidth * 0.8;
    double textSize = pageHeight * 0.03;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: ListView(
              children: [
                Image.asset('assets/image/login.png'),
                SizedBox(height: spacing),
                Center(
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                        fontSize: textSize, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: spacing * 0.5),
                Center(
                  child: Text(
                    'Enter your registered email address to receive a password reset link.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: textSize * 0.7,
                      color: const Color.fromRGBO(115, 115, 115, 1),
                    ),
                  ),
                ),
                SizedBox(height: spacing),
                CustomTextField(
                  icon: Icons.email_outlined,
                  hintText: 'Email',
                  textEditingController: _emailController,
                  inputType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                SizedBox(height: spacing),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        onPressed: () {
                          if (_emailController.text.isNotEmpty) {
                            _sendPasswordResetEmail();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter your email'),
                              ),
                            );
                          }
                        },
                        buttonText: 'Send Reset OTP',
                        buttonHeight: buttonHeight,
                        buttonWidth: buttonWidth,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:treemate/Auth_pages/terms_policies.dart';
import 'package:treemate/services/validator.dart';
import 'package:treemate/widgets/custom_button.dart';
import 'package:treemate/widgets/custom_text_field.dart';
import 'package:treemate/controllers/user_controller.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final UserController _userController;

  bool _isLoading = false;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  @override
  void initState() {
    super.initState();
    _userController = UserController();
    _userController.init(context);
  }

  void _showPopup(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(
              child: Text(content),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

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
                  Image.asset('assets/image/signup.png'),
                  SizedBox(height: spaceBetween),
                  Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                          fontSize: textSize, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: spaceBetween * 0.25),
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      'Let\'s Grow Together',
                      style: TextStyle(
                          fontSize: textSize * 0.7,
                          color: const Color.fromRGBO(115, 115, 115, 1)),
                    ),
                  ),
                  SizedBox(height: spaceBetween),
                  CustomTextField(
                    icon: Icons.person_outline,
                    hintText: 'Full Name',
                    textEditingController: nameController,
                    inputType: TextInputType.name,
                    validator: Validators.validateName,
                  ),
                  SizedBox(height: spaceBetween * 0.5),
                  CustomTextField(
                    icon: Icons.email_outlined,
                    hintText: 'Email',
                    textEditingController: emailController,
                    inputType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  SizedBox(height: spaceBetween),
                  Row(
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        onChanged: (value) {
                          setState(() {
                            _termsAccepted = value ?? false;
                          });
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          _showPopup(
                            "TREEmate App Terms and Conditions",
                            TermsAndPolicies.termsAndConditions,
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'I accept the ',
                            style: TextStyle(
                              fontSize: textSize * 0.7,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(
                                  fontSize: textSize * 0.7,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _privacyAccepted,
                        onChanged: (value) {
                          setState(() {
                            _privacyAccepted = value ?? false;
                          });
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          _showPopup(
                            "TREEmate Privacy Policy",
                            TermsAndPolicies.privacyPolicy,
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'I accept the ',
                            style: TextStyle(
                              fontSize: textSize * 0.7,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  fontSize: textSize * 0.7,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spaceBetween),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          onPressed: (_termsAccepted && _privacyAccepted)
                              ? () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    bool? response =
                                        await _userController.registerInitiate(
                                            emailController.text, context);

                                    setState(() {
                                      _isLoading = false;
                                    });

                                    if (response ?? false) {
                                      Navigator.pushNamed(
                                        context,
                                        '/otp',
                                        arguments: {
                                          'name': nameController.text,
                                          'email': emailController.text
                                        },
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Please enter valid details.'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                }
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Please accept the ${(!_termsAccepted) ? 'Terms and Conditions' : 'Privacy Policy'}'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                          buttonText: 'Get OTP',
                          buttonHeight: buttonHeight,
                          buttonWidth: buttonWidth,
                        ),
                  SizedBox(height: spaceBetween * 0.5),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: textSize * 0.7,
                        ),
                        children: [
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              child: Text(
                                'Log In',
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

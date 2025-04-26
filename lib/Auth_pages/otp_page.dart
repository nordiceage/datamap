import 'package:flutter/material.dart';
import 'package:treemate/controllers/user_controller.dart';
import 'package:treemate/widgets/custom_button.dart';
import 'package:flutter/gestures.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final int otpLength = 6;
  late final UserController _userController;
  late final List<TextEditingController> otpControllers;
  bool isResending = false; // Tracks whether we are resending the OTP

  @override
  void initState() {
    super.initState();
    _userController = UserController();
    _userController.init(context);
    otpControllers = List.generate(otpLength, (_) => TextEditingController());
  }

  String getOtp() {
    // Combine the OTP from all six fields into a single string
    return otpControllers.map((controller) => controller.text).join('');
  }

  @override
  Widget build(BuildContext context) {
    // Received arguments
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String email = args['email'] ?? "";
    final String name = args['name'] ?? "";
    final bool isForgetPasswordOTPPage = args['forgotPassword'] ?? false;

    // Size constants
    double pageHeight = MediaQuery.of(context).size.height;
    double pageWidth = MediaQuery.of(context).size.width;
    double pad = pageWidth * 0.05;
    double spaceBetween = pageHeight * 0.05;
    double buttonHeight = pageHeight * 0.06;
    double buttonWidth = pageWidth * 0.8;
    double textSize = pageHeight * 0.03;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _showBackDialog(context) ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: GestureDetector(
        onTap: () {
          // Unfocus all input fields when tapping outside of them
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: ListView(
                children: [
                  Image.asset('assets/image/email_verify.png'),
                  SizedBox(height: spaceBetween),
                  Center(
                    child: Text(
                      'Email Verification',
                      style: TextStyle(
                          fontSize: textSize, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: spaceBetween * 0.25),
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      'Please enter the $otpLength-digit OTP (One Time Password) sent to your email address “$email” to verify your email.',
                      style: TextStyle(
                          fontSize: textSize * 0.7,
                          color: const Color.fromRGBO(115, 115, 115, 1)),
                    ),
                  ),
                  SizedBox(height: spaceBetween),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(otpLength, (index) {
                      return SizedBox(
                        width: (pageWidth / otpLength) * 0.8,
                        child: TextField(
                          controller: otpControllers[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: '', // Hide the counter
                            border: OutlineInputBorder(),
                          ),
                          // inputFormatters: [
                          //   // Allow only capital letters, numbers, and backspace
                          //   FilteringTextInputFormatter.allow(
                          //     RegExp(r'[A-Z0-9]'),
                          //   ),
                          // ],
                          onChanged: (value) {
                            if (value.length == 1 && index < (otpLength - 1)) {
                              FocusScope.of(context).nextFocus();
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: spaceBetween),
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Didn\'t receive OTP? ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: textSize * 0.7,
                        ),
                        children: [
                          TextSpan(
                            text: isResending ? 'Resending...' : 'Resend',
                            style: TextStyle(
                              fontSize: textSize * 0.7,
                              color: const Color.fromRGBO(43, 147, 72, 1),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (!isResending) {
                                  setState(() {
                                    isResending = true;
                                  });

                                  await _userController.resendOTP(
                                      email, context);

                                  setState(() {
                                    isResending = false;
                                  });
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: spaceBetween),
                  CustomButton(
                    onPressed: () async {
                      // Get the full OTP input
                      String otp = getOtp();

                      // Validate if OTP is of correct length and not containing blanks
                      if (otp.length == otpLength &&
                          !otp.contains(RegExp(r'\s'))) {
                        if (isForgetPasswordOTPPage) {
                          bool response = await _userController
                              .verifyPasswordResetOTP(email, otp, context);
                          if (response) {
                            Navigator.pushNamed(
                              context,
                              '/create-password',
                              arguments: {
                                'name': name,
                                'email': email,
                                'resetPassword': true
                              },
                            );
                          }
                        } else {
                          bool response = await _userController.verifyOTP(
                              email, otp, context);
                          if (response) {
                            Navigator.pushNamed(
                              context,
                              '/create-password',
                              arguments: {'name': name, 'email': email},
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter the entire OTP.'),
                          ),
                        );
                      }
                    },
                    buttonText: "Verify",
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

Future<bool?> _showBackDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text(
          'Are you sure you want to go back?',
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context, false);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Yes'),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      );
    },
  );
}

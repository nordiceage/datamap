import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final double buttonWidth;
  final double buttonHeight;

  const CustomButton({super.key, 
    required this.onPressed,
    required this.buttonText,
    this.buttonWidth = 200.0,
    this.buttonHeight = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(Color.fromRGBO(43, 147, 72, 1)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(buttonWidth / 10)),
          ),
        ),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        padding: WidgetStatePropertyAll(EdgeInsets.all(buttonHeight*0.01)),
        fixedSize: WidgetStatePropertyAll(Size(buttonWidth, buttonHeight)),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyle(fontSize: buttonHeight*0.4),
      ),
    );
  }
}

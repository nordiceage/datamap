import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final IconData icon;
  final bool isPassword;
  final TextInputType inputType;
  final String hintText;
  final TextEditingController textEditingController;
  final String? Function(String?)? validator;

  const CustomTextField(
      {super.key, required this.icon,
      this.isPassword = false,
      this.inputType = TextInputType.text,
      required this.hintText,
      required this.textEditingController,
      this.validator});

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    double fieldWidth = MediaQuery.of(context).size.width;
    return TextFormField(
      validator: widget.validator,
      controller: widget.textEditingController,
      keyboardType: widget.inputType,
      obscureText: widget.isPassword ? _isObscured : false,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon:
                    Icon(_isObscured ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fieldWidth),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

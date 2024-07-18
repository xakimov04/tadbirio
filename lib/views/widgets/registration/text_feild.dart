import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final Widget? suffixIcon;
  final String hintText;
  Function(String)? onChanged;
  final String? Function(String?)? validator;
  bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization? textCapitalization;
  IconData? icon;
  TextFieldWidget({
    super.key,
    this.onChanged,
    required this.controller,
    this.suffixIcon,
    required this.hintText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      textCapitalization: textCapitalization!,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      obscureText: obscureText,
      validator: validator,
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.withOpacity(.3),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(130, 27, 56, 135)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.green),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

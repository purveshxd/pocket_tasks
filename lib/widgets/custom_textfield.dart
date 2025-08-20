import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Widget? prefixIcon;
  final String? errorText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const CustomTextfield({
    super.key,
    this.controller,
    required this.hintText,
    this.errorText,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Color(0xFFD1A9F9)),
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Color(0xff76539a),
          fontWeight: FontWeight.w400,
        ),
        fillColor: Color(0x58452576),
        filled: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff452576)),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff452576)),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        errorText: errorText,
      ),

      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

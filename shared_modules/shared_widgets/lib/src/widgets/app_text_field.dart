import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final String? hintText;
  final IconData? prefixIcon;
  final InputDecoration? decoration;
  final int maxLines;
  final bool enabled; // ✅ تم تعريفه

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.prefixIcon,
    this.decoration,
    this.maxLines = 1,
    this.enabled = true, // ✅ تم إضافته مع قيمة افتراضية
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled, // ✅ استخدمناه هنا
      decoration: decoration ??
          InputDecoration(
            labelText: label,
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.blue.shade400)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
    );
  }
}

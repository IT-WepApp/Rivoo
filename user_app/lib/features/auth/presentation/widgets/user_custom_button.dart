import 'package:flutter/material.dart';

class UserCustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const UserCustomButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(label),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// زر تطبيق مخصص يدعم أنماط مختلفة
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonStyle = isPrimary
        ? AppTheme.primaryButtonStyle
        : AppTheme.secondaryButtonStyle;

    final buttonWidth = isFullWidth
        ? double.infinity
        : width;

    final buttonHeight = height ?? 48.0;

    final buttonChild = isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.0,
            ),
          )
        : _buildButtonContent();

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: isPrimary
          ? ElevatedButton(
              style: buttonStyle,
              onPressed: isLoading ? null : onPressed,
              child: buttonChild,
            )
          : OutlinedButton(
              style: buttonStyle,
              onPressed: isLoading ? null : onPressed,
              child: buttonChild,
            ),
    );
  }

  Widget _buildButtonContent() {
    if (prefixIcon != null || suffixIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: 8),
          ],
          Text(text),
          if (suffixIcon != null) ...[
            const SizedBox(width: 8),
            suffixIcon!,
          ],
        ],
      );
    } else if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      return Text(text);
    }
  }
}

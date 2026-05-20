import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_background.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final Color? color;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return NeonButton(
        label: label,
        onPressed: onPressed,
        isLoading: isLoading,
        outlined: true,
        icon: icon,
      );
    }

    return NeonButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
    );
  }
}

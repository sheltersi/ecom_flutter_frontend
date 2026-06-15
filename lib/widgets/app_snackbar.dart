import 'package:flutter/material.dart';
import 'package:flutter_learn2/theme/app_colors.dart';

/// Shows a floating snackbar with the app's default styling.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  Color backgroundColor = AppColors.red,
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: duration,
    ),
  );
}

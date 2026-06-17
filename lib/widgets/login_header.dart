import "package:flutter/material.dart";
import 'package:flutter_learn2/theme/app_colors.dart';
import 'package:flutter_learn2/widgets/gradient_text.dart';

class BuildHeader extends StatelessWidget {
  const BuildHeader({super.key});

  /// App icon, "Welcome Back" title, and subtitle.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.blazeOrange, AppColors.brightAmber],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.blazeOrange.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 24),
        const GradientText(
          'Welcome Back',
          colors: [AppColors.brightAmber, AppColors.sunbeamYellow],
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

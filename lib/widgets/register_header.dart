import 'package:flutter/material.dart';
import 'package:flutter_learn2/theme/app_colors.dart';
import 'package:flutter_learn2/widgets/gradient_text.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    /// App icon, "Create Account" title, and "Join us" subtitle.

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.amberGlow, AppColors.sunbeamYellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.amberGlow.withValues(alpha: 0.4),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        const GradientText(
          'Create Account',
          colors: [AppColors.brightAmber, AppColors.sunbeamYellow],
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Join us and get started',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

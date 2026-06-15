import 'package:flutter/material.dart';

/// Frosted-glass circular icon button with configurable size.
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? iconColor;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 42,
    this.iconSize = 20,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        iconColor ?? Colors.white.withValues(alpha: 0.7);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(size * 0.31),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size * 0.31),
          onTap: onTap,
          child: Icon(icon, color: effectiveIconColor, size: iconSize),
        ),
      ),
    );
  }
}

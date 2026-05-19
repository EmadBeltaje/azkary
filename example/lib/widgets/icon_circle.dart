import 'package:flutter/material.dart';

import '../app/palette.dart';

class IconCircle extends StatelessWidget {
  const IconCircle({
    super.key,
    required this.icon,
    required this.filled,
    this.accent = false,
    this.onTap,
  });

  final IconData icon;
  final bool filled;
  final bool accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled
          ? AppPalette.primary
          : accent
              ? AppPalette.gold.withValues(alpha: 0.15)
              : Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 22,
            color: filled
                ? Colors.white
                : accent
                    ? AppPalette.gold
                    : AppPalette.primary,
          ),
        ),
      ),
    );
  }
}

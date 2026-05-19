import 'package:flutter/material.dart';

import '../app/palette.dart';

class SmallAction extends StatelessWidget {
  const SmallAction({
    super.key,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          filled ? AppPalette.primary : AppPalette.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : AppPalette.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

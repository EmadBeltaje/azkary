import 'package:flutter/material.dart';

import '../app/palette.dart';

class RingProgress extends StatelessWidget {
  const RingProgress({super.key, required this.value, required this.size});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: 4,
            color: AppPalette.primary,
            backgroundColor: AppPalette.primary.withValues(alpha: 0.12),
          ),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppPalette.primary,
            ),
          ),
        ],
      ),
    );
  }
}

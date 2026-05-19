import 'package:azkary/azkary.dart';
import 'package:flutter/material.dart';

import '../app/palette.dart';

class BatchProgressCard extends StatelessWidget {
  const BatchProgressCard({super.key, required this.progress});

  final AllAudiosDownloadProgress progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تنزيل الكل: ${progress.completedItems} / ${progress.totalItems}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.overallFraction.clamp(0.0, 1.0),
              color: AppPalette.primary,
              backgroundColor: AppPalette.primary.withValues(alpha: 0.12),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:azkary/azkary.dart';
import 'package:flutter/material.dart';

import '../app/palette.dart';
import 'ring_progress.dart';

class CategoryProgressHeader extends StatelessWidget {
  const CategoryProgressHeader({super.key, required this.category});

  final ZekrCategory category;

  @override
  Widget build(BuildContext context) {
    final progress = category.totalCount > 0
        ? category.completedCount / category.totalCount
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            RingProgress(value: progress, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تقدّم الفئة',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    '${category.completedCount} من ${category.totalCount}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppPalette.primary,
                        ),
                  ),
                  if (category.isCompleted)
                    Text(
                      'مكتملة ✓',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppPalette.primary,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

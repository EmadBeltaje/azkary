import 'download_progress.dart';

class AllAudiosDownloadProgress {
  const AllAudiosDownloadProgress({
    required this.completedItems,
    required this.totalItems,
    required this.currentCategoryId,
    this.currentZekrId,
    this.currentFileProgress,
  });

  final int completedItems;
  final int totalItems;
  final int currentCategoryId;
  final int? currentZekrId;
  final DownloadProgress? currentFileProgress;

  double get overallFraction {
    if (totalItems <= 0) return 1;
    final f = currentFileProgress?.fraction ?? 0.0;
    return (completedItems + f) / totalItems;
  }

  double get overallPercent => overallFraction * 100;
}

typedef AllAudiosDownloadProgressCallback = void Function(
  AllAudiosDownloadProgress progress,
);

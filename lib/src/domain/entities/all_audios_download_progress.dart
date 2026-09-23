import 'download_progress.dart';

/// Progress across a batch download of every Zekr audio file.
class AllAudiosDownloadProgress {
  /// Creates batch progress for [totalItems] files.
  const AllAudiosDownloadProgress({
    required this.completedItems,
    required this.totalItems,
    required this.currentCategoryId,
    this.currentZekrId,
    this.currentFileProgress,
  });

  /// Files already stored.
  final int completedItems;

  /// Files in the batch.
  final int totalItems;

  /// Category of the file currently transferring.
  final int currentCategoryId;

  /// Zekr of the file currently transferring, when the file belongs to one Zekr.
  final int? currentZekrId;

  /// Byte progress of the file currently transferring.
  final DownloadProgress? currentFileProgress;

  /// Finished files plus the current file, divided by [totalItems].
  ///
  /// Returns `1` when [totalItems] is zero.
  double get overallFraction {
    if (totalItems <= 0) return 1;
    final f = currentFileProgress?.fraction ?? 0.0;
    return (completedItems + f) / totalItems;
  }

  /// [overallFraction] as a percentage from 0 to 100.
  double get overallPercent => overallFraction * 100;
}

/// Reports [AllAudiosDownloadProgress] during a batch download.
typedef AllAudiosDownloadProgressCallback = void Function(
  AllAudiosDownloadProgress progress,
);

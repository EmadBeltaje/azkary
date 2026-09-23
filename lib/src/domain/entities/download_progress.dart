/// Bytes received so far for one file download.
class DownloadProgress {
  /// Creates progress from [received] and [total] byte counts.
  const DownloadProgress({required this.received, required this.total});

  /// Bytes written so far.
  final int received;

  /// Expected size in bytes, or `-1` when the server omits the length.
  final int total;

  /// [received] divided by [total], or `0` when [total] is unknown.
  double get fraction => total > 0 ? received / total : 0.0;

  /// [fraction] as a percentage from 0 to 100.
  double get percent => fraction * 100;

  /// Whether [received] has reached a known [total].
  bool get isComplete => total > 0 && received >= total;

  @override
  String toString() =>
      'DownloadProgress(received: $received, total: $total, percent: ${percent.toStringAsFixed(1)})';
}

/// Reports [DownloadProgress] while one file transfers.
typedef DownloadProgressCallback = void Function(DownloadProgress progress);

/// Snapshot reported while a file streams from the network.
class DownloadProgress {
  const DownloadProgress({required this.received, required this.total});

  final int received;
  final int total;

  /// [total] is `-1` when Content-Length is unknown.
  double get fraction => total > 0 ? received / total : 0.0;

  double get percent => fraction * 100;

  bool get isComplete => total > 0 && received >= total;

  @override
  String toString() =>
      'DownloadProgress(received: $received, total: $total, percent: ${percent.toStringAsFixed(1)})';
}

typedef DownloadProgressCallback = void Function(DownloadProgress progress);

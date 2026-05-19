import '../../domain/entities/download_progress.dart';

abstract interface class AudioDownloader {
  Future<void> download({
    required String url,
    required String destinationPath,
    DownloadProgressCallback? onProgress,
    DownloadCancelToken? cancelToken,
  });
}

abstract interface class DownloadCancelToken {
  bool get isCancelled;
  void cancel([String? reason]);
}

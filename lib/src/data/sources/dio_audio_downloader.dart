import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/constants/package_constants.dart';
import '../../core/errors/azkary_exception.dart';
import '../../domain/entities/download_progress.dart';
import 'audio_downloader.dart';

class DioDownloadCancelToken implements DownloadCancelToken {
  DioDownloadCancelToken() : dioToken = CancelToken();

  final CancelToken dioToken;

  @override
  bool get isCancelled => dioToken.isCancelled;

  @override
  void cancel([String? reason]) => dioToken.cancel(reason);
}

class DioAudioDownloader implements AudioDownloader {
  DioAudioDownloader({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<void> download({
    required String url,
    required String destinationPath,
    DownloadProgressCallback? onProgress,
    DownloadCancelToken? cancelToken,
  }) async {
    final tempPath = '$destinationPath.part';
    final dioToken =
        cancelToken is DioDownloadCancelToken ? cancelToken.dioToken : null;
    try {
      await _dio.download(
        url,
        tempPath,
        cancelToken: dioToken,
        onReceiveProgress: onProgress == null
            ? null
            : (received, total) => onProgress(
                  DownloadProgress(received: received, total: total),
                ),
      );

      final tempFile = File(tempPath);
      if (!await tempFile.exists()) {
        throw DownloadException(PackageConstants.downloadFailed(url));
      }
      await tempFile.rename(destinationPath);
    } on DioException catch (e) {
      await _safeDelete(tempPath);
      if (CancelToken.isCancel(e)) {
        rethrow;
      }
      throw DownloadException(
        PackageConstants.downloadFailed(url),
        cause: e,
      );
    } catch (e) {
      await _safeDelete(tempPath);
      if (e is AzkaryException) rethrow;
      throw DownloadException(
        PackageConstants.downloadFailed(url),
        cause: e,
      );
    }
  }

  Future<void> _safeDelete(String path) async {
    final f = File(path);
    if (await f.exists()) {
      try {
        await f.delete();
      } catch (_) {}
    }
  }
}

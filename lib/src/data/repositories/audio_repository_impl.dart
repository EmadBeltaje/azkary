import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../core/constants/hive_constants.dart';
import '../../core/constants/package_constants.dart';
import '../../core/errors/azkary_exception.dart';
import '../../domain/entities/all_audios_download_progress.dart';
import '../../domain/entities/current_playback.dart';
import '../../domain/entities/download_progress.dart';
import '../../domain/entities/playback_state.dart';
import '../../domain/repositories/audio_repository.dart';
import '../sources/azkar_local_source.dart';
import '../sources/audio_downloader.dart';
import '../sources/audio_player_source.dart';
import '../sources/audio_storage_source.dart';
import '../sources/dio_audio_downloader.dart';

class AudioRepositoryImpl implements AudioRepository {
  AudioRepositoryImpl({
    required AzkarLocalSource azkarLocal,
    required AudioDownloader downloader,
    required AudioPlayerSource player,
    required AudioStorageSource storage,
    required Directory audioDir,
    DownloadCancelToken Function()? cancelTokenFactory,
  })  : _azkar = azkarLocal,
        _downloader = downloader,
        _player = player,
        _storage = storage,
        _audioDir = audioDir,
        _cancelTokenFactory =
            cancelTokenFactory ?? DioDownloadCancelToken.new {
    _stateSub = _player.stateStream.listen((playerState) {
      final target = _currentTarget;
      if (target == null) return;
      _setCurrent(target.copyWith(state: playerState));
    });
    _currentCtrl.add(null);
  }

  final AzkarLocalSource _azkar;
  final AudioDownloader _downloader;
  final AudioPlayerSource _player;
  final AudioStorageSource _storage;
  final Directory _audioDir;
  final DownloadCancelToken Function() _cancelTokenFactory;

  final Map<String, DownloadCancelToken> _audiosBeingDownloading = {};
  CurrentPlayback? _currentTarget;
  final StreamController<CurrentPlayback?> _currentCtrl =
      StreamController<CurrentPlayback?>.broadcast();
  late final StreamSubscription<PlaybackState> _stateSub;

  void _setCurrent(CurrentPlayback? cp) {
    _currentTarget = cp;
    _currentCtrl.add(cp);
  }

  /// Hive stores the canonical absolute file path after each successful download.
  Future<String?> _resolveLocalAudioPath(String hiveKey, String stored) async {
    final path = stored.trim();
    if (path.isEmpty) {
      await _storage.remove(hiveKey);
      return null;
    }
    if (await File(path).exists()) {
      return File(path).absolute.path;
    }
    await _storage.remove(hiveKey);
    return null;
  }

  Future<bool> _isDownloadedAndOnDisk(String key) async {
    final stored = await _storage.get(key);
    if (stored == null) return false;
    return await _resolveLocalAudioPath(key, stored) != null;
  }

  Future<({String url, String filename})> _resolveZekr(
    int categoryId,
    int zekrId,
  ) async {
    final categories = await _azkar.readCategories();
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => throw NotFoundException(
        PackageConstants.hiveCategoryNotFound(categoryId),
      ),
    );
    final zekr = category.azkar.firstWhere(
      (z) => z.id == zekrId,
      orElse: () => throw NotFoundException(
        PackageConstants.zekrNotFoundInCategory(zekrId, categoryId),
      ),
    );
    final audio = zekr.audio;
    final fname = zekr.filename;
    if (audio == null ||
        audio.isEmpty ||
        fname == null ||
        fname.isEmpty) {
      throw AudioNotAvailableException(
        PackageConstants.audioNotAvailableForZekr(categoryId, zekrId),
      );
    }
    return (
      url: '${PackageConstants.audioBaseUrl}$audio',
      filename: fname,
    );
  }

  Future<({String url, String filename})> _resolveCategory(
    int categoryId,
  ) async {
    final categories = await _azkar.readCategories();
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => throw NotFoundException(
        PackageConstants.hiveCategoryNotFound(categoryId),
      ),
    );
    final audio = category.audio;
    final fname = category.filename;
    if (audio == null ||
        audio.isEmpty ||
        fname == null ||
        fname.isEmpty) {
      throw AudioNotAvailableException(
        PackageConstants.audioNotAvailableForCategory(categoryId),
      );
    }
    return (
      url: '${PackageConstants.audioBaseUrl}$audio',
      filename: fname,
    );
  }

  String _localAudioBasename(String filename, String downloadUrl) {
    final urlPath = Uri.parse(downloadUrl).path;
    var ext = p.extension(urlPath).toLowerCase();
    if (ext.isEmpty) ext = '.mp3';
    final stem = p.basenameWithoutExtension(p.basename(filename.trim()));
    return '$stem$ext';
  }

  Future<String> _destinationPath(String filename, String downloadUrl) async {
    if (!await _audioDir.exists()) await _audioDir.create(recursive: true);
    return p.join(_audioDir.path, _localAudioBasename(filename, downloadUrl));
  }

  @override
  Future<void> downloadZekr(
    int categoryId,
    int zekrId, {
    DownloadProgressCallback? onProgress,
  }) =>
      _doDownload(
        key: HiveConstants.zekrAudioKey(categoryId, zekrId),
        inProgressMsg:
            PackageConstants.zekrDownloadInProgress(categoryId, zekrId),
        alreadyDoneMsg:
            PackageConstants.zekrAlreadyDownloaded(categoryId, zekrId),
        resolve: () => _resolveZekr(categoryId, zekrId),
        onProgress: onProgress,
      );

  @override
  Future<void> downloadCategory(
    int categoryId, {
    DownloadProgressCallback? onProgress,
  }) =>
      _doDownload(
        key: HiveConstants.categoryAudioKey(categoryId),
        inProgressMsg:
            PackageConstants.categoryDownloadInProgress(categoryId),
        alreadyDoneMsg:
            PackageConstants.categoryAlreadyDownloaded(categoryId),
        resolve: () => _resolveCategory(categoryId),
        onProgress: onProgress,
      );

  @override
  Future<void> downloadAllAudios({
    AllAudiosDownloadProgressCallback? onProgress,
  }) async {
    if (_audiosBeingDownloading.containsKey(HiveConstants.allAudiosDownloadingKey)) {
      throw DownloadAlreadyInProgressException(
        PackageConstants.allAudiosDownloadInProgress,
      );
    }

    final raw = await _azkar.readCategories();
    final sorted = [...raw]..sort((a, b) => a.id.compareTo(b.id));

    final queue = <({int categoryId, int? zekrId})>[];
    for (final c in sorted) {
      final ca = c.audio;
      final cf = c.filename;
      if (ca != null &&
          ca.isNotEmpty &&
          cf != null &&
          cf.isNotEmpty) {
        queue.add((categoryId: c.id, zekrId: null));
      }
      for (final z in c.azkar) {
        final za = z.audio;
        final zf = z.filename;
        if (za != null &&
            za.isNotEmpty &&
            zf != null &&
            zf.isNotEmpty) {
          queue.add((categoryId: c.id, zekrId: z.id));
        }
      }
    }

    if (queue.isEmpty) return;

    final batchToken = _cancelTokenFactory();
    _audiosBeingDownloading[HiveConstants.allAudiosDownloadingKey] = batchToken;

    final totalItems = queue.length;
    var completed = 0;

    void emitAll({
      required int currentCategoryId,
      int? currentZekrId,
      DownloadProgress? fileProgress,
    }) {
      onProgress?.call(
        AllAudiosDownloadProgress(
          completedItems: completed,
          totalItems: totalItems,
          currentCategoryId: currentCategoryId,
          currentZekrId: currentZekrId,
          currentFileProgress: fileProgress,
        ),
      );
    }

    try {
      for (final item in queue) {
        if (batchToken.isCancelled) {
          throw DownloadCancelledException(
            PackageConstants.downloadCancelled(
              HiveConstants.allAudiosDownloadingKey,
            ),
          );
        }

        final categoryId = item.categoryId;
        final zekrId = item.zekrId;

        if (zekrId == null) {
          final key = HiveConstants.categoryAudioKey(categoryId);
          if (await _isDownloadedAndOnDisk(key)) {
            completed++;
            emitAll(
              currentCategoryId: categoryId,
              currentZekrId: null,
              fileProgress: null,
            );
            continue;
          }

          emitAll(
            currentCategoryId: categoryId,
            currentZekrId: null,
            fileProgress: null,
          );

          await _doDownload(
            key: key,
            inProgressMsg:
                PackageConstants.categoryDownloadInProgress(categoryId),
            alreadyDoneMsg:
                PackageConstants.categoryAlreadyDownloaded(categoryId),
            resolve: () => _resolveCategory(categoryId),
            onProgress: (p) {
              if (!batchToken.isCancelled) {
                emitAll(
                  currentCategoryId: categoryId,
                  currentZekrId: null,
                  fileProgress: p,
                );
              }
            },
          );
          completed++;
          emitAll(
            currentCategoryId: categoryId,
            currentZekrId: null,
            fileProgress: null,
          );
          continue;
        }

        final key = HiveConstants.zekrAudioKey(categoryId, zekrId);
        if (await _isDownloadedAndOnDisk(key)) {
          completed++;
          emitAll(
            currentCategoryId: categoryId,
            currentZekrId: zekrId,
            fileProgress: null,
          );
          continue;
        }

        emitAll(
          currentCategoryId: categoryId,
          currentZekrId: zekrId,
          fileProgress: null,
        );

        await _doDownload(
          key: key,
          inProgressMsg:
              PackageConstants.zekrDownloadInProgress(categoryId, zekrId),
          alreadyDoneMsg:
              PackageConstants.zekrAlreadyDownloaded(categoryId, zekrId),
          resolve: () => _resolveZekr(categoryId, zekrId),
          onProgress: (p) {
            if (!batchToken.isCancelled) {
              emitAll(
                currentCategoryId: categoryId,
                currentZekrId: zekrId,
                fileProgress: p,
              );
            }
          },
        );
        completed++;
        emitAll(
          currentCategoryId: categoryId,
          currentZekrId: zekrId,
          fileProgress: null,
        );
      }
    } finally {
      _audiosBeingDownloading.remove(HiveConstants.allAudiosDownloadingKey);
    }
  }

  Future<void> _doDownload({
    required String key,
    required String inProgressMsg,
    required String alreadyDoneMsg,
    required Future<({String url, String filename})> Function() resolve,
    DownloadProgressCallback? onProgress,
  }) async {
    if (_audiosBeingDownloading.containsKey(key)) {
      throw DownloadAlreadyInProgressException(inProgressMsg);
    }
    if (await _isDownloadedAndOnDisk(key)) {
      throw AlreadyDownloadedException(alreadyDoneMsg);
    }

    final token = _cancelTokenFactory();
    _audiosBeingDownloading[key] = token;

    try {
      final info = await resolve();
      final dest = await _destinationPath(info.filename, info.url);
      try {
        await _downloader.download(
          url: info.url,
          destinationPath: dest,
          onProgress: onProgress,
          cancelToken: token,
        );
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) {
          throw DownloadCancelledException(
            PackageConstants.downloadCancelled(key),
          );
        }
        throw DownloadException(
          PackageConstants.downloadFailed(info.url),
          cause: e,
        );
      }
      await _storage.put(key, File(dest).absolute.path);
    } finally {
      _audiosBeingDownloading.remove(key);
    }
  }

  @override
  Future<bool> cancelZekrDownload(int categoryId, int zekrId) =>
      _cancelByKey(HiveConstants.zekrAudioKey(categoryId, zekrId));

  @override
  Future<bool> cancelCategoryDownload(int categoryId) =>
      _cancelByKey(HiveConstants.categoryAudioKey(categoryId));

  @override
  Future<int> cancelAllDownloads() async {
    final keys = _audiosBeingDownloading.keys.toList();
    for (final k in keys) {
      _audiosBeingDownloading[k]?.cancel('cancelAllDownloads');
    }
    return keys.length;
  }

  Future<bool> _cancelByKey(String key) async {
    final token = _audiosBeingDownloading[key];
    if (token == null) return false;
    token.cancel('cancelDownload');
    return true;
  }

  @override
  Future<bool> isZekrDownloaded(int categoryId, int zekrId) =>
      _isDownloadedAndOnDisk(HiveConstants.zekrAudioKey(categoryId, zekrId));

  @override
  Future<bool> isCategoryDownloaded(int categoryId) =>
      _isDownloadedAndOnDisk(HiveConstants.categoryAudioKey(categoryId));

  @override
  Future<String?> getZekrLocalPath(int categoryId, int zekrId) async {
    final key = HiveConstants.zekrAudioKey(categoryId, zekrId);
    final stored = await _storage.get(key);
    if (stored == null) return null;
    return _resolveLocalAudioPath(key, stored);
  }

  @override
  Future<String?> getCategoryLocalPath(int categoryId) async {
    final key = HiveConstants.categoryAudioKey(categoryId);
    final stored = await _storage.get(key);
    if (stored == null) return null;
    return _resolveLocalAudioPath(key, stored);
  }

  @override
  Future<Map<String, String>> readAllDownloadedPaths() async {
    final raw = await _storage.readAll();
    final out = <String, String>{};
    for (final e in raw.entries) {
      final abs = await _resolveLocalAudioPath(e.key, e.value);
      if (abs != null) out[e.key] = abs;
    }
    return out;
  }

  @override
  Future<void> playZekr(int categoryId, int zekrId) async {
    final key = HiveConstants.zekrAudioKey(categoryId, zekrId);
    final stored = await _storage.get(key);
    if (stored == null) {
      throw AudioNotDownloadedException(
        PackageConstants.audioNotDownloadedForZekr(categoryId, zekrId),
      );
    }
    final path = await _resolveLocalAudioPath(key, stored);
    if (path == null) {
      throw AudioNotDownloadedException(
        PackageConstants.audioNotDownloadedForZekr(categoryId, zekrId),
      );
    }
    await _player.stop();
    _setCurrent(
      CurrentPlayback(
        categoryId: categoryId,
        zekrId: zekrId,
        state: PlaybackState.loading,
      ),
    );
    try {
      await _player.loadFile(path);
      await _player.play();
    } catch (e) {
      _setCurrent(null);
      rethrow;
    }
  }

  @override
  Future<void> playCategory(int categoryId) async {
    final key = HiveConstants.categoryAudioKey(categoryId);
    final stored = await _storage.get(key);
    if (stored == null) {
      throw AudioNotDownloadedException(
        PackageConstants.audioNotDownloadedForCategory(categoryId),
      );
    }
    final path = await _resolveLocalAudioPath(key, stored);
    if (path == null) {
      throw AudioNotDownloadedException(
        PackageConstants.audioNotDownloadedForCategory(categoryId),
      );
    }
    await _player.stop();
    _setCurrent(
      CurrentPlayback(
        categoryId: categoryId,
        zekrId: null,
        state: PlaybackState.loading,
      ),
    );
    try {
      await _player.loadFile(path);
      await _player.play();
    } catch (e) {
      _setCurrent(null);
      rethrow;
    }
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.play();

  @override
  Future<void> seek(Duration position) async {
    if (_currentTarget == null) {
      throw PlaybackException(PackageConstants.nothingPlayingToSeek);
    }
    await _player.seek(position);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _setCurrent(null);
  }

  @override
  Stream<CurrentPlayback?> get currentPlaybackStream => _currentCtrl.stream;

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Future<void> clearAudioCache() async {
    await cancelAllDownloads();
    await stop();
    await _storage.clearAll();
    if (await _audioDir.exists()) {
      await _audioDir.delete(recursive: true);
    }
    await _audioDir.create(recursive: true);
  }

  @override
  Future<void> dispose() async {
    await cancelAllDownloads();
    _setCurrent(null);
    await _stateSub.cancel();
    await _currentCtrl.close();
    await _player.dispose();
  }
}

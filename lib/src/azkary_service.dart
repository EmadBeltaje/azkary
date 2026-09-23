import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'core/constants/hive_constants.dart';
import 'core/constants/package_constants.dart';
import 'core/errors/azkary_exception.dart';
import 'data/models/zekr_category_model.dart';
import 'data/models/zekr_model.dart';
import 'data/repositories/audio_repository_impl.dart';
import 'data/repositories/azkar_repository_impl.dart';
import 'data/sources/dio_audio_downloader.dart';
import 'data/sources/hive_audio_storage_source.dart';
import 'data/sources/hive_azkar_source.dart';
import 'data/sources/just_audio_player_source.dart';
import 'data/sources/package_asset_source.dart';
import 'domain/entities/current_playback.dart';
import 'domain/entities/all_audios_download_progress.dart';
import 'domain/entities/download_progress.dart';
import 'domain/entities/zekr_category.dart';
import 'domain/repositories/audio_repository.dart';
import 'domain/usecases/auto_reset_usecase.dart';
import 'domain/usecases/cancel_download_usecase.dart';
import 'domain/usecases/download_all_audio_usecase.dart';
// coming on the next version
// import 'domain/usecases/download_category_audio_usecase.dart';
import 'domain/usecases/download_zekr_audio_usecase.dart';
import 'domain/usecases/increment_zekr_usecase.dart';
import 'domain/usecases/is_audio_downloaded_usecase.dart';
import 'domain/usecases/load_azkar_usecase.dart';
import 'domain/usecases/play_audio_usecase.dart';
import 'domain/usecases/reset_category_usecase.dart';
import 'domain/usecases/reset_zekr_usecase.dart';

/// Loads categories, updates Zekr progress, and controls audio downloads and playback.
class AzkaryService {
  const AzkaryService._({
    required LoadAzkarUseCase loadAzkar,
    required AutoResetUseCase autoReset,
    required IncrementZekrUseCase incrementZekr,
    required ResetZekrUseCase resetZekr,
    required ResetCategoryUseCase resetCategory,
    required AudioRepository audio,
    required DownloadZekrAudioUseCase downloadZekr,
    // required DownloadCategoryAudioUseCase downloadCategory,
    required DownloadAllAudioUseCase downloadAll,
    required CancelDownloadUseCase cancelDownload,
    required IsAudioDownloadedUseCase isAudioDownloaded,
    required PlayAudioUseCase playAudio,
  })  : _loadAzkar = loadAzkar,
        _autoReset = autoReset,
        _incrementZekr = incrementZekr,
        _resetZekr = resetZekr,
        _resetCategory = resetCategory,
        _audio = audio,
        _downloadZekr = downloadZekr,
        // _downloadCategory = downloadCategory,
        _downloadAll = downloadAll,
        _cancelDownload = cancelDownload,
        _isAudioDownloaded = isAudioDownloaded,
        _playAudio = playAudio;

  final LoadAzkarUseCase _loadAzkar;
  final AutoResetUseCase _autoReset;
  final IncrementZekrUseCase _incrementZekr;
  final ResetZekrUseCase _resetZekr;
  final ResetCategoryUseCase _resetCategory;
  final AudioRepository _audio;
  final DownloadZekrAudioUseCase _downloadZekr;
  // Category audio download — will be released in a future version.
  // final DownloadCategoryAudioUseCase _downloadCategory;
  final DownloadAllAudioUseCase _downloadAll;
  final CancelDownloadUseCase _cancelDownload;
  final IsAudioDownloadedUseCase _isAudioDownloaded;
  final PlayAudioUseCase _playAudio;

  /// Loads every category and applies Sabah and Masaa auto-reset.
  Future<List<ZekrCategory>> getCategories() async {
    final categories = await _loadAzkar();
    return _autoReset(categories);
  }

  /// Increases the progress of the Zekr identified by [zekrId] by one.
  ///
  /// Returns the updated [category]. Progress stops at that Zekr's required count.
  Future<ZekrCategory> incrementZekr(ZekrCategory category, int zekrId) =>
      _incrementZekr(category, zekrId);

  /// Sets the progress of the Zekr identified by [zekrId] back to zero.
  ///
  /// Returns the updated [category].
  Future<ZekrCategory> resetZekr(ZekrCategory category, int zekrId) =>
      _resetZekr(category, zekrId);

  /// Sets every Zekr in the category identified by [categoryId] back to zero.
  Future<void> resetCategory(int categoryId) =>
      _resetCategory(categoryId);

  /// Downloads the audio file for one Zekr.
  ///
  /// [onProgress] receives byte counts while the file transfers.
  Future<void> downloadZekrAudio({
    required int categoryId,
    required int zekrId,
    DownloadProgressCallback? onProgress,
  }) =>
      _downloadZekr(categoryId, zekrId, onProgress: onProgress);

  // coming on the next version
  // Future<void> downloadCategoryAudio({
  //   required int categoryId,
  //   DownloadProgressCallback? onProgress,
  // }) =>
  //     _downloadCategory(categoryId, onProgress: onProgress);

  /// Downloads every Zekr audio file that is not already stored locally.
  ///
  /// [onProgress] reports how many files are finished and the current file.
  Future<void> downloadAllAudios({
    AllAudiosDownloadProgressCallback? onProgress,
  }) =>
      _downloadAll(onProgress: onProgress);

  /// Cancels an in-flight download for one Zekr.
  ///
  /// Returns whether a download for that Zekr was running.
  Future<bool> cancelZekrDownload({
    required int categoryId,
    required int zekrId,
  }) =>
      _cancelDownload.zekr(categoryId, zekrId);

  // coming on the next version
  // Future<bool> cancelCategoryDownload({required int categoryId}) =>
  //     _cancelDownload.category(categoryId);

  /// Cancels every in-flight download and returns how many were stopped.
  Future<int> cancelAllDownloads() => _cancelDownload.all();

  /// Whether the audio file for one Zekr is already on disk.
  Future<bool> isZekrAudioDownloaded({
    required int categoryId,
    required int zekrId,
  }) =>
      _isAudioDownloaded.zekr(categoryId, zekrId);

  /// Whether every audio file in the category identified by [categoryId] is on disk.
  Future<bool> isCategoryAudioDownloaded(int categoryId) =>
      _isAudioDownloaded.category(categoryId);

  /// Plays the downloaded audio for one Zekr.
  ///
  /// Throws an [AudioNotDownloadedException] when the file is not on disk.
  Future<void> playZekrAudio({
    required int categoryId,
    required int zekrId,
  }) =>
      _playAudio.zekr(categoryId, zekrId);

  // coming on the next version
  // Future<void> playCategoryAudio(int categoryId) =>
  //     _playAudio.category(categoryId);

  /// Pauses the current audio.
  Future<void> pauseAudio() => _playAudio.pause();

  /// Resumes audio paused by [pauseAudio].
  Future<void> resumeAudio() => _playAudio.resume();

  /// Moves playback to [position].
  Future<void> seekAudio(Duration position) => _playAudio.seek(position);

  /// Stops playback and clears the current item.
  Future<void> stopAudio() => _playAudio.stop();

  /// The item currently loaded in the player, or `null` when nothing is loaded.
  Stream<CurrentPlayback?> get currentPlaybackStream =>
      _audio.currentPlaybackStream;

  /// The playback position of the current item.
  Stream<Duration> get positionStream => _audio.positionStream;

  /// The length of the current item, or `null` until the player knows it.
  Stream<Duration?> get durationStream => _audio.durationStream;

  /// Stops playback, cancels downloads, and releases the audio player.
  Future<void> dispose() => _audio.dispose();

  static Future<AzkaryService> create() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(HiveConstants.zekrTypeId)) {
      Hive.registerAdapter(ZekrModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveConstants.categoryTypeId)) {
      Hive.registerAdapter(ZekrCategoryModelAdapter());
    }

    late final Box<ZekrCategoryModel> categoriesBox;
    late final Box<String> metaBox;
    late final Box<String> audioBox;

    try {
      categoriesBox = await Hive.openBox<ZekrCategoryModel>(
        HiveConstants.categoriesBox,
      );
      metaBox = await Hive.openBox<String>(HiveConstants.metaBox);
      audioBox = await Hive.openBox<String>(HiveConstants.audioDownloadsBox);
    } catch (e) {
      throw StorageException(
        PackageConstants.hiveBoxesOpenFailed,
        cause: e,
      );
    }

    final local = HiveAzkarSource(categoriesBox: categoriesBox, metaBox: metaBox);
    final asset = const PackageAssetSource();
    final audioStorage = HiveAudioStorageSource(box: audioBox);

    final root = await getApplicationDocumentsDirectory();
    final audioDir = Directory(
      '${root.path}/${PackageConstants.audioStorageDirName}',
    );

    final audioSession = await AudioSession.instance;
    await audioSession.configure(const AudioSessionConfiguration.music());

    final audioRepo = AudioRepositoryImpl(
      azkarLocal: local,
      downloader: DioAudioDownloader(),
      player: JustAudioPlayerSource(),
      storage: audioStorage,
      audioDir: audioDir,
    );

    final azkarRepo = AzkarRepositoryImpl(
      localSource: local,
      assetSource: asset,
      audioRepository: audioRepo,
    );

    return AzkaryService._(
      loadAzkar: LoadAzkarUseCase(azkarRepo),
      autoReset: AutoResetUseCase(azkarRepo),
      incrementZekr: IncrementZekrUseCase(azkarRepo),
      resetZekr: ResetZekrUseCase(azkarRepo),
      resetCategory: ResetCategoryUseCase(azkarRepo),
      audio: audioRepo,
      downloadZekr: DownloadZekrAudioUseCase(audioRepo),
      // downloadCategory: DownloadCategoryAudioUseCase(audioRepo),
      downloadAll: DownloadAllAudioUseCase(audioRepo),
      cancelDownload: CancelDownloadUseCase(audioRepo),
      isAudioDownloaded: IsAudioDownloadedUseCase(audioRepo),
      playAudio: PlayAudioUseCase(audioRepo),
    );
  }
}

abstract final class PackageConstants {
  static const String azkarAssetPath = 'packages/azkary/assets/json/azkar.json';

  static const String audioBaseUrl = 'https://raw.githubusercontent.com/rn0x/Adhkar-json/main';

  static const String audioStorageDirName = 'azkary_audio';

  /// GitHub issue reporter link — embedded in every exception message.
  static const String githubIssues =
      'https://github.com/emadbeltaje/azkary/issues/new';

  static const String developerMessageOpening = '[Azkary] ';
  static const String developerMessageCausePrefix = 'Caused by: ';
  static const String developerMessageReportPrefix =
      'Please report this bug at: ';

  static const String instanceAccessedBeforeInit =
      'Azkary.instance was accessed before Azkary.initialize() completed successfully.';

  static const String unexpectedInitError =
      'Unexpected error during initialization.';

  static const String assetLoadFailed =
      'Could not load the bundled azkar.json asset. '
      'Ensure the package is correctly installed.';

  static const String jsonRootMustBeArrayPrefix =
      'azkar.json root must be a JSON array. Got: ';

  static const String jsonDecodeFailed = 'Failed to decode azkar.json';

  static String parseZekrFailed(Object json) =>
      'Failed to parse Zekr from azkar.json.\nOffending entry: $json';

  static String parseZekrCategoryFailed(Object json) =>
      'Failed to parse ZekrCategory from azkar.json.\nOffending entry: $json';

  static const String hiveReadCategoriesFailed =
      'Failed to read categories from Hive';

  static const String hiveWriteCategoriesFailed =
      'Failed to write categories to Hive';

  static String hiveCategoryNotFound(int categoryId) =>
      'Category "$categoryId" not found in Hive.';

  static String hiveZekrNotFound(int zekrId) =>
      'Zekr "$zekrId" not found.';

  static const String hiveUpdateZekrProgressFailed =
      'Failed to update zekr progress';

  static String hiveResetCategoryFailed(int categoryId) =>
      'Failed to reset category "$categoryId"';

  static const String hiveSaveLastResetFailed =
      'Failed to save lastResetTime';

  static const String hiveReadLastResetFailed =
      'Failed to read lastResetTime';

  static const String hiveSaveAudioPathFailed =
      'Failed to save audio download path to Hive';

  static const String hiveClearCacheFailed = 'Failed to clear Hive cache';

  static const String hiveBoxesOpenFailed =
      'Hive could not open its storage boxes. '
      'The device may be out of space or the Hive data may be corrupted.';

  static String zekrNotFoundInCategory(int zekrId, int categoryId) =>
      'Zekr "$zekrId" not found in category "$categoryId".';

  static String zekrAlreadyDownloaded(int categoryId, int zekrId) =>
      'Audio for zekr "$zekrId" in category "$categoryId" is already downloaded.';

  static String categoryAlreadyDownloaded(int categoryId) =>
      'Audio for category "$categoryId" is already downloaded.';

  static String zekrDownloadInProgress(int categoryId, int zekrId) =>
      'Audio for zekr "$zekrId" in category "$categoryId" is already being downloaded. '
      'Await the original call or cancel it before re-requesting.';

  static String categoryDownloadInProgress(int categoryId) =>
      'Audio for category "$categoryId" is already being downloaded. '
      'Await the original call or cancel it before re-requesting.';

  static const String allAudiosDownloadInProgress =
      'A full download of all audios is already running. '
      'Await it or call cancelAllDownloads() first.';

  static String downloadCancelled(String key) =>
      'Download for "$key" was cancelled.';

  static String audioNotAvailableForZekr(int categoryId, int zekrId) =>
      'Zekr "$zekrId" in category "$categoryId" has no audio URL in azkar.json.';

  static String audioNotAvailableForCategory(int categoryId) =>
      'Category "$categoryId" has no audio URL in azkar.json.';

  static String audioNotDownloadedForZekr(int categoryId, int zekrId) =>
      'Audio for zekr "$zekrId" in category "$categoryId" must be downloaded before playback.';

  static String audioNotDownloadedForCategory(int categoryId) =>
      'Audio for category "$categoryId" must be downloaded before playback.';

  static String downloadFailed(String url) =>
      'Failed to download audio from "$url".';

  static const String playbackFailed = 'Audio playback failed.';

  static const String nothingPlayingToSeek =
      'Nothing is playing. Start playback before seeking.';
}

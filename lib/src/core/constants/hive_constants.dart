abstract final class HiveConstants {
  static const String categoriesBox  = 'azkary_categories';
  static const String metaBox = 'azkary_meta';

  static const String audioDownloadsBox = 'azkary_audio_downloads';

  static String zekrAudioKey(int categoryId, int zekrId) =>
      'zekr_${categoryId}_$zekrId';

  static String categoryAudioKey(int categoryId) => 'category_$categoryId';

  /// In-flight sentinel for [AudioRepository.downloadAllAudios].
  static const String allAudiosDownloadingKey = '__azkary_all_audio_batch__';

  static const int zekrTypeId     = 1;
  static const int categoryTypeId = 2;

  static const String lastResetPrefix = 'last_reset_';
}

import '../entities/all_audios_download_progress.dart';
import '../entities/current_playback.dart';
import '../entities/download_progress.dart';

abstract class AudioRepository {
  Future<void> downloadZekr(
    int categoryId,
    int zekrId, {
    DownloadProgressCallback? onProgress,
  });

  Future<void> downloadCategory(
    int categoryId, {
    DownloadProgressCallback? onProgress,
  });

  Future<void> downloadAllAudios({
    AllAudiosDownloadProgressCallback? onProgress,
  });

  Future<bool> cancelZekrDownload(int categoryId, int zekrId);
  Future<bool> cancelCategoryDownload(int categoryId);
  Future<int> cancelAllDownloads();

  Future<bool> isZekrDownloaded(int categoryId, int zekrId);
  Future<bool> isCategoryDownloaded(int categoryId);

  Future<String?> getZekrLocalPath(int categoryId, int zekrId);
  Future<String?> getCategoryLocalPath(int categoryId);

  Future<Map<String, String>> readAllDownloadedPaths();

  Future<void> playZekr(int categoryId, int zekrId);
  Future<void> playCategory(int categoryId);

  Future<void> pause();
  Future<void> resume();

  Future<void> seek(Duration position);

  Future<void> stop();

  Stream<CurrentPlayback?> get currentPlaybackStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;

  Future<void> clearAudioCache();

  Future<void> dispose();
}

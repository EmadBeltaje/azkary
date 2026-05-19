import '../entities/download_progress.dart';
import '../repositories/audio_repository.dart';

class DownloadZekrAudioUseCase {
  const DownloadZekrAudioUseCase(this._audio);
  final AudioRepository _audio;

  Future<void> call(
    int categoryId,
    int zekrId, {
    DownloadProgressCallback? onProgress,
  }) =>
      _audio.downloadZekr(categoryId, zekrId, onProgress: onProgress);
}

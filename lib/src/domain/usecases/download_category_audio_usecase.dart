import '../entities/download_progress.dart';
import '../repositories/audio_repository.dart';

class DownloadCategoryAudioUseCase {
  const DownloadCategoryAudioUseCase(this._audio);
  final AudioRepository _audio;

  Future<void> call(
    int categoryId, {
    DownloadProgressCallback? onProgress,
  }) =>
      _audio.downloadCategory(categoryId, onProgress: onProgress);
}

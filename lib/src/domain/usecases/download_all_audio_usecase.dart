import '../entities/all_audios_download_progress.dart';
import '../repositories/audio_repository.dart';

class DownloadAllAudioUseCase {
  const DownloadAllAudioUseCase(this._audio);
  final AudioRepository _audio;

  Future<void> call({AllAudiosDownloadProgressCallback? onProgress}) =>
      _audio.downloadAllAudios(onProgress: onProgress);
}

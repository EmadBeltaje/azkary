import '../repositories/audio_repository.dart';

class IsAudioDownloadedUseCase {
  const IsAudioDownloadedUseCase(this._audio);
  final AudioRepository _audio;

  Future<bool> zekr(int categoryId, int zekrId) =>
      _audio.isZekrDownloaded(categoryId, zekrId);

  Future<bool> category(int categoryId) =>
      _audio.isCategoryDownloaded(categoryId);
}

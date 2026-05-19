import '../repositories/audio_repository.dart';

class CancelDownloadUseCase {
  const CancelDownloadUseCase(this._audio);
  final AudioRepository _audio;

  Future<bool> zekr(int categoryId, int zekrId) =>
      _audio.cancelZekrDownload(categoryId, zekrId);

  Future<bool> category(int categoryId) =>
      _audio.cancelCategoryDownload(categoryId);

  Future<int> all() => _audio.cancelAllDownloads();
}

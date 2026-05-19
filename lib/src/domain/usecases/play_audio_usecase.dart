import '../repositories/audio_repository.dart';

class PlayAudioUseCase {
  const PlayAudioUseCase(this._audio);
  final AudioRepository _audio;

  Future<void> zekr(int categoryId, int zekrId) =>
      _audio.playZekr(categoryId, zekrId);

  Future<void> category(int categoryId) => _audio.playCategory(categoryId);

  Future<void> pause() => _audio.pause();

  Future<void> resume() => _audio.resume();

  Future<void> seek(Duration position) => _audio.seek(position);

  Future<void> stop() => _audio.stop();
}

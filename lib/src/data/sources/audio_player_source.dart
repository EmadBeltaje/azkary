import '../../domain/entities/playback_state.dart';

/// Low level audio player without category/zekr identity
/// (u just play no matter what is the category or zekr).
abstract interface class AudioPlayerSource {
  Future<void> loadFile(String absolutePath);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> stop();

  Stream<PlaybackState> get stateStream;
  Stream<Duration> get positionStream;
  Stream<Duration?> get durationStream;

  Future<void> dispose();
}

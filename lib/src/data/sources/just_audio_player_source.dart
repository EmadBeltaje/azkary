import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/constants/package_constants.dart';
import '../../core/errors/azkary_exception.dart';
import '../../domain/entities/playback_state.dart';
import 'audio_player_source.dart';

class JustAudioPlayerSource implements AudioPlayerSource {
  JustAudioPlayerSource({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Future<void> loadFile(String absolutePath) async {
    try {
      await _player.setFilePath(absolutePath);
    } catch (e) {
      throw PlaybackException(PackageConstants.playbackFailed, cause: e);
    }
  }

  @override
  Future<void> play() async {
    try {
      final session = await AudioSession.instance;
      await session.setActive(true);
      await _player.play();
    } catch (e) {
      throw PlaybackException(PackageConstants.playbackFailed, cause: e);
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      throw PlaybackException(PackageConstants.playbackFailed, cause: e);
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      throw PlaybackException(PackageConstants.playbackFailed, cause: e);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (e) {
      throw PlaybackException(PackageConstants.playbackFailed, cause: e);
    }
  }

  @override
  Stream<PlaybackState> get stateStream =>
      _player.playerStateStream.map(mapJustAudioPlayerState).distinct();

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Future<void> dispose() => _player.dispose();
}

PlaybackState mapJustAudioPlayerState(PlayerState s) {
  final ps = s.processingState;
  if (ps == ProcessingState.loading || ps == ProcessingState.buffering) {
    return PlaybackState.loading;
  }
  if (ps == ProcessingState.completed) {
    return PlaybackState.completed;
  }
  if (ps == ProcessingState.ready) {
    return s.playing ? PlaybackState.playing : PlaybackState.paused;
  }
  return PlaybackState.stopped;
}

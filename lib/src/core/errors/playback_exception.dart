part of 'azkary_exception.dart';

/// Thrown when the audio player fails to load or control playback.
/// Thrown when the audio player fails to play, pause, seek, or stop.
final class PlaybackException extends AzkaryException {
  const PlaybackException(super.message, {super.cause});
}

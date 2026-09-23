part of 'azkary_exception.dart';

/// Thrown when playback is requested for audio that is not on disk.
final class AudioNotDownloadedException extends AzkaryException {
  const AudioNotDownloadedException(super.message);
}

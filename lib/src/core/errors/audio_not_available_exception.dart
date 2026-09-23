part of 'azkary_exception.dart';

/// Thrown when a Zekr or category has no audio URL.
final class AudioNotAvailableException extends AzkaryException {
  const AudioNotAvailableException(super.message);
}

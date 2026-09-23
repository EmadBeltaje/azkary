part of 'azkary_exception.dart';

/// Thrown when a download is requested for audio that is already on disk.
final class AlreadyDownloadedException extends AzkaryException {
  const AlreadyDownloadedException(super.message);
}

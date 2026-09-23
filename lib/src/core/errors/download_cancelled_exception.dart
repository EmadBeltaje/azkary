part of 'azkary_exception.dart';

/// Thrown when a download stops because it was cancelled.
final class DownloadCancelledException extends AzkaryException {
  const DownloadCancelledException(super.message);
}

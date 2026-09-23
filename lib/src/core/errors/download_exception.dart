part of 'azkary_exception.dart';

/// Thrown when an audio download fails.
final class DownloadException extends AzkaryException {
  const DownloadException(super.message, {super.cause});
}

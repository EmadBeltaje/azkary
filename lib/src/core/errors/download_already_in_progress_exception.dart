part of 'azkary_exception.dart';

/// Thrown when a download is requested for a file that is already transferring.
final class DownloadAlreadyInProgressException extends AzkaryException {
  const DownloadAlreadyInProgressException(super.message);
}

part of 'azkary_exception.dart';

/// Thrown when local storage cannot be opened or written.
final class StorageException extends AzkaryException {
  const StorageException(super.message, {super.cause});
}

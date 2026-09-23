part of 'azkary_exception.dart';

/// Thrown when a category or Zekr id does not exist.
final class NotFoundException extends AzkaryException {
  const NotFoundException(super.message, {super.cause});
}

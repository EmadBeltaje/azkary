part of 'azkary_exception.dart';

final class NotFoundException extends AzkaryException {
  const NotFoundException(super.message, {super.cause});
}

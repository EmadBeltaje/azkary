part of 'azkary_exception.dart';

/// Thrown when package setup fails for a reason other than a known [AzkaryException].
final class InitException extends AzkaryException {
  const InitException(super.message, {super.cause});
}

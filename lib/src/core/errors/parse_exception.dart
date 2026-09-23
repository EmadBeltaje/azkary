part of 'azkary_exception.dart';

/// Thrown when bundled Azkar data cannot be parsed.
final class ParseException extends AzkaryException {
  const ParseException(super.message, {super.cause});
}

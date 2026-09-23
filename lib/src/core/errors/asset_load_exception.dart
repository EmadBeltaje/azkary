part of 'azkary_exception.dart';

/// Thrown when the bundled Azkar asset cannot be loaded.
final class AssetLoadException extends AzkaryException {
  const AssetLoadException(super.message, {super.cause});
}

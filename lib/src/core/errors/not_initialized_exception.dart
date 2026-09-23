part of 'azkary_exception.dart';

/// Thrown when the package instance is read before a successful initialization.
final class NotInitializedException extends AzkaryException {
  const NotInitializedException()
      : super(PackageConstants.instanceAccessedBeforeInit);
}

part of 'azkary_exception.dart';

final class NotInitializedException extends AzkaryException {
  const NotInitializedException()
      : super(PackageConstants.instanceAccessedBeforeInit);
}

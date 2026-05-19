import 'core/constants/package_constants.dart';
import 'core/errors/azkary_exception.dart';
import 'azkary_service.dart';

abstract final class Azkary {
  static AzkaryService? _instance;
  static AzkaryException? _lastError;

  /// access the service methods after [initialize] returns true.
  /// throws [NotInitializedException] if called before a successful initialization.
  static AzkaryService get instance {
    if (_instance == null) {
      throw const NotInitializedException();
    }
    return _instance!;
  }

  /// the last error from [initialize],
  /// it will be null if intialize went fine.
  static AzkaryException? get lastError => _lastError;

  /// initializes the package fully
  static Future<bool> initialize() async {
    try {
      _lastError = null;
      _instance = await AzkaryService.create();
      return true;
    } on AzkaryException catch (e) {
      _lastError = e;
      rethrow;
    } catch (e, st) {
      final initException = InitException(
        PackageConstants.unexpectedInitError,
        cause: '$e\n$st',
      );
      _lastError = initException;
      throw initException;
    }
  }

  /// Tears down audio (player, streams, running downloads) and clears
  /// [instance]. Call [initialize] again before using the package again.
  static Future<void> dispose() async {
    if (_instance == null) return;
    _instance = null;
    _lastError = null;
    await _instance!.dispose();
  }
}

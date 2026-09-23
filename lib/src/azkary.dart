import 'core/constants/package_constants.dart';
import 'core/errors/azkary_exception.dart';
import 'azkary_service.dart';

/// Entry point for loading Azkar, tracking progress, and playing audio.
abstract final class Azkary {
  static AzkaryService? _instance;
  static AzkaryException? _lastError;

  /// The initialized service.
  ///
  /// Throws a [NotInitializedException] when [initialize] has not completed
  /// successfully.
  static AzkaryService get instance {
    if (_instance == null) {
      throw const NotInitializedException();
    }
    return _instance!;
  }

  /// The [AzkaryException] from the last failed [initialize], or `null` after
  /// a successful initialization.
  static AzkaryException? get lastError => _lastError;

  /// Opens local storage and prepares audio playback.
  ///
  /// Returns `true` when [instance] is ready. Rethrows an [AzkaryException]
  /// and stores it in [lastError] when setup fails.
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

  /// Stops playback, cancels downloads, and clears [instance].
  ///
  /// Call [initialize] again before using the package. Does nothing when the
  /// package is not initialized.
  static Future<void> dispose() async {
    if (_instance == null) return;
    await _instance!.dispose();
    _instance = null;
    _lastError = null;
  }
}

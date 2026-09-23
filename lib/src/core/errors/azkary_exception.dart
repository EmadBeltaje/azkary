import '../constants/package_constants.dart';

part 'already_downloaded_exception.dart';
part 'asset_load_exception.dart';
part 'audio_not_available_exception.dart';
part 'audio_not_downloaded_exception.dart';
part 'download_already_in_progress_exception.dart';
part 'download_cancelled_exception.dart';
part 'download_exception.dart';
part 'init_exception.dart';
part 'not_found_exception.dart';
part 'not_initialized_exception.dart';
part 'parse_exception.dart';
part 'playback_exception.dart';
part 'storage_exception.dart';

/// Base type for every error thrown by this package.
sealed class AzkaryException implements Exception {
  /// Creates an error with [message] and an optional [cause].
  const AzkaryException(this.message, {this.cause});

  /// What went wrong.
  final String message;

  /// The underlying error, when one was caught.
  final Object? cause;

  /// [message] plus [cause] and a link for reporting the failure.
  String get developerMessage => [
        '${PackageConstants.developerMessageOpening}$runtimeType: $message',
        if (cause != null)
          '${PackageConstants.developerMessageCausePrefix}$cause',
        '${PackageConstants.developerMessageReportPrefix}'
            '${PackageConstants.githubIssues}',
      ].join('\n');

  @override
  String toString() => developerMessage;
}

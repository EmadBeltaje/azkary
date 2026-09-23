import 'zekr.dart';

/// A named group of [Zekr] items, such as morning or evening remembrances.
class ZekrCategory {
  /// Creates a category with [id], [name], [type], and its [azkar].
  const ZekrCategory({
    required this.id,
    required this.name,
    required this.azkar,
    required this.type,
    this.lastResetTime,
    this.audio,
    this.filename,
    this.localAudioPath,
  });

  /// Stable identifier of this category.
  final int id;

  /// Display name of this category.
  final String name;

  /// Remembrances that belong to this category.
  final List<Zekr> azkar;

  /// Which automatic reset schedule applies.
  final CategoryType type;

  /// When progress in this category was last cleared, or `null` if it never was.
  final DateTime? lastResetTime;

  /// Remote URL of a category-level recitation, or `null` when there is none.
  final String? audio;

  /// File name used when the category recitation is stored locally.
  final String? filename;

  /// Absolute path of the downloaded category recitation.
  final String? localAudioPath;

  /// Whether every Zekr in [azkar] is completed.
  bool get isCompleted => azkar.every((z) => z.isCompleted);

  /// How many Zekr items [azkar] contains.
  int get totalCount => azkar.length;

  /// How many Zekr items in [azkar] are completed.
  int get completedCount => azkar.where((z) => z.isCompleted).length;

  /// Whether [audio] points at a recitation.
  bool get hasAudio => audio != null && audio!.isNotEmpty;

  /// Whether [localAudioPath] is set.
  bool get isAudioDownloaded => localAudioPath != null;

  /// Returns a copy with updated Azkar, reset time, or local audio path.
  ///
  /// [clearLocalAudioPath] drops the stored path even when [localAudioPath]
  /// is omitted.
  ZekrCategory copyWith({
    List<Zekr>? azkar,
    DateTime? lastResetTime,
    String? localAudioPath,
    bool clearLocalAudioPath = false,
  }) =>
      ZekrCategory(
        id: id,
        name: name,
        azkar: azkar ?? this.azkar,
        type: type,
        lastResetTime: lastResetTime ?? this.lastResetTime,
        audio: audio,
        filename: filename,
        localAudioPath: clearLocalAudioPath
            ? null
            : (localAudioPath ?? this.localAudioPath),
      );
}

/// Which automatic reset schedule applies to a [ZekrCategory].
enum CategoryType {
  /// Resets at the start of each morning phase (00:00–11:59).
  sabah,

  /// Resets at the start of each evening phase (12:00–23:59).
  masaa,

  /// Never resets automatically.
  general,
}

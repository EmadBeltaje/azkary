import 'zekr.dart';

class ZekrCategory {
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

  final int id;
  final String name;
  final List<Zekr> azkar;
  final CategoryType type;
  final DateTime? lastResetTime;
  final String? audio;
  final String? filename;
  final String? localAudioPath;

  bool get isCompleted => azkar.every((z) => z.isCompleted);
  int get totalCount => azkar.length;
  int get completedCount => azkar.where((z) => z.isCompleted).length;
  bool get hasAudio => audio != null && audio!.isNotEmpty;
  bool get isAudioDownloaded => localAudioPath != null;

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

/// Controls which auto-reset schedule applies to a category.
enum CategoryType {
  /// resets at the start of each morning phase (00:00–11:59)
  sabah,
  /// resets at the start of each evening phase (12:00–23:59)
  masaa,
  /// No automatic reset. User may still reset manually via the API.
  general,
}

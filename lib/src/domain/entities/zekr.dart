/// One remembrance, including its required count and saved progress.
class Zekr {
  /// Creates a Zekr with [id], [text], required [count], and saved [currentCount].
  const Zekr({
    required this.id,
    required this.text,
    required this.count,
    required this.currentCount,
    this.audio,
    this.filename,
    this.localAudioPath,
  });

  /// Stable identifier inside its category.
  final int id;

  /// The Arabic text of the remembrance.
  final String text;

  /// How many times this remembrance should be said.
  final int count;

  /// How many times the user has already said it.
  final int currentCount;

  /// Remote URL of the recitation, or `null` when this Zekr has no audio.
  final String? audio;

  /// File name used when the recitation is stored locally.
  final String? filename;

  /// Absolute path of the downloaded recitation, or `null` when it is not on disk.
  final String? localAudioPath;

  /// How many repetitions are still left.
  int get remaining => (count - currentCount).clamp(0, count);

  /// Whether [currentCount] has reached [count].
  bool get isCompleted => currentCount >= count;

  /// Whether [audio] points at a recitation.
  bool get hasAudio => audio != null && audio!.isNotEmpty;

  /// Whether [localAudioPath] is set.
  bool get isAudioDownloaded => localAudioPath != null;

  /// Returns a copy with updated progress or a new local audio path.
  ///
  /// [clearLocalAudioPath] drops the stored path even when [localAudioPath]
  /// is omitted.
  Zekr copyWith({
    int? currentCount,
    String? localAudioPath,
    bool clearLocalAudioPath = false,
  }) =>
      Zekr(
        id: id,
        text: text,
        count: count,
        currentCount: currentCount ?? this.currentCount,
        audio: audio,
        filename: filename,
        localAudioPath:
            clearLocalAudioPath ? null : (localAudioPath ?? this.localAudioPath),
      );

  @override
  bool operator ==(Object other) =>
      other is Zekr && other.id == id && other.currentCount == currentCount;

  @override
  int get hashCode => Object.hash(id, currentCount);
}

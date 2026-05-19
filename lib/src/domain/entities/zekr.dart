class Zekr {
  const Zekr({
    required this.id,
    required this.text,
    required this.count,
    required this.currentCount,
    this.audio,
    this.filename,
    this.localAudioPath,
  });

  final int id;
  final String text;
  final int count;
  final int currentCount;
  final String? audio;
  final String? filename;
  final String? localAudioPath;

  int get remaining => (count - currentCount).clamp(0, count);
  bool get isCompleted => currentCount >= count;
  bool get hasAudio => audio != null && audio!.isNotEmpty;
  bool get isAudioDownloaded => localAudioPath != null;

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

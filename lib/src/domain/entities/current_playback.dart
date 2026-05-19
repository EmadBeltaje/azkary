import 'playback_state.dart';

/// What the global player is doing and which audio it refers to.
class CurrentPlayback {
  const CurrentPlayback({
    required this.categoryId,
    required this.state,
    this.zekrId,
  });

  final int categoryId;
  final int? zekrId;
  final PlaybackState state;

  bool get isCategory => zekrId == null;
  bool get isZekr => zekrId != null;

  CurrentPlayback copyWith({PlaybackState? state}) => CurrentPlayback(
        categoryId: categoryId,
        zekrId: zekrId,
        state: state ?? this.state,
      );

  @override
  bool operator ==(Object other) =>
      other is CurrentPlayback &&
      other.categoryId == categoryId &&
      other.zekrId == zekrId &&
      other.state == state;

  @override
  int get hashCode => Object.hash(categoryId, zekrId, state);

  @override
  String toString() =>
      'CurrentPlayback(category: $categoryId, zekr: $zekrId, state: $state)';
}

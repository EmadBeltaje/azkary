import 'playback_state.dart';

/// The item loaded in the player and its [PlaybackState].
class CurrentPlayback {
  /// Creates playback for [categoryId], optionally a single [zekrId].
  const CurrentPlayback({
    required this.categoryId,
    required this.state,
    this.zekrId,
  });

  /// Category that owns the audio.
  final int categoryId;

  /// Zekr inside [categoryId], or `null` when a whole category is loaded.
  final int? zekrId;

  /// Lifecycle of the player for this item.
  final PlaybackState state;

  /// Whether this playback refers to a whole category.
  bool get isCategory => zekrId == null;

  /// Whether this playback refers to one Zekr.
  bool get isZekr => zekrId != null;

  /// Returns a copy with a new [state].
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

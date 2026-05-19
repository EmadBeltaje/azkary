/// High-level player lifecycle for [CurrentPlayback].
enum PlaybackState {
  idle,
  loading,
  playing,
  paused,
  stopped,
  completed,
}

/// Lifecycle of the audio player.
enum PlaybackState {
  /// Nothing is loaded.
  idle,

  /// The file is opening.
  loading,

  /// Audio is audible.
  playing,

  /// Audio is paused and can resume.
  paused,

  /// Playback was stopped.
  stopped,

  /// Playback reached the end of the file.
  completed,
}

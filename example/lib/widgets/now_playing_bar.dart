import 'package:azkary/azkary.dart';
import 'package:flutter/material.dart';

import '../app/palette.dart';
import 'icon_circle.dart';

class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({
    super.key,
    required this.zekr,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPauseResume,
    required this.onStop,
    this.onSeek,
  });

  final Zekr zekr;
  final bool isPlaying;
  final Duration position;
  final Duration? duration;
  final VoidCallback onPauseResume;
  final VoidCallback onStop;
  final ValueChanged<Duration>? onSeek;

  @override
  Widget build(BuildContext context) {
    final dur = duration ?? Duration.zero;
    final maxMs = dur.inMilliseconds > 0 ? dur.inMilliseconds.toDouble() : 1.0;
    final posMs = position.inMilliseconds.toDouble().clamp(0.0, maxMs);

    return Material(
      elevation: 12,
      color: AppPalette.primary,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                zekr.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              if (dur > Duration.zero) ...[
                const SizedBox(height: 6),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                    overlayColor: Colors.white24,
                  ),
                  child: Slider(
                    value: posMs,
                    max: maxMs,
                    onChanged: onSeek == null
                        ? null
                        : (ms) => onSeek!(Duration(milliseconds: ms.round())),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      _formatDuration(dur),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconCircle(
                    icon: isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    filled: true,
                    onTap: onPauseResume,
                  ),
                  const SizedBox(width: 12),
                  IconCircle(
                    icon: Icons.stop_rounded,
                    filled: false,
                    onTap: onStop,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

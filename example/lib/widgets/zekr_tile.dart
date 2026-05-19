import 'package:azkary/azkary.dart';
import 'package:flutter/material.dart';

import '../app/palette.dart';
import 'small_action.dart';
import 'zekr_audio_controls.dart';

class ZekrTile extends StatelessWidget {
  const ZekrTile({
    super.key,
    required this.zekr,
    required this.isActive,
    required this.isPlaying,
    required this.isPaused,
    required this.downloading,
    this.downloadProgress,
    required this.onReset,
    this.onIncrement,
    this.onPlay,
    this.onDownload,
    this.onCancelDownload,
    required this.onPauseResume,
    required this.onStop,
  });

  final Zekr zekr;
  final bool isActive;
  final bool isPlaying;
  final bool isPaused;
  final bool downloading;
  final DownloadProgress? downloadProgress;
  final VoidCallback onReset;
  final VoidCallback? onIncrement;
  final VoidCallback? onPlay;
  final VoidCallback? onDownload;
  final VoidCallback? onCancelDownload;
  final VoidCallback onPauseResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countProgress =
        zekr.count > 0 ? zekr.currentCount / zekr.count : 0.0;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: isActive
            ? const BorderSide(color: AppPalette.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              zekr.text,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: countProgress.clamp(0.0, 1.0),
                minHeight: 5,
                color: zekr.isCompleted ? AppPalette.gold : AppPalette.primary,
                backgroundColor: AppPalette.primary.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${zekr.currentCount} / ${zekr.count}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppPalette.primary,
                  ),
                ),
                const SizedBox(width: 8),
                if (onIncrement != null)
                  SmallAction(
                    label: '+1',
                    filled: true,
                    onTap: onIncrement,
                  ),
                const SizedBox(width: 2),
                Tooltip(
                  message: 'إعادة الذكر',
                  child: IconButton(
                    onPressed: zekr.currentCount > 0 ? onReset : null,
                    icon: const Icon(Icons.restart_alt_rounded),
                    color: AppPalette.primary,
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const Spacer(),
                if (!zekr.hasAudio)
                  Text('بدون صوت', style: theme.textTheme.labelSmall)
                else
                  ZekrAudioControls(
                    isActive: isActive,
                    isPlaying: isPlaying,
                    isPaused: isPaused,
                    isDownloaded: zekr.isAudioDownloaded,
                    downloading: downloading,
                    downloadProgress: downloadProgress,
                    onPlay: onPlay,
                    onDownload: onDownload,
                    onCancelDownload: onCancelDownload,
                    onPauseResume: onPauseResume,
                    onStop: onStop,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

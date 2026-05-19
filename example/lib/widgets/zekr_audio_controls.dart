import 'package:azkary/azkary.dart';
import 'package:flutter/material.dart';

import '../app/palette.dart';
import 'icon_circle.dart';

class ZekrAudioControls extends StatelessWidget {
  const ZekrAudioControls({
    super.key,
    required this.isActive,
    required this.isPlaying,
    required this.isPaused,
    required this.isDownloaded,
    required this.downloading,
    this.downloadProgress,
    this.onPlay,
    this.onDownload,
    this.onCancelDownload,
    required this.onPauseResume,
    required this.onStop,
  });

  final bool isActive;
  final bool isPlaying;
  final bool isPaused;
  final bool isDownloaded;
  final bool downloading;
  final DownloadProgress? downloadProgress;
  final VoidCallback? onPlay;
  final VoidCallback? onDownload;
  final VoidCallback? onCancelDownload;
  final VoidCallback onPauseResume;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    if (isActive && (isPlaying || isPaused)) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconCircle(
            icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            filled: true,
            onTap: onPauseResume,
          ),
          const SizedBox(width: 6),
          IconCircle(
            icon: Icons.stop_rounded,
            filled: false,
            onTap: onStop,
          ),
        ],
      );
    }

    if (downloading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              value: downloadProgress != null && downloadProgress!.total > 0
                  ? downloadProgress!.fraction.clamp(0.0, 1.0)
                  : null,
              color: AppPalette.primary,
            ),
          ),
          const SizedBox(width: 6),
          IconCircle(
            icon: Icons.close_rounded,
            filled: false,
            onTap: onCancelDownload,
          ),
        ],
      );
    }

    if (isDownloaded) {
      return IconCircle(
        icon: Icons.play_arrow_rounded,
        filled: true,
        onTap: onPlay,
      );
    }

    return IconCircle(
      icon: Icons.download_rounded,
      filled: false,
      accent: true,
      onTap: onDownload,
    );
  }
}

import 'dart:async';

import 'package:azkary/azkary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/playback_helpers.dart';
import '../core/snack_error.dart';
import '../widgets/category_progress_header.dart';
import '../widgets/now_playing_bar.dart';
import '../widgets/zekr_tile.dart';

class CategoryAzkarPage extends StatefulWidget {
  const CategoryAzkarPage({super.key, required this.category});

  final ZekrCategory category;

  @override
  State<CategoryAzkarPage> createState() => _CategoryAzkarPageState();
}

class _CategoryAzkarPageState extends State<CategoryAzkarPage> {
  late ZekrCategory _category;

  CurrentPlayback? _playback;
  Duration _position = Duration.zero;
  Duration? _duration;

  final Map<int, bool> _downloading = {};
  final Map<int, DownloadProgress?> _downloadProgress = {};

  StreamSubscription<CurrentPlayback?>? _playbackSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;

  @override
  void initState() {
    super.initState();
    _category = widget.category;
    final svc = Azkary.instance;
    _playbackSub = svc.currentPlaybackStream.listen((v) {
      if (mounted) setState(() => _playback = v);
    });
    _positionSub = svc.positionStream.listen((v) {
      if (mounted) setState(() => _position = v);
    });
    _durationSub = svc.durationStream.listen((v) {
      if (mounted) setState(() => _duration = v);
    });
  }

  @override
  void dispose() {
    unawaited(_playbackSub?.cancel());
    unawaited(_positionSub?.cancel());
    unawaited(_durationSub?.cancel());
    super.dispose();
  }

  int get _categoryId => _category.id;

  CurrentPlayback? get _activeZekrPlayback {
    final p = _playback;
    if (p == null || !p.isZekr) return null;
    if (p.categoryId != _categoryId) return null;
    if (p.state == PlaybackState.idle || p.state == PlaybackState.stopped) {
      return null;
    }
    return p;
  }

  Future<void> _reload() async {
    final all = await Azkary.instance.getCategories();
    if (!mounted) return;
    for (final c in all) {
      if (c.id == _categoryId) {
        setState(() => _category = c);
        return;
      }
    }
  }

  Future<void> _increment(Zekr z) async {
    HapticFeedback.lightImpact();
    try {
      final updated = await Azkary.instance.incrementZekr(_category, z.id);
      if (mounted) setState(() => _category = updated);
    } catch (e) {
      if (mounted) snackError(context, e);
    }
  }

  Future<void> _resetZekr(Zekr z) async {
    if (z.currentCount == 0) return;
    HapticFeedback.lightImpact();
    try {
      final updated = await Azkary.instance.resetZekr(_category, z.id);
      if (mounted) setState(() => _category = updated);
    } catch (e) {
      if (mounted) snackError(context, e);
    }
  }

  Future<void> _confirmResetCategory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة الفئة'),
        content: const Text(
          'سيتم تصفير عدّاد جميع أذكار هذه الفئة. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('إعادة الكل'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await Azkary.instance.resetCategory(_categoryId);
      if (!mounted) return;
      await _reload();
    } catch (e) {
      if (mounted) snackError(context, e);
    }
  }

  Future<void> _download(Zekr z) async {
    setState(() {
      _downloading[z.id] = true;
      _downloadProgress[z.id] = null;
    });
    try {
      await Azkary.instance.downloadZekrAudio(
        categoryId: _categoryId,
        zekrId: z.id,
        onProgress: (p) {
          if (mounted) setState(() => _downloadProgress[z.id] = p);
        },
      );
      if (!mounted) return;
      await _reload();
    } catch (e) {
      if (mounted) snackError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _downloading[z.id] = false;
          _downloadProgress.remove(z.id);
        });
      }
    }
  }

  Future<void> _cancelDownload(Zekr z) async {
    try {
      await Azkary.instance.cancelZekrDownload(
        categoryId: _categoryId,
        zekrId: z.id,
      );
      if (!mounted) return;
      setState(() {
        _downloading[z.id] = false;
        _downloadProgress.remove(z.id);
      });
    } catch (e) {
      if (mounted) snackError(context, e);
    }
  }

  Future<void> _play(Zekr z) async {
    try {
      await Azkary.instance.playZekrAudio(
        categoryId: _categoryId,
        zekrId: z.id,
      );
    } catch (e) {
      if (mounted) snackError(context, e);
    }
  }

  Future<void> _togglePauseResume() async {
    try {
      if (_playback?.state == PlaybackState.paused) {
        await Azkary.instance.resumeAudio();
      } else {
        await Azkary.instance.pauseAudio();
      }
    } catch (e) {
      if (mounted) snackError(context, e);
    }
  }

  Future<void> _stop() async {
    try {
      await Azkary.instance.stopAudio();
    } catch (e) {
      if (mounted) snackError(context, e);
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      await Azkary.instance.seekAudio(position);
    } catch (e) {
      if (mounted) snackError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeZekrPlayback;
    final activeZekrId = active?.zekrId;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_sharp),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(_category.name),
          actions: [
            IconButton(
              tooltip: 'تصفير عدادات الأذكار',
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: _confirmResetCategory,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  active != null ? 8 : 24,
                ),
                children: [
                  CategoryProgressHeader(category: _category),
                  const SizedBox(height: 16),
                  ..._category.azkar.map((z) {
                    final downloading = _downloading[z.id] == true;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ZekrTile(
                        zekr: z,
                        isActive:
                            zekrIsActive(_playback, _categoryId, z.id),
                        isPlaying:
                            zekrIsPlaying(_playback, _categoryId, z.id),
                        isPaused:
                            zekrIsPaused(_playback, _categoryId, z.id),
                        downloading: downloading,
                        downloadProgress: _downloadProgress[z.id],
                        onReset: () => _resetZekr(z),
                        onIncrement:
                            z.isCompleted ? null : () => _increment(z),
                        onPlay: z.hasAudio && z.isAudioDownloaded
                            ? () => _play(z)
                            : null,
                        onDownload: z.hasAudio && !z.isAudioDownloaded
                            ? () => _download(z)
                            : null,
                        onCancelDownload: downloading
                            ? () => _cancelDownload(z)
                            : null,
                        onPauseResume: _togglePauseResume,
                        onStop: _stop,
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (active != null && activeZekrId != null)
              NowPlayingBar(
                zekr: _category.azkar.firstWhere((z) => z.id == activeZekrId),
                isPlaying: active.state == PlaybackState.playing,
                position: _position,
                duration: _duration,
                onPauseResume: _togglePauseResume,
                onStop: _stop,
                onSeek: _seek,
              ),
          ],
        ),
      ),
    );
  }
}

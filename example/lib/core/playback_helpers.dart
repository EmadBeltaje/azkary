import 'package:azkary/azkary.dart';

bool zekrIsActive(CurrentPlayback? p, int categoryId, int zekrId) =>
    p != null &&
    p.categoryId == categoryId &&
    p.zekrId == zekrId &&
    (p.state == PlaybackState.playing ||
        p.state == PlaybackState.paused ||
        p.state == PlaybackState.loading);

bool zekrIsPlaying(CurrentPlayback? p, int categoryId, int zekrId) =>
    p != null &&
    p.categoryId == categoryId &&
    p.zekrId == zekrId &&
    p.state == PlaybackState.playing;

bool zekrIsPaused(CurrentPlayback? p, int categoryId, int zekrId) =>
    p != null &&
    p.categoryId == categoryId &&
    p.zekrId == zekrId &&
    p.state == PlaybackState.paused;

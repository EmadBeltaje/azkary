import 'dart:async';
import 'dart:io';

import 'package:azkary/azkary.dart';
import 'package:azkary/src/azkary_service.dart';
import 'package:azkary/src/core/constants/hive_constants.dart';
import 'package:azkary/src/core/errors/azkary_exception.dart';
import 'package:azkary/src/domain/entities/current_playback.dart';
import 'package:azkary/src/domain/entities/zekr_category.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.createTempSync('azkary_docs').path;
      }
      return null;
    });
  });

  group('Azkary facade', () {
    test('instance before initialize throws NotInitializedException', () {
      expect(() => Azkary.instance, throwsA(isA<NotInitializedException>()));
    });
  });

  group('AzkaryService integration', () {
    late AzkaryService service;

    setUp(() async {
      await Hive.close();
      try {
        await Hive.deleteFromDisk();
      } catch (_) {}
      service = await AzkaryService.create();
    });

    tearDown(() async {
      await service.dispose();
      await Hive.close();
      try {
        await Hive.deleteFromDisk();
      } catch (_) {}
    });

    test('getCategories loads bundled data', () async {
      expect(await service.getCategories(), isNotEmpty);
    });

    test('incrementZekr persists progress', () async {
      final category = (await service.getCategories()).first;
      final zekrId = category.azkar.first.id;

      final updated = await service.incrementZekr(category, zekrId);

      expect(
        updated.azkar.first.currentCount,
        category.azkar.first.currentCount + 1,
      );
    });

    test('currentPlaybackStream emits null before play', () async {
      CurrentPlayback? first;
      final sub = service.currentPlaybackStream.listen((v) => first ??= v);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      expect(first, isNull);
    });

    test('cancelAllDownloads returns zero when idle', () async {
      expect(await service.cancelAllDownloads(), 0);
    });

    test('sabah category auto-resets when morning phase changes', () async {
      final yesterdayMorning = DateTime(2026, 5, 18, 8, 0);
      final todayMorning = DateTime(2026, 5, 19, 7, 0);

      await withClock(Clock.fixed(todayMorning), () async {
        final sabah = (await service.getCategories()).firstWhere(
          (c) => c.type == CategoryType.sabah,
        );

        await service.incrementZekr(sabah, sabah.azkar.first.id);

        await Hive.box<String>(HiveConstants.metaBox).put(
          '${HiveConstants.lastResetPrefix}${sabah.id}',
          yesterdayMorning.toIso8601String(),
        );

        final afterReset = (await service.getCategories()).firstWhere(
          (c) => c.id == sabah.id,
        );

        expect(afterReset.azkar.every((z) => z.currentCount == 0), isTrue);
      });
    });
  });

  group('fake_async', () {
    test('flushes scheduled microtasks', () {
      fakeAsync((async) {
        var ran = false;
        scheduleMicrotask(() => ran = true);
        expect(ran, isFalse);
        async.flushMicrotasks();
        expect(ran, isTrue);
      });
    });
  });

  group('Azkary.initialize', () {
    tearDown(() async {
      await Hive.close();
      try {
        await Hive.deleteFromDisk();
      } catch (_) {}
    });

    test('returns true and exposes instance', () async {
      expect(await Azkary.initialize(), isTrue);
      expect(await Azkary.instance.getCategories(), isNotEmpty);
      await Azkary.instance.dispose();
    });
  });
}

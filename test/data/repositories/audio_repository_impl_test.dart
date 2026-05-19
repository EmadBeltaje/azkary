import 'dart:async';
import 'dart:io';

import 'package:azkary/src/core/constants/hive_constants.dart';
import 'package:azkary/src/core/constants/package_constants.dart';
import 'package:azkary/src/core/errors/azkary_exception.dart';
import 'package:azkary/src/data/models/zekr_category_model.dart';
import 'package:azkary/src/data/models/zekr_model.dart';
import 'package:azkary/src/data/repositories/audio_repository_impl.dart';
import 'package:azkary/src/data/sources/audio_downloader.dart';
import 'package:azkary/src/data/sources/dio_audio_downloader.dart';
import 'package:azkary/src/domain/entities/current_playback.dart';
import 'package:azkary/src/domain/entities/download_progress.dart';
import 'package:azkary/src/domain/entities/playback_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mocks.mocks.dart';

ZekrCategoryModel _category({List<ZekrModel>? azkar}) => ZekrCategoryModel(
      id: 1,
      name: 'Test',
      type: 'general',
      azkar: azkar ??
          [
            ZekrModel(
              id: 1,
              text: 'zekr',
              count: 3,
              currentCount: 0,
              audio: '/audio/75.mp3',
              filename: '75',
            ),
          ],
      audio: '/audio/cat.mp3',
      filename: 'cat',
    );

void main() {
  late MockAzkarLocalSource azkar;
  late MockAudioDownloader downloader;
  late MockAudioPlayerSource player;
  late MockAudioStorageSource storage;
  late Directory audioDir;
  late AudioRepositoryImpl repo;
  late StreamController<PlaybackState> stateCtrl;

  AudioRepositoryImpl buildRepo({
    DownloadCancelToken Function()? cancelTokenFactory,
  }) {
    return AudioRepositoryImpl(
      azkarLocal: azkar,
      downloader: downloader,
      player: player,
      storage: storage,
      audioDir: audioDir,
      cancelTokenFactory: cancelTokenFactory ?? DioDownloadCancelToken.new,
    );
  }

  setUp(() {
    azkar = MockAzkarLocalSource();
    downloader = MockAudioDownloader();
    player = MockAudioPlayerSource();
    storage = MockAudioStorageSource();
    audioDir = Directory.systemTemp.createTempSync('azkary_audio_test');
    stateCtrl = StreamController<PlaybackState>.broadcast();

    when(azkar.readCategories()).thenAnswer((_) async => [_category()]);
    when(player.stateStream).thenAnswer((_) => stateCtrl.stream);
    when(player.positionStream).thenAnswer((_) => const Stream<Duration>.empty());
    when(player.durationStream)
        .thenAnswer((_) => const Stream<Duration?>.empty());
    when(player.stop()).thenAnswer((_) async {});
    when(player.pause()).thenAnswer((_) async {});
    when(player.play()).thenAnswer((_) async {
      stateCtrl.add(PlaybackState.playing);
    });

    repo = buildRepo();
  });

  tearDown(() async {
    await stateCtrl.close();
    await repo.dispose();
    if (audioDir.existsSync()) {
      audioDir.deleteSync(recursive: true);
    }
  });

  group('downloadZekr', () {
    test('stores path and forwards progress', () async {
      when(
        downloader.download(
          url: anyNamed('url'),
          destinationPath: anyNamed('destinationPath'),
          onProgress: anyNamed('onProgress'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((inv) async {
        final dest = inv.namedArguments[#destinationPath] as String;
        await File(dest).writeAsBytes(const [1, 2, 3]);
        final onProgress =
            inv.namedArguments[#onProgress] as DownloadProgressCallback?;
        onProgress?.call(const DownloadProgress(received: 100, total: 100));
      });
      when(storage.get(any)).thenAnswer((_) async => null);
      when(storage.put(any, any)).thenAnswer((_) async {});

      DownloadProgress? last;
      await repo.downloadZekr(1, 1, onProgress: (p) => last = p);

      verify(
        downloader.download(
          url: '${PackageConstants.audioBaseUrl}/audio/75.mp3',
          destinationPath: argThat(contains('75.mp3'), named: 'destinationPath'),
          onProgress: anyNamed('onProgress'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).called(1);
      verify(storage.put(HiveConstants.zekrAudioKey(1, 1), any)).called(1);
      expect(last?.isComplete, isTrue);
    });

    test('throws AlreadyDownloadedException when on disk', () async {
      final path = '${audioDir.path}/75.mp3';
      await File(path).writeAsBytes(const [1]);
      when(storage.get(HiveConstants.zekrAudioKey(1, 1)))
          .thenAnswer((_) async => path);

      expect(
        () => repo.downloadZekr(1, 1),
        throwsA(isA<AlreadyDownloadedException>()),
      );
      verifyNever(downloader.download(
        url: anyNamed('url'),
        destinationPath: anyNamed('destinationPath'),
        onProgress: anyNamed('onProgress'),
        cancelToken: anyNamed('cancelToken'),
      ));
    });

    test('throws DownloadAlreadyInProgressException for duplicate call', () async {
      final gate = Completer<void>();
      when(
        downloader.download(
          url: anyNamed('url'),
          destinationPath: anyNamed('destinationPath'),
          onProgress: anyNamed('onProgress'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((_) => gate.future);
      when(storage.get(any)).thenAnswer((_) async => null);

      final first = repo.downloadZekr(1, 1);
      await Future<void>.delayed(Duration.zero);

      expect(
        () => repo.downloadZekr(1, 1),
        throwsA(isA<DownloadAlreadyInProgressException>()),
      );

      gate.complete();
      await first;
    });

    test('cancelZekrDownload throws DownloadCancelledException', () async {
      final token = MockDownloadCancelToken();
      var cancelled = false;
      when(token.isCancelled).thenAnswer((_) => cancelled);
      when(token.cancel(any)).thenAnswer((_) {
        cancelled = true;
      });

      when(
        downloader.download(
          url: anyNamed('url'),
          destinationPath: anyNamed('destinationPath'),
          onProgress: anyNamed('onProgress'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((inv) async {
        final t = inv.namedArguments[#cancelToken] as DownloadCancelToken?;
        while (t?.isCancelled != true) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
        throw DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.cancel,
        );
      });
      when(storage.get(any)).thenAnswer((_) async => null);

      repo = buildRepo(cancelTokenFactory: () => token);

      final future = repo.downloadZekr(1, 1);
      await Future<void>.delayed(Duration.zero);
      expect(await repo.cancelZekrDownload(1, 1), isTrue);

      await expectLater(future, throwsA(isA<DownloadCancelledException>()));
    });
  });

  group('playback', () {
    test('playZekr loads file and emits loading', () async {
      final path = '${audioDir.path}/75.mp3';
      await File(path).writeAsBytes(const [1]);
      when(storage.get(HiveConstants.zekrAudioKey(1, 1)))
          .thenAnswer((_) async => path);
      when(player.loadFile(path)).thenAnswer((_) async {});

      final states = <CurrentPlayback?>[];
      final sub = repo.currentPlaybackStream.listen(states.add);

      await repo.playZekr(1, 1);

      verify(player.stop()).called(1);
      verify(player.loadFile(path)).called(1);
      verify(player.play()).called(1);
      expect(
        states.any(
          (s) =>
              s?.categoryId == 1 &&
              s?.zekrId == 1 &&
              s?.state == PlaybackState.loading,
        ),
        isTrue,
      );

      await sub.cancel();
    });

    test('playZekr throws AudioNotDownloadedException when missing', () async {
      when(storage.get(any)).thenAnswer((_) async => null);

      expect(
        () => repo.playZekr(1, 1),
        throwsA(isA<AudioNotDownloadedException>()),
      );
    });

    test('seek throws PlaybackException when idle', () async {
      expect(
        () => repo.seek(const Duration(seconds: 1)),
        throwsA(isA<PlaybackException>()),
      );
    });
  });

  group('downloadAllAudios', () {
    test('skips downloaded files and reports aggregate progress', () async {
      final path = '${audioDir.path}/75.mp3';
      await File(path).writeAsBytes(const [1]);
      when(storage.get(HiveConstants.zekrAudioKey(1, 1)))
          .thenAnswer((_) async => path);
      when(storage.get(argThat(isNot(HiveConstants.zekrAudioKey(1, 1)))))
          .thenAnswer((_) async => null);
      when(storage.put(any, any)).thenAnswer((_) async {});
      when(
        downloader.download(
          url: anyNamed('url'),
          destinationPath: anyNamed('destinationPath'),
          onProgress: anyNamed('onProgress'),
          cancelToken: anyNamed('cancelToken'),
        ),
      ).thenAnswer((inv) async {
        final dest = inv.namedArguments[#destinationPath] as String;
        await File(dest).writeAsBytes(const [1]);
      });

      var lastCompleted = -1;
      await repo.downloadAllAudios(
        onProgress: (p) => lastCompleted = p.completedItems,
      );

      expect(lastCompleted, greaterThan(0));
      verifyNever(
        downloader.download(
          url: argThat(contains('75.mp3'), named: 'url'),
          destinationPath: anyNamed('destinationPath'),
          onProgress: anyNamed('onProgress'),
          cancelToken: anyNamed('cancelToken'),
        ),
      );
    });
  });
}

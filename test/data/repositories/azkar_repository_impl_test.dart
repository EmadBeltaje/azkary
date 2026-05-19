import 'package:azkary/src/core/constants/hive_constants.dart';
import 'package:azkary/src/data/models/zekr_category_model.dart';
import 'package:azkary/src/data/models/zekr_model.dart';
import 'package:azkary/src/data/repositories/azkar_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mocks.mocks.dart';

ZekrCategoryModel _category({int id = 1, int zekrId = 10}) => ZekrCategoryModel(
      id: id,
      name: 'Morning',
      type: 'sabah',
      azkar: [
        ZekrModel(
          id: zekrId,
          text: 'text',
          count: 3,
          currentCount: 1,
          audio: '/audio/75.mp3',
          filename: '75',
        ),
      ],
      audio: '/audio/cat.mp3',
      filename: 'cat',
    );

void main() {
  late MockAzkarLocalSource local;
  late MockAzkarAssetSource asset;
  late MockAudioRepository audio;
  late AzkarRepositoryImpl repo;

  setUp(() {
    local = MockAzkarLocalSource();
    asset = MockAzkarAssetSource();
    audio = MockAudioRepository();
    repo = AzkarRepositoryImpl(
      localSource: local,
      assetSource: asset,
      audioRepository: audio,
    );
    when(audio.readAllDownloadedPaths()).thenAnswer((_) async => {});
  });

  test('cache miss loads asset, persists, and returns entities', () async {
    final models = [_category()];
    when(local.hasCache()).thenAnswer((_) async => false);
    when(asset.loadCategories()).thenAnswer((_) async => models);
    when(local.writeCategories(any)).thenAnswer((_) async {});

    final categories = await repo.getCategories();

    verify(asset.loadCategories()).called(1);
    verify(local.writeCategories(models)).called(1);
    verifyNever(local.readCategories());
    expect(categories, hasLength(1));
    expect(categories.first.id, 1);
    verify(audio.readAllDownloadedPaths()).called(1);
  });

  test('cache hit reads local only and never touches asset', () async {
    final models = [_category()];
    when(local.hasCache()).thenAnswer((_) async => true);
    when(local.readCategories()).thenAnswer((_) async => models);
    when(local.getLastResetTime(1))
        .thenAnswer((_) async => '2026-05-19T08:00:00.000');

    final categories = await repo.getCategories();

    verify(local.readCategories()).called(1);
    verifyNever(asset.loadCategories());
    verifyNever(local.writeCategories(any));
    expect(categories.first.lastResetTime, isNotNull);
  });

  test('enriches localAudioPath from audio index', () async {
    when(local.hasCache()).thenAnswer((_) async => true);
    when(local.readCategories()).thenAnswer((_) async => [_category(id: 2, zekrId: 5)]);
    when(local.getLastResetTime(any)).thenAnswer((_) async => null);
    when(audio.readAllDownloadedPaths()).thenAnswer(
      (_) async => {
        HiveConstants.zekrAudioKey(2, 5): '/tmp/zekr.mp3',
        HiveConstants.categoryAudioKey(2): '/tmp/cat.mp3',
      },
    );

    final cat = (await repo.getCategories()).single;

    expect(cat.localAudioPath, '/tmp/cat.mp3');
    expect(cat.azkar.single.localAudioPath, '/tmp/zekr.mp3');
  });

  test('saveZekrProgress delegates to local', () async {
    when(local.updateZekrProgress(1, 10, 2)).thenAnswer((_) async {});

    await repo.saveZekrProgress(1, 10, 2);

    verify(local.updateZekrProgress(1, 10, 2)).called(1);
  });

  test('clearCache delegates to local', () async {
    when(local.clearAll()).thenAnswer((_) async {});

    await repo.clearCache();

    verify(local.clearAll()).called(1);
  });
}

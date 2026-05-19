import '../../domain/entities/zekr_category.dart';
import '../../domain/repositories/audio_repository.dart';
import '../../domain/repositories/azkar_repository.dart';
import '../sources/azkar_asset_source.dart';
import '../sources/azkar_local_source.dart';

/// Orchestrates the cache-or-parse decision and all persistence operations.
class AzkarRepositoryImpl implements AzkarRepository {
  const AzkarRepositoryImpl({
    required AzkarLocalSource localSource,
    required AzkarAssetSource assetSource,
    required AudioRepository audioRepository,
  })  : _local = localSource,
        _asset = assetSource,
        _audio = audioRepository;

  final AzkarLocalSource _local;
  final AzkarAssetSource _asset;
  final AudioRepository _audio;

  @override
  Future<List<ZekrCategory>> getCategories() async {
    final paths = await _audio.readAllDownloadedPaths();

    if (await _local.hasCache()) {
      final models = await _local.readCategories();
      for (final model in models) {
        model.lastResetTime = await _local.getLastResetTime(model.id);
      }
      return models.map((m) => m.toEntity(paths: paths)).toList();
    }

    final models = await _asset.loadCategories();
    await _local.writeCategories(models);
    return models.map((m) => m.toEntity(paths: paths)).toList();
  }

  @override
  Future<void> saveZekrProgress(int categoryId, int zekrId, int newCount) =>
      _local.updateZekrProgress(categoryId, zekrId, newCount);

  @override
  Future<void> resetCategory(int categoryId) =>
      _local.resetCategory(categoryId);

  @override
  Future<void> saveLastResetTime(int categoryId, DateTime time) =>
      _local.saveLastResetTime(categoryId, time.toIso8601String());

  @override
  Future<DateTime?> getLastResetTime(int categoryId) async {
    final raw = await _local.getLastResetTime(categoryId);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  @override
  Future<void> clearCache() => _local.clearAll();
}

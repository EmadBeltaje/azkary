import 'package:hive/hive.dart';

import '../../core/constants/hive_constants.dart';
import '../../core/constants/package_constants.dart';
import '../../core/errors/azkary_exception.dart';
import '../models/zekr_category_model.dart';
import 'azkar_local_source.dart';

class HiveAzkarSource implements AzkarLocalSource {
  HiveAzkarSource({required this.categoriesBox, required this.metaBox});

  final Box<ZekrCategoryModel> categoriesBox;
  final Box<String> metaBox;

  @override
  Future<bool> hasCache() async => categoriesBox.isNotEmpty;

  @override
  Future<List<ZekrCategoryModel>> readCategories() async {
    try {
      final list = categoriesBox.values.toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      return list;
    } catch (e) {
      throw StorageException(PackageConstants.hiveReadCategoriesFailed, cause: e);
    }
  }

  @override
  Future<void> writeCategories(List<ZekrCategoryModel> categories) async {
    try {
      await categoriesBox.clear();
      await categoriesBox.putAll({for (final c in categories) c.id: c});
    } catch (e) {
      throw StorageException(PackageConstants.hiveWriteCategoriesFailed, cause: e);
    }
  }

  @override
  Future<void> updateZekrProgress(
    int categoryId, int zekrId, int newCount,
  ) async {
    try {
      final category = categoriesBox.get(categoryId);
      if (category == null) {
        throw NotFoundException(PackageConstants.hiveCategoryNotFound(categoryId));
      }
      final zekr = category.azkar.firstWhere(
        (z) => z.id == zekrId,
        orElse: () => throw NotFoundException(
          PackageConstants.zekrNotFoundInCategory(zekrId, categoryId),
        ),
      );
      zekr.currentCount = newCount;
      await category.save(); // HiveObject.save() writes back to the box
    } on AzkaryException {
      rethrow;
    } catch (e) {
      throw StorageException(PackageConstants.hiveUpdateZekrProgressFailed, cause: e);
    }
  }

  @override
  Future<void> resetCategory(int categoryId) async {
    try {
      final category = categoriesBox.get(categoryId);
      if (category == null) {
        throw NotFoundException(PackageConstants.hiveCategoryNotFound(categoryId));
      }
      for (final zekr in category.azkar) {
        zekr.currentCount = 0;
      }
      await category.save();
    } on AzkaryException {
      rethrow;
    } catch (e) {
      throw StorageException(PackageConstants.hiveResetCategoryFailed(categoryId), cause: e);
    }
  }

  @override
  Future<void> saveLastResetTime(int categoryId, String isoTimestamp) async {
    try {
      await metaBox.put('${HiveConstants.lastResetPrefix}$categoryId', isoTimestamp);
    } catch (e) {
      throw StorageException(PackageConstants.hiveSaveLastResetFailed, cause: e);
    }
  }

  @override
  Future<String?> getLastResetTime(int categoryId) async {
    try {
      return metaBox.get('${HiveConstants.lastResetPrefix}$categoryId');
    } catch (e) {
      throw StorageException(PackageConstants.hiveReadLastResetFailed, cause: e);
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await categoriesBox.clear();
      await metaBox.clear();
    } catch (e) {
      throw StorageException(PackageConstants.hiveClearCacheFailed, cause: e);
    }
  }
}

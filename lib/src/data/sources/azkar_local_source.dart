import '../models/zekr_category_model.dart';

/// Contract for local persistence. Swap with a fake in tests.
abstract interface class AzkarLocalSource {
  Future<bool> hasCache();
  Future<List<ZekrCategoryModel>> readCategories();
  Future<void> writeCategories(List<ZekrCategoryModel> categories);
  Future<void> updateZekrProgress(int categoryId, int zekrId, int newCount);
  Future<void> resetCategory(int categoryId);
  Future<void> saveLastResetTime(int categoryId, String isoTimestamp);
  Future<String?> getLastResetTime(int categoryId);
  Future<void> clearAll();
}

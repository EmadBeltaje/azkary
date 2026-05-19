import '../entities/zekr_category.dart';

abstract interface class AzkarRepository {
  /// returns all categories with current user progress.
  /// implementations must check the Hive cache first;
  /// parse the bundled JSON only on first launch or after clearCache().
  Future<List<ZekrCategory>> getCategories();

  /// save incremented progress for a single zekr.
  Future<void> saveZekrProgress(int categoryId, int zekrId, int newCount);

  /// reset all azkar in a category (currentCount → 0) in Hive.
  Future<void> resetCategory(int categoryId);

  /// records the timestamp of the most recent reset for a category.
  Future<void> saveLastResetTime(int categoryId, DateTime time);

  /// returns null if the category has never completed a reset cycle.
  Future<DateTime?> getLastResetTime(int categoryId);

  /// wipes all Hive data. Next getCategories() call re-parses the JSON.
  /// cuz the cache would be empty ofc :v
  Future<void> clearCache();
}

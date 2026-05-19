import '../models/zekr_category_model.dart';

abstract interface class AzkarAssetSource {
  Future<List<ZekrCategoryModel>> loadCategories();
}

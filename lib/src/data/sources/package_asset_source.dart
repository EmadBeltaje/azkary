import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/constants/package_constants.dart';
import '../../core/errors/azkary_exception.dart';
import '../models/zekr_category_model.dart';
import 'azkar_asset_source.dart';

class PackageAssetSource implements AzkarAssetSource {
  const PackageAssetSource();

  @override
  Future<List<ZekrCategoryModel>> loadCategories() async {
    late final String jsonContent;

    try {
      jsonContent = await rootBundle.loadString(PackageConstants.azkarAssetPath);
    } catch (e) {
      throw AssetLoadException(
        PackageConstants.assetLoadFailed,
        cause: e,
      );
    }

    try {
      final decoded = jsonDecode(jsonContent);
      if (decoded is! List) {
        throw ParseException(
          '${PackageConstants.jsonRootMustBeArrayPrefix}${decoded.runtimeType}',
        );
      }
      return decoded
          .cast<Map<String, dynamic>>()
          .map(ZekrCategoryModel.fromJson)
          .toList();
    } on ParseException {
      rethrow;
    } catch (e) {
      throw ParseException(PackageConstants.jsonDecodeFailed, cause: e);
    }
  }
}

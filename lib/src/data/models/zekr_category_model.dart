import 'package:hive/hive.dart';

import '../../core/constants/hive_constants.dart';
import '../../core/constants/package_constants.dart';
import '../../core/errors/azkary_exception.dart';
import '../../domain/entities/zekr_category.dart';
import 'zekr_model.dart';

part 'zekr_category_model.g.dart';

@HiveType(typeId: HiveConstants.categoryTypeId)
class ZekrCategoryModel extends HiveObject {
  ZekrCategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.azkar,
    this.lastResetTime,
    this.audio,
    this.filename,
  });

  @HiveField(0) int id;
  @HiveField(1) String name;
  @HiveField(2) String type;              // 'sabah' | 'masaa' | 'general'
  @HiveField(3) List<ZekrModel> azkar;
  @HiveField(4) String? lastResetTime;
  @HiveField(5) String? audio;
  @HiveField(6) String? filename;

  factory ZekrCategoryModel.fromJson(Map<String, dynamic> json) {
    try {
      final nameRaw = (json['category'] ?? json['name']) as String;
      final rawList =
          (json['array'] ?? json['azkar']) as List<dynamic>? ?? const [];
      final azkarList = rawList
          .map((e) => ZekrModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ZekrCategoryModel(
        id: json['id'],
        name: nameRaw,
        type: (json['type'] as String?) ?? _resolveTypeKey(nameRaw),
        azkar: azkarList,
        lastResetTime: null,
        audio: json['audio'] as String?,
        filename: json['filename'] as String?,
      );
    } catch (e) {
      throw ParseException(
        PackageConstants.parseZekrCategoryFailed(json),
        cause: e,
      );
    }
  }

  ZekrCategory toEntity({Map<String, String> paths = const {}}) =>
      ZekrCategory(
        id: id,
        name: name,
        azkar: azkar.map((m) => m.toEntity(id, paths: paths)).toList(),
        type: _parseType(type),
        lastResetTime:
            lastResetTime != null ? DateTime.tryParse(lastResetTime!) : null,
        audio: audio,
        filename: filename,
        localAudioPath: paths[HiveConstants.categoryAudioKey(id)],
      );

  static CategoryType _parseType(String raw) => switch (raw) {
    'sabah'  => CategoryType.sabah,
    'masaa'  => CategoryType.masaa,
    _        => CategoryType.general,
  };

  static String _resolveTypeKey(String categoryTitle) {
    final hasSabah = categoryTitle.contains('صباح');
    final hasMasaa = categoryTitle.contains('مساء');
    if (hasSabah) return 'sabah';
    if (hasMasaa) return 'masaa';
    return 'general';
  }
}

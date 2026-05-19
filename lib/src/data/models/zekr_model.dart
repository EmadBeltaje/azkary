import 'package:hive/hive.dart';

import '../../core/constants/hive_constants.dart';
import '../../core/constants/package_constants.dart';
import '../../core/errors/azkary_exception.dart';
import '../../domain/entities/zekr.dart';

part 'zekr_model.g.dart';

@HiveType(typeId: HiveConstants.zekrTypeId)
class ZekrModel extends HiveObject {
  ZekrModel({
    required this.id,
    required this.text,
    required this.count,
    required this.currentCount,
    this.audio,
    this.filename,
  });

  @HiveField(0) int id;
  @HiveField(1) String text;
  @HiveField(2) int count;
  @HiveField(3) int currentCount;
  @HiveField(4) String? audio;
  @HiveField(5) String? filename;

  factory ZekrModel.fromJson(Map<String, dynamic> json) {
    try {
      return ZekrModel(
        id: json['id'],
        text: json['text'] as String,
        count: json['count'],
        currentCount: 0, // will be filled later by local storage (hive)
        audio: json['audio'] as String?,
        filename: json['filename'] as String?,
      );
    } catch (e) {
      throw ParseException(
        PackageConstants.parseZekrFailed(json),
        cause: e,
      );
    }
  }

  Zekr toEntity(int categoryId, {Map<String, String> paths = const {}}) {
    final key = HiveConstants.zekrAudioKey(categoryId, id);
    final local = paths[key];
    return Zekr(
      id: id,
      text: text,
      count: count,
      currentCount: currentCount,
      audio: audio,
      filename: filename,
      localAudioPath: local,
    );
  }
}

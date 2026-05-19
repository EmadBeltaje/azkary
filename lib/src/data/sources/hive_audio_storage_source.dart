import 'package:hive/hive.dart';

import '../../core/constants/package_constants.dart';
import '../../core/errors/azkary_exception.dart';
import 'audio_storage_source.dart';

class HiveAudioStorageSource implements AudioStorageSource {
  HiveAudioStorageSource({required this.box});

  final Box<String> box;

  @override
  Future<bool> has(String key) async => box.containsKey(key);

  @override
  Future<String?> get(String key) async => box.get(key);

  @override
  Future<void> put(String key, String localFilePath) async {
    try {
      await box.put(key, localFilePath);
    } catch (e) {
      throw StorageException(PackageConstants.hiveSaveAudioPathFailed, cause: e);
    }
  }

  @override
  Future<void> remove(String key) async {
    await box.delete(key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    final downloadedPaths = <String, String>{};
    for (final hiveKey in box.keys) {
      final storageKey = hiveKey.toString();
      final localPath = box.get(storageKey);
      if (localPath != null) {
        downloadedPaths[storageKey] = localPath;
      }
    }
    return downloadedPaths;
  }

  @override
  Future<void> clearAll() async {
    await box.clear();
  }
}

import 'package:azkary/src/data/sources/audio_downloader.dart';
import 'package:azkary/src/data/sources/audio_player_source.dart';
import 'package:azkary/src/data/sources/audio_storage_source.dart';
import 'package:azkary/src/data/sources/azkar_asset_source.dart';
import 'package:azkary/src/data/sources/azkar_local_source.dart';
import 'package:azkary/src/domain/repositories/audio_repository.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  AzkarLocalSource,
  AzkarAssetSource,
  AudioRepository,
  AudioDownloader,
  AudioPlayerSource,
  AudioStorageSource,
  DownloadCancelToken,
])
void main() {}

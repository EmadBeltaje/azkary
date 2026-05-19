import '../../core/constants/package_constants.dart';
import '../../core/errors/azkary_exception.dart';
import '../entities/zekr.dart';
import '../entities/zekr_category.dart';
import '../repositories/azkar_repository.dart';

class IncrementZekrUseCase {
  const IncrementZekrUseCase(this._repository);
  final AzkarRepository _repository;

  Future<ZekrCategory> call(ZekrCategory category, int zekrId) async {
    final index = category.azkar.indexWhere((z) => z.id == zekrId);
    if (index == -1) {
      throw NotFoundException(
        PackageConstants.zekrNotFoundInCategory(zekrId, category.id),
      );
    }

    final zekr = category.azkar[index];
    if (zekr.isCompleted) return category;

    final newCount = zekr.currentCount + 1;
    await _repository.saveZekrProgress(category.id, zekrId, newCount);

    final updatedAzkar = List<Zekr>.from(category.azkar)
      ..[index] = zekr.copyWith(currentCount: newCount);

    return category.copyWith(azkar: updatedAzkar);
  }
}

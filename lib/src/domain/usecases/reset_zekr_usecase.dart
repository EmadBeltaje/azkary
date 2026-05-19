import '../../core/constants/package_constants.dart';
import '../../core/errors/azkary_exception.dart';
import '../entities/zekr.dart';
import '../entities/zekr_category.dart';
import '../repositories/azkar_repository.dart';

class ResetZekrUseCase {
  const ResetZekrUseCase(this._repository);
  final AzkarRepository _repository;

  Future<ZekrCategory> call(ZekrCategory category, int zekrId) async {
    final index = category.azkar.indexWhere((z) => z.id == zekrId);
    if (index == -1) {
      throw NotFoundException(
        PackageConstants.zekrNotFoundInCategory(zekrId, category.id),
      );
    }

    await _repository.saveZekrProgress(category.id, zekrId, 0);

    final updatedAzkar = List<Zekr>.from(category.azkar)
      ..[index] = category.azkar[index].copyWith(currentCount: 0);

    return category.copyWith(azkar: updatedAzkar);
  }
}

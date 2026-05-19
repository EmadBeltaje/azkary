import 'package:clock/clock.dart';

import '../repositories/azkar_repository.dart';

class ResetCategoryUseCase {
  const ResetCategoryUseCase(this._repository);
  final AzkarRepository _repository;

  Future<void> call(int categoryId) async {
    await _repository.resetCategory(categoryId);
    await _repository.saveLastResetTime(categoryId, clock.now());
  }
}

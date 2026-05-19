import '../entities/zekr_category.dart';
import '../repositories/azkar_repository.dart';

class LoadAzkarUseCase {
  const LoadAzkarUseCase(this._repository);
  final AzkarRepository _repository;

  Future<List<ZekrCategory>> call() => _repository.getCategories();
}

import '../../entities/category_task_entity.dart';
import '../../repositories/category_task_repository.dart';

/// 카테고리별 할일 조회 UseCase
class GetTasksByCategoryUseCase {
  final CategoryTaskRepository _repository;

  GetTasksByCategoryUseCase(this._repository);

  Future<List<CategoryTaskEntity>> call(String categoryId) {
    return _repository.getByCategoryId(categoryId);
  }
}

import '../../repositories/category_task_repository.dart';

/// 카테고리에서 할일 제거 UseCase
class RemoveTaskFromCategoryUseCase {
  final CategoryTaskRepository _repository;

  RemoveTaskFromCategoryUseCase(this._repository);

  Future<void> call(String categoryTaskId) {
    return _repository.delete(categoryTaskId);
  }
}

import '../../repositories/category_task_repository.dart';

/// 카테고리 내 할일 순서 변경 UseCase
class ReorderCategoryTasksUseCase {
  final CategoryTaskRepository _repository;

  ReorderCategoryTasksUseCase(this._repository);

  Future<void> call(String categoryId, List<String> orderedIds) {
    return _repository.reorder(categoryId, orderedIds);
  }
}

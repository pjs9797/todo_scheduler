import '../../repositories/category_repository.dart';
import '../../repositories/task_repository.dart';

/// 카테고리 삭제 UseCase
class DeleteCategoryUseCase {
  final CategoryRepository _categoryRepository;
  final TaskRepository _taskRepository;

  DeleteCategoryUseCase(this._categoryRepository, this._taskRepository);

  /// 카테고리 삭제
  /// 해당 카테고리에 속한 할 일은 미분류로 이동
  Future<void> call(String categoryId) async {
    // 해당 카테고리의 할 일들을 미분류로 이동
    await _taskRepository.unassignTasksByCategory(categoryId);

    // 카테고리 삭제
    await _categoryRepository.deleteCategory(categoryId);
  }
}

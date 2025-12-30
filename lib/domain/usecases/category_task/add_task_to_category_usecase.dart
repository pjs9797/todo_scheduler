import '../../entities/category_task_entity.dart';
import '../../repositories/category_task_repository.dart';
import '../../repositories/task_template_repository.dart';

/// 카테고리에 할일 추가 UseCase
class AddTaskToCategoryUseCase {
  final CategoryTaskRepository _categoryTaskRepository;
  final TaskTemplateRepository _templateRepository;

  AddTaskToCategoryUseCase(this._categoryTaskRepository, this._templateRepository);

  /// 카테고리에 할일 추가
  /// [categoryId]: 카테고리 ID
  /// [taskTemplateId]: 할일 템플릿 ID
  ///
  /// Throws [ArgumentError] if task already exists in category
  Future<CategoryTaskEntity> call({
    required String categoryId,
    required String taskTemplateId,
  }) async {
    final exists = await _categoryTaskRepository.exists(
      categoryId: categoryId,
      taskTemplateId: taskTemplateId,
    );

    if (exists) {
      throw ArgumentError('이미 카테고리에 추가된 할일입니다.');
    }

    final existing = await _categoryTaskRepository.getByCategoryId(categoryId);
    final nextSortOrder = existing.isEmpty
        ? 0
        : existing.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    final result = await _categoryTaskRepository.add(
      categoryId: categoryId,
      taskTemplateId: taskTemplateId,
      sortOrder: nextSortOrder,
    );

    await _templateRepository.updateLastUsedAt(taskTemplateId);

    return result;
  }
}

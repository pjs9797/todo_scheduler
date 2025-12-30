import '../../entities/category_task_entity.dart';
import '../../repositories/category_task_repository.dart';
import '../../repositories/task_template_repository.dart';

/// 카테고리에 여러 할일 추가 UseCase
class AddMultipleTasksToCategoryUseCase {
  final CategoryTaskRepository _categoryTaskRepository;
  final TaskTemplateRepository _templateRepository;

  AddMultipleTasksToCategoryUseCase(this._categoryTaskRepository, this._templateRepository);

  /// 카테고리에 여러 할일 추가 (이미 있는 할일은 스킵)
  Future<List<CategoryTaskEntity>> call({
    required String categoryId,
    required List<String> taskTemplateIds,
  }) async {
    final results = <CategoryTaskEntity>[];

    for (final templateId in taskTemplateIds) {
      final exists = await _categoryTaskRepository.exists(
        categoryId: categoryId,
        taskTemplateId: templateId,
      );

      if (!exists) {
        final existing = await _categoryTaskRepository.getByCategoryId(categoryId);
        final nextSortOrder = existing.isEmpty
            ? 0
            : existing.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

        final result = await _categoryTaskRepository.add(
          categoryId: categoryId,
          taskTemplateId: templateId,
          sortOrder: nextSortOrder,
        );
        results.add(result);

        await _templateRepository.updateLastUsedAt(templateId);
      }
    }

    return results;
  }
}

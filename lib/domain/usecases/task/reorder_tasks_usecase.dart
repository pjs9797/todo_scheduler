import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

/// 할 일 순서 변경 UseCase
class ReorderTasksUseCase {
  final TaskRepository _repository;

  ReorderTasksUseCase(this._repository);

  /// 할 일 순서 변경
  /// [tasks]: 새로운 순서로 정렬된 할 일 목록
  Future<void> call(List<TaskEntity> tasks) async {
    // sortOrder 재할당 (0부터 시작)
    final reordered = tasks.asMap().entries.map((e) {
      return e.value.copyWith(sortOrder: e.key);
    }).toList();

    await _repository.reorderTasks(reordered);
  }
}

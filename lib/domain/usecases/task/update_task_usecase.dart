import '../../entities/task_entity.dart';
import '../../entities/task_filter.dart';
import '../../repositories/task_repository.dart';

/// 할 일 수정 UseCase
class UpdateTaskUseCase {
  final TaskRepository _repository;

  UpdateTaskUseCase(this._repository);

  /// 할 일 수정
  /// [task]: 수정할 할 일 (id로 식별)
  /// [title]: 새 제목 (optional)
  /// [minutes]: 새 소요 시간 (optional)
  /// [categoryId]: 새 카테고리 ID (optional, null 허용을 위해 함수 타입)
  ///
  /// Throws [ArgumentError] if title is empty or minutes < 1
  Future<TaskEntity> call({
    required TaskEntity task,
    String? title,
    int? minutes,
    String? Function()? categoryId,
  }) async {
    final newTitle = title?.trim() ?? task.title;
    final newMinutes = minutes ?? task.minutes;
    final newCategoryId = categoryId != null ? categoryId() : task.categoryId;

    // 유효성 검사: 빈 제목
    if (newTitle.isEmpty) {
      throw ArgumentError('할 일 이름을 입력해주세요.');
    }

    // 유효성 검사: 소요 시간
    if (newMinutes < 1) {
      throw ArgumentError('소요 시간은 1분 이상 입력해주세요.');
    }

    // 카테고리가 변경된 경우 새 그룹의 마지막으로 이동
    int newSortOrder = task.sortOrder;
    if (newCategoryId != task.categoryId) {
      final filter = newCategoryId != null
          ? TaskFilterByCategory(newCategoryId)
          : const TaskFilterUnassigned();
      newSortOrder = await _repository.getNextSortOrder(filter);
    }

    // 수정된 엔티티 생성
    final updated = task.copyWith(
      title: newTitle,
      minutes: newMinutes,
      categoryId: () => newCategoryId,
      sortOrder: newSortOrder,
    );

    // 저장
    await _repository.updateTask(updated);

    return updated;
  }
}

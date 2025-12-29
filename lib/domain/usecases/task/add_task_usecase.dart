import 'package:uuid/uuid.dart';
import '../../entities/task_entity.dart';
import '../../entities/task_filter.dart';
import '../../repositories/task_repository.dart';

/// 할 일 추가 UseCase
class AddTaskUseCase {
  final TaskRepository _repository;
  final Uuid _uuid = const Uuid();

  AddTaskUseCase(this._repository);

  /// 할 일 추가
  /// [title]: 할 일 제목
  /// [minutes]: 소요 시간 (분)
  /// [categoryId]: 카테고리 ID (null이면 미분류)
  ///
  /// Throws [ArgumentError] if title is empty or minutes < 1
  Future<TaskEntity> call({
    required String title,
    required int minutes,
    String? categoryId,
  }) async {
    // 유효성 검사: 빈 제목
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('할 일 이름을 입력해주세요.');
    }

    // 유효성 검사: 소요 시간
    if (minutes < 1) {
      throw ArgumentError('소요 시간은 1분 이상 입력해주세요.');
    }

    // sortOrder 할당 (해당 그룹 내에서)
    final filter = categoryId != null
        ? TaskFilterByCategory(categoryId)
        : const TaskFilterUnassigned();
    final sortOrder = await _repository.getNextSortOrder(filter);

    // 엔티티 생성
    final task = TaskEntity(
      id: _uuid.v4(),
      title: trimmedTitle,
      minutes: minutes,
      categoryId: categoryId,
      sortOrder: sortOrder,
      createdAt: DateTime.now(),
    );

    // 저장
    await _repository.addTask(task);

    return task;
  }
}

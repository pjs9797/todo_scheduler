import '../entities/task_entity.dart';
import '../entities/task_filter.dart';

/// 할 일 저장소 인터페이스 (Domain Layer)
/// Data Layer에서 구현
abstract class TaskRepository {
  /// 모든 할 일 조회 (sortOrder 기준 정렬)
  Future<List<TaskEntity>> getAllTasks();

  /// 필터 기준으로 할 일 조회
  Future<List<TaskEntity>> getTasksByFilter(TaskFilter filter);

  /// 할 일 ID로 조회
  Future<TaskEntity?> getTaskById(String id);

  /// 특정 카테고리의 할 일 개수 조회
  Future<int> getTaskCountByCategory(String categoryId);

  /// 할 일 추가
  Future<void> addTask(TaskEntity task);

  /// 할 일 수정
  Future<void> updateTask(TaskEntity task);

  /// 할 일 삭제
  Future<void> deleteTask(String id);

  /// 할 일 순서 일괄 업데이트 (드래그 정렬용)
  Future<void> reorderTasks(List<TaskEntity> tasks);

  /// 특정 카테고리의 할 일들을 미분류로 이동 (카테고리 삭제 시)
  Future<void> unassignTasksByCategory(String categoryId);

  /// 다음 sortOrder 값 조회 (필터 기준)
  Future<int> getNextSortOrder(TaskFilter filter);
}

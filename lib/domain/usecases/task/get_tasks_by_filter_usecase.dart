import '../../entities/task_entity.dart';
import '../../entities/task_filter.dart';
import '../../repositories/task_repository.dart';

/// 필터 기준 할 일 조회 UseCase
class GetTasksByFilterUseCase {
  final TaskRepository _repository;

  GetTasksByFilterUseCase(this._repository);

  Future<List<TaskEntity>> call(TaskFilter filter) {
    return _repository.getTasksByFilter(filter);
  }
}

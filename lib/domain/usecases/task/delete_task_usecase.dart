import '../../repositories/task_repository.dart';

/// 할 일 삭제 UseCase
class DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCase(this._repository);

  /// 할 일 삭제
  Future<void> call(String taskId) async {
    await _repository.deleteTask(taskId);
  }
}

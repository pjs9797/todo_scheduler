import '../../repositories/task_tag_repository.dart';

/// 태그 삭제 UseCase
class DeleteTaskTagUseCase {
  final TaskTagRepository _repository;

  DeleteTaskTagUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.delete(id);
  }
}

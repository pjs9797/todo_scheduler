import '../../entities/task_tag_entity.dart';
import '../../repositories/task_tag_repository.dart';

/// 모든 태그 조회 UseCase
class GetAllTaskTagsUseCase {
  final TaskTagRepository _repository;

  GetAllTaskTagsUseCase(this._repository);

  Future<List<TaskTagEntity>> call() {
    return _repository.getAll();
  }
}

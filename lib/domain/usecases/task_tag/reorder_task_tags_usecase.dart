import '../../repositories/task_tag_repository.dart';

/// 태그 순서 변경 UseCase
class ReorderTaskTagsUseCase {
  final TaskTagRepository _repository;

  ReorderTaskTagsUseCase(this._repository);

  Future<void> call(List<String> orderedIds) {
    return _repository.reorder(orderedIds);
  }
}

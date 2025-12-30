import '../../entities/task_tag_entity.dart';
import '../../repositories/task_tag_repository.dart';

/// 태그 수정 UseCase
class UpdateTaskTagUseCase {
  final TaskTagRepository _repository;

  UpdateTaskTagUseCase(this._repository);

  /// 태그 수정
  /// Throws [ArgumentError] if name is empty or duplicate
  Future<void> call(TaskTagEntity tag) async {
    final trimmedName = tag.name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('태그 이름을 입력해주세요.');
    }

    final isDuplicate = await _repository.isNameDuplicate(
      trimmedName,
      excludeId: tag.id,
    );
    if (isDuplicate) {
      throw ArgumentError('이미 같은 이름의 태그가 있어요.');
    }

    return _repository.update(tag.copyWith(name: trimmedName));
  }
}

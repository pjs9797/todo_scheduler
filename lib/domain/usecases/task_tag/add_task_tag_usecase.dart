import '../../entities/task_tag_entity.dart';
import '../../repositories/task_tag_repository.dart';

/// 태그 추가 UseCase
class AddTaskTagUseCase {
  final TaskTagRepository _repository;

  AddTaskTagUseCase(this._repository);

  /// 태그 추가
  /// [name]: 태그 이름
  /// [colorHex]: 태그 색상 (Hex)
  ///
  /// Throws [ArgumentError] if name is empty or duplicate
  Future<TaskTagEntity> call({
    required String name,
    required String colorHex,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('태그 이름을 입력해주세요.');
    }

    final isDuplicate = await _repository.isNameDuplicate(trimmedName);
    if (isDuplicate) {
      throw ArgumentError('이미 같은 이름의 태그가 있어요.');
    }

    return _repository.add(
      name: trimmedName,
      colorHex: colorHex,
    );
  }
}

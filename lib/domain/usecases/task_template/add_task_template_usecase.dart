import '../../entities/task_template_entity.dart';
import '../../repositories/task_template_repository.dart';

/// 할일 템플릿 추가 UseCase
class AddTaskTemplateUseCase {
  final TaskTemplateRepository _repository;

  AddTaskTemplateUseCase(this._repository);

  /// 할일 템플릿 추가
  /// [title]: 할일 제목
  /// [minutes]: 소요 시간 (분)
  /// [isFavorite]: 즐겨찾기 여부
  /// [tagIds]: 태그 ID 목록
  ///
  /// Throws [ArgumentError] if title is empty
  Future<TaskTemplateEntity> call({
    required String title,
    required int minutes,
    bool isFavorite = false,
    List<String> tagIds = const [],
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('할일 제목을 입력해주세요.');
    }

    if (minutes <= 0) {
      throw ArgumentError('소요 시간은 1분 이상이어야 합니다.');
    }

    return _repository.add(
      title: trimmedTitle,
      minutes: minutes,
      isFavorite: isFavorite,
      tagIds: tagIds,
    );
  }
}

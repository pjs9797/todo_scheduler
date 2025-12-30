import '../../entities/task_template_entity.dart';
import '../../repositories/task_template_repository.dart';

/// 할일 템플릿 수정 UseCase
class UpdateTaskTemplateUseCase {
  final TaskTemplateRepository _repository;

  UpdateTaskTemplateUseCase(this._repository);

  /// 할일 템플릿 수정
  /// Throws [ArgumentError] if title is empty
  Future<void> call(TaskTemplateEntity template) async {
    if (template.title.trim().isEmpty) {
      throw ArgumentError('할일 제목을 입력해주세요.');
    }

    if (template.minutes <= 0) {
      throw ArgumentError('소요 시간은 1분 이상이어야 합니다.');
    }

    return _repository.update(template);
  }
}

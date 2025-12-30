import '../../entities/task_template_entity.dart';
import '../../repositories/task_template_repository.dart';

/// 모든 할일 템플릿 조회 UseCase
class GetAllTaskTemplatesUseCase {
  final TaskTemplateRepository _repository;

  GetAllTaskTemplatesUseCase(this._repository);

  Future<List<TaskTemplateEntity>> call() {
    return _repository.getAll();
  }
}

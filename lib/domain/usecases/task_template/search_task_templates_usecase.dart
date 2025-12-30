import '../../entities/task_template_entity.dart';
import '../../repositories/task_template_repository.dart';

/// 할일 템플릿 검색 UseCase
class SearchTaskTemplatesUseCase {
  final TaskTemplateRepository _repository;

  SearchTaskTemplatesUseCase(this._repository);

  Future<List<TaskTemplateEntity>> call(String query) {
    return _repository.search(query);
  }
}

import '../../entities/task_template_entity.dart';
import '../../repositories/task_template_repository.dart';

/// 즐겨찾기 할일 템플릿 조회 UseCase
class GetFavoriteTaskTemplatesUseCase {
  final TaskTemplateRepository _repository;

  GetFavoriteTaskTemplatesUseCase(this._repository);

  Future<List<TaskTemplateEntity>> call() {
    return _repository.getFavorites();
  }
}

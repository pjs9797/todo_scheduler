import '../../repositories/task_template_repository.dart';

/// 할일 템플릿 즐겨찾기 토글 UseCase
class ToggleFavoriteUseCase {
  final TaskTemplateRepository _repository;

  ToggleFavoriteUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.toggleFavorite(id);
  }
}

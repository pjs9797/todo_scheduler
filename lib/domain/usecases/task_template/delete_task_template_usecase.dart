import '../../repositories/task_template_repository.dart';
import '../../repositories/category_task_repository.dart';

/// 할일 템플릿 삭제 UseCase
class DeleteTaskTemplateUseCase {
  final TaskTemplateRepository _templateRepository;
  final CategoryTaskRepository _categoryTaskRepository;

  DeleteTaskTemplateUseCase(this._templateRepository, this._categoryTaskRepository);

  /// 할일 템플릿 삭제 (연결된 카테고리-할일 관계도 함께 삭제)
  Future<void> call(String id) async {
    await _categoryTaskRepository.deleteByTaskTemplateId(id);
    await _templateRepository.delete(id);
  }
}

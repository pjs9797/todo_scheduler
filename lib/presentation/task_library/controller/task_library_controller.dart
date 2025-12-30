import 'package:get/get.dart';
import '../../../domain/domain.dart';

/// 할 일 라이브러리 컨트롤러
class TaskLibraryController extends GetxController {
  final TaskTemplateRepository _templateRepository;
  final CategoryTaskRepository _categoryTaskRepository;

  TaskLibraryController(this._templateRepository, this._categoryTaskRepository);

  // 상태
  final isLoading = true.obs;
  final templates = <TaskTemplateEntity>[].obs;
  final categoryTaskCounts = <String, int>{}.obs; // templateId -> 사용 카테고리 수

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  /// 템플릿 목록 로드
  Future<void> loadTemplates() async {
    isLoading.value = true;
    try {
      templates.value = await _templateRepository.getAll();
      await _loadCategoryTaskCounts();
    } finally {
      isLoading.value = false;
    }
  }

  /// 카테고리 사용 수 로드
  Future<void> _loadCategoryTaskCounts() async {
    final counts = <String, int>{};
    for (final template in templates) {
      final categoryTasks = await _categoryTaskRepository.getByTaskTemplateId(template.id);
      counts[template.id] = categoryTasks.length;
    }
    categoryTaskCounts.value = counts;
  }

  /// 템플릿 추가
  Future<TaskTemplateEntity> addTemplate({
    required String title,
    required int minutes,
    bool isFavorite = false,
  }) async {
    final template = await _templateRepository.add(
      title: title,
      minutes: minutes,
      isFavorite: isFavorite,
    );
    await loadTemplates();
    return template;
  }

  /// 템플릿 수정
  Future<void> updateTemplate(TaskTemplateEntity template) async {
    await _templateRepository.update(template);
    await loadTemplates();
  }

  /// 템플릿 삭제
  Future<void> deleteTemplate(String id) async {
    await _categoryTaskRepository.deleteByTaskTemplateId(id);
    await _templateRepository.delete(id);
    await loadTemplates();
  }

  /// 즐겨찾기 토글
  Future<void> toggleFavorite(String id) async {
    await _templateRepository.toggleFavorite(id);
    await loadTemplates();
  }

  /// 즐겨찾기 템플릿 목록
  List<TaskTemplateEntity> get favoriteTemplates =>
      templates.where((t) => t.isFavorite).toList();

  /// 템플릿이 사용되는 카테고리 수
  int getCategoryCount(String templateId) => categoryTaskCounts[templateId] ?? 0;
}

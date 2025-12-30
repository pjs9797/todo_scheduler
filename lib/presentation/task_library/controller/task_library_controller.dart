import 'package:get/get.dart';
import '../../../domain/domain.dart';

/// 할 일 라이브러리 컨트롤러
class TaskLibraryController extends GetxController {
  final TaskTemplateRepository _templateRepository;
  final CategoryTaskRepository _categoryTaskRepository;
  final TaskTagRepository _tagRepository;

  TaskLibraryController(
    this._templateRepository,
    this._categoryTaskRepository,
    this._tagRepository,
  );

  // 상태
  final isLoading = true.obs;
  final templates = <TaskTemplateEntity>[].obs;
  final tags = <TaskTagEntity>[].obs;
  final selectedTagId = Rxn<String>(); // null = 전체, 'favorites' = 즐겨찾기
  final categoryTaskCounts = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// 전체 데이터 로드
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _loadTemplates(),
        _loadTags(),
      ]);
      await _loadCategoryTaskCounts();
    } finally {
      isLoading.value = false;
    }
  }

  /// 템플릿 목록 로드
  Future<void> _loadTemplates() async {
    templates.value = await _templateRepository.getAll();
  }

  /// 태그 목록 로드
  Future<void> _loadTags() async {
    tags.value = await _tagRepository.getAll();
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

  /// 필터된 템플릿 목록
  List<TaskTemplateEntity> get filteredTemplates {
    final filter = selectedTagId.value;
    if (filter == null) {
      return templates.toList();
    } else if (filter == 'favorites') {
      return templates.where((t) => t.isFavorite).toList();
    } else {
      return templates.where((t) => t.tagIds.contains(filter)).toList();
    }
  }

  /// 필터 변경
  void setFilter(String? tagId) {
    selectedTagId.value = tagId;
  }

  // ==================== Template Actions ====================

  /// 템플릿 추가
  Future<TaskTemplateEntity> addTemplate({
    required String title,
    required int minutes,
    bool isFavorite = false,
    List<String> tagIds = const [],
  }) async {
    final template = await _templateRepository.add(
      title: title,
      minutes: minutes,
      isFavorite: isFavorite,
      tagIds: tagIds,
    );
    await loadData();
    return template;
  }

  /// 템플릿 수정
  Future<void> updateTemplate(TaskTemplateEntity template) async {
    await _templateRepository.update(template);
    await loadData();
  }

  /// 템플릿 삭제
  Future<void> deleteTemplate(String id) async {
    await _categoryTaskRepository.deleteByTaskTemplateId(id);
    await _templateRepository.delete(id);
    await loadData();
  }

  /// 즐겨찾기 토글
  Future<void> toggleFavorite(String id) async {
    await _templateRepository.toggleFavorite(id);
    await _loadTemplates();
  }

  /// 템플릿이 사용되는 카테고리 수
  int getCategoryCount(String templateId) => categoryTaskCounts[templateId] ?? 0;

  // ==================== Tag Actions ====================

  /// 태그 추가
  Future<void> addTag(String name, String colorHex) async {
    await _tagRepository.add(name: name, colorHex: colorHex);
    await _loadTags();
  }

  /// 태그 수정
  Future<void> updateTag(TaskTagEntity tag) async {
    await _tagRepository.update(tag);
    await _loadTags();
  }

  /// 태그 삭제
  Future<void> deleteTag(String id) async {
    // 해당 태그를 사용하는 템플릿에서 태그 제거
    for (final template in templates) {
      if (template.tagIds.contains(id)) {
        final updatedTagIds = template.tagIds.where((t) => t != id).toList();
        await _templateRepository.update(template.copyWith(tagIds: updatedTagIds));
      }
    }
    await _tagRepository.delete(id);
    if (selectedTagId.value == id) {
      selectedTagId.value = null;
    }
    await loadData();
  }

  /// 태그 이름으로 조회
  TaskTagEntity? getTagById(String id) {
    try {
      return tags.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}

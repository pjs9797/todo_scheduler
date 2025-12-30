import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/domain.dart';

/// 홈 화면 컨트롤러
class HomeController extends GetxController {
  // UseCases & Repositories
  final GetAllCategoriesUseCase _getAllCategoriesUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final CalculateStartTimeUseCase _calculateStartTimeUseCase;
  final TaskTemplateRepository _templateRepository;
  final CategoryTaskRepository _categoryTaskRepository;

  HomeController({
    required GetAllCategoriesUseCase getAllCategoriesUseCase,
    required UpdateCategoryUseCase updateCategoryUseCase,
    required CalculateStartTimeUseCase calculateStartTimeUseCase,
    required TaskTemplateRepository templateRepository,
    required CategoryTaskRepository categoryTaskRepository,
  })  : _getAllCategoriesUseCase = getAllCategoriesUseCase,
        _updateCategoryUseCase = updateCategoryUseCase,
        _calculateStartTimeUseCase = calculateStartTimeUseCase,
        _templateRepository = templateRepository,
        _categoryTaskRepository = categoryTaskRepository;

  // ==================== State ====================

  /// 카테고리 목록
  final categories = <CategoryEntity>[].obs;

  /// 템플릿 목록 (캐시)
  final _templateCache = <String, TaskTemplateEntity>{};

  /// 현재 필터
  final Rx<TaskFilter> currentFilter = Rx<TaskFilter>(const TaskFilterAll());

  /// 필터된 할 일 목록 (그룹별)
  final taskGroups = <TaskGroup>[].obs;

  /// 로딩 상태
  final isLoading = false.obs;

  // ==================== Getters ====================

  /// 총 소요 시간 (분)
  int get totalMinutes {
    return taskGroups.fold<int>(
      0,
      (sum, group) => sum + group.totalMinutes,
    );
  }

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // ==================== Data Loading ====================

  /// 데이터 로드
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await _loadCategories();
      await _loadTemplateCache();
      await _loadTasks();
    } finally {
      isLoading.value = false;
    }
  }

  /// 카테고리 로드
  Future<void> _loadCategories() async {
    categories.value = await _getAllCategoriesUseCase();
  }

  /// 템플릿 캐시 로드
  Future<void> _loadTemplateCache() async {
    final templates = await _templateRepository.getAll();
    _templateCache.clear();
    for (final t in templates) {
      _templateCache[t.id] = t;
    }
  }

  /// 카테고리의 DisplayTask 목록 생성
  Future<List<DisplayTask>> _getDisplayTasksForCategory(String categoryId) async {
    final categoryTasks = await _categoryTaskRepository.getByCategoryId(categoryId);
    final displayTasks = <DisplayTask>[];

    for (final ct in categoryTasks) {
      final template = _templateCache[ct.taskTemplateId];
      if (template != null) {
        displayTasks.add(DisplayTask.fromEntities(
          categoryTask: ct,
          template: template,
        ));
      }
    }

    displayTasks.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return displayTasks;
  }

  /// 할 일 로드 (현재 필터 기준)
  Future<void> _loadTasks() async {
    final filter = currentFilter.value;
    final allCategories = await _getAllCategoriesUseCase();
    final groups = <TaskGroup>[];

    switch (filter) {
      case TaskFilterAll():
        // 카테고리별 그룹
        for (final category in allCategories) {
          final displayTasks = await _getDisplayTasksForCategory(category.id);
          final totalMins = displayTasks.fold<int>(0, (s, t) => s + t.minutes);
          final startTime = _calculateStartTimeUseCase(
            endHour: category.endTimeHour,
            endMinute: category.endTimeMinute,
            totalMinutes: totalMins,
          );
          groups.add(TaskGroup(
            key: 'cat:${category.id}',
            title: category.name,
            colorHex: category.colorHex,
            categoryId: category.id,
            endTimeHour: category.endTimeHour,
            endTimeMinute: category.endTimeMinute,
            startTimeResult: startTime,
            tasks: displayTasks,
          ));
        }
        break;

      case TaskFilterUnassigned():
        // 새로운 아키텍처에서는 미분류 개념이 없음 (모든 할일은 카테고리에 속함)
        break;

      case TaskFilterByCategory(:final categoryId):
        final category = allCategories.firstWhereOrNull((c) => c.id == categoryId);
        if (category != null) {
          final displayTasks = await _getDisplayTasksForCategory(categoryId);
          final totalMins = displayTasks.fold<int>(0, (s, t) => s + t.minutes);
          final startTime = _calculateStartTimeUseCase(
            endHour: category.endTimeHour,
            endMinute: category.endTimeMinute,
            totalMinutes: totalMins,
          );
          groups.add(TaskGroup(
            key: 'cat:$categoryId',
            title: category.name,
            colorHex: category.colorHex,
            categoryId: categoryId,
            endTimeHour: category.endTimeHour,
            endTimeMinute: category.endTimeMinute,
            startTimeResult: startTime,
            tasks: displayTasks,
          ));
        }
        break;
    }

    taskGroups.value = groups;
  }

  // ==================== Filter ====================

  /// 필터 변경
  void setFilter(TaskFilter filter) {
    currentFilter.value = filter;
    _loadTasks();
  }

  // ==================== Time ====================

  /// 카테고리 완료 시간 설정
  Future<void> setCategoryEndTime(String? categoryId, TimeOfDay time) async {
    if (categoryId == null) return;

    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    if (category != null) {
      await _updateCategoryUseCase(
        category: category,
        endTimeHour: time.hour,
        endTimeMinute: time.minute,
      );
      await _loadCategories();
      await _loadTasks();
    }
  }

  // ==================== Task Actions ====================

  /// 카테고리에 할일 추가 (라이브러리에서 선택)
  Future<void> addTasksToCategory(String categoryId, List<String> templateIds) async {
    for (final templateId in templateIds) {
      final exists = await _categoryTaskRepository.exists(
        categoryId: categoryId,
        taskTemplateId: templateId,
      );
      if (!exists) {
        final categoryTasks = await _categoryTaskRepository.getByCategoryId(categoryId);
        final nextSortOrder = categoryTasks.isEmpty
            ? 0
            : categoryTasks.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
        await _categoryTaskRepository.add(
          categoryId: categoryId,
          taskTemplateId: templateId,
          sortOrder: nextSortOrder,
        );
        await _templateRepository.updateLastUsedAt(templateId);
      }
    }
    await _loadTemplateCache();
    await _loadTasks();
  }

  /// 새 할일 템플릿 생성 후 카테고리에 추가
  Future<void> createAndAddTask({
    required String title,
    required int minutes,
    required String categoryId,
    bool isFavorite = false,
  }) async {
    final template = await _templateRepository.add(
      title: title,
      minutes: minutes,
      isFavorite: isFavorite,
    );
    await addTasksToCategory(categoryId, [template.id]);
  }

  /// 카테고리에서 할일 제거
  Future<void> removeTaskFromCategory(String categoryTaskId) async {
    await _categoryTaskRepository.delete(categoryTaskId);
    await _loadTasks();
  }

  /// 할 일 순서 변경
  Future<void> reorderTasks(String? categoryId, int oldIndex, int newIndex) async {
    if (categoryId == null) return;

    // 해당 그룹 찾기
    final groupIndex = taskGroups.indexWhere((g) => g.categoryId == categoryId);
    if (groupIndex == -1) return;

    final group = taskGroups[groupIndex];
    final tasks = List<DisplayTask>.from(group.tasks);

    // 순서 조정
    if (newIndex > oldIndex) newIndex--;
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);

    // 시작 시간 재계산
    final totalMins = tasks.fold<int>(0, (s, t) => s + t.minutes);
    final startTime = _calculateStartTimeUseCase(
      endHour: group.endTimeHour,
      endMinute: group.endTimeMinute,
      totalMinutes: totalMins,
    );

    // UI 즉시 업데이트
    taskGroups[groupIndex] = TaskGroup(
      key: group.key,
      title: group.title,
      colorHex: group.colorHex,
      categoryId: group.categoryId,
      endTimeHour: group.endTimeHour,
      endTimeMinute: group.endTimeMinute,
      startTimeResult: startTime,
      tasks: tasks,
    );

    // DB 저장
    final orderedIds = tasks.map((t) => t.categoryTaskId).toList();
    await _categoryTaskRepository.reorder(categoryId, orderedIds);
  }

  /// 모든 템플릿 조회 (할일 선택용)
  Future<List<TaskTemplateEntity>> getAllTemplates() async {
    return _templateRepository.getAll();
  }

  /// 즐겨찾기 템플릿 조회
  Future<List<TaskTemplateEntity>> getFavoriteTemplates() async {
    return _templateRepository.getFavorites();
  }

  /// 카테고리에 이미 추가된 템플릿 ID 목록
  Future<Set<String>> getAddedTemplateIds(String categoryId) async {
    final categoryTasks = await _categoryTaskRepository.getByCategoryId(categoryId);
    return categoryTasks.map((ct) => ct.taskTemplateId).toSet();
  }

  /// 데이터 새로고침
  @override
  Future<void> refresh() async {
    await loadData();
  }
}

/// 할 일 그룹 (카테고리)
class TaskGroup {
  final String key;
  final String title;
  final String colorHex;
  final String? categoryId;
  final int endTimeHour;
  final int endTimeMinute;
  final StartTimeResult startTimeResult;
  final List<DisplayTask> tasks;

  const TaskGroup({
    required this.key,
    required this.title,
    required this.colorHex,
    required this.categoryId,
    required this.endTimeHour,
    required this.endTimeMinute,
    required this.startTimeResult,
    required this.tasks,
  });

  /// 총 소요 시간 (분)
  int get totalMinutes => tasks.fold<int>(0, (s, t) => s + t.minutes);

  /// 완료 시간 문자열
  String get endTimeString {
    final h = endTimeHour.toString().padLeft(2, '0');
    final m = endTimeMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

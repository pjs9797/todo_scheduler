import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/domain.dart';

/// 홈 화면 컨트롤러
class HomeController extends GetxController {
  // UseCases
  final GetAllCategoriesUseCase _getAllCategoriesUseCase;
  final GetTasksByFilterUseCase _getTasksByFilterUseCase;
  final AddTaskUseCase _addTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final ReorderTasksUseCase _reorderTasksUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final CalculateStartTimeUseCase _calculateStartTimeUseCase;

  HomeController({
    required GetAllCategoriesUseCase getAllCategoriesUseCase,
    required GetTasksByFilterUseCase getTasksByFilterUseCase,
    required AddTaskUseCase addTaskUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required ReorderTasksUseCase reorderTasksUseCase,
    required UpdateCategoryUseCase updateCategoryUseCase,
    required CalculateStartTimeUseCase calculateStartTimeUseCase,
  })  : _getAllCategoriesUseCase = getAllCategoriesUseCase,
        _getTasksByFilterUseCase = getTasksByFilterUseCase,
        _addTaskUseCase = addTaskUseCase,
        _updateTaskUseCase = updateTaskUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        _reorderTasksUseCase = reorderTasksUseCase,
        _updateCategoryUseCase = updateCategoryUseCase,
        _calculateStartTimeUseCase = calculateStartTimeUseCase;

  // ==================== State ====================

  /// 카테고리 목록
  final categories = <CategoryEntity>[].obs;

  /// 현재 필터
  final Rx<TaskFilter> currentFilter = Rx<TaskFilter>(const TaskFilterAll());

  /// 필터된 할 일 목록 (그룹별)
  final taskGroups = <TaskGroup>[].obs;

  /// 미분류 완료 시간 (시, 분)
  final unassignedEndTimeHour = 9.obs;
  final unassignedEndTimeMinute = 0.obs;

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
      await Future.wait([
        _loadCategories(),
        _loadTasks(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  /// 카테고리 로드
  Future<void> _loadCategories() async {
    categories.value = await _getAllCategoriesUseCase();
  }

  /// 할 일 로드 (현재 필터 기준)
  Future<void> _loadTasks() async {
    final filter = currentFilter.value;
    final allCategories = await _getAllCategoriesUseCase();
    final groups = <TaskGroup>[];

    switch (filter) {
      case TaskFilterAll():
        // 카테고리별 그룹 + 미분류
        for (final category in allCategories) {
          final tasks = await _getTasksByFilterUseCase(
            TaskFilterByCategory(category.id),
          );
          final totalMins = tasks.fold<int>(0, (s, t) => s + t.minutes);
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
            tasks: tasks,
          ));
        }
        // 미분류
        final unassigned = await _getTasksByFilterUseCase(
          const TaskFilterUnassigned(),
        );
        final unassignedMins = unassigned.fold<int>(0, (s, t) => s + t.minutes);
        final unassignedStart = _calculateStartTimeUseCase(
          endHour: unassignedEndTimeHour.value,
          endMinute: unassignedEndTimeMinute.value,
          totalMinutes: unassignedMins,
        );
        groups.add(TaskGroup(
          key: 'unassigned',
          title: '미분류',
          colorHex: '#64748B',
          categoryId: null,
          endTimeHour: unassignedEndTimeHour.value,
          endTimeMinute: unassignedEndTimeMinute.value,
          startTimeResult: unassignedStart,
          tasks: unassigned,
        ));
        break;

      case TaskFilterUnassigned():
        final tasks = await _getTasksByFilterUseCase(filter);
        final totalMins = tasks.fold<int>(0, (s, t) => s + t.minutes);
        final startTime = _calculateStartTimeUseCase(
          endHour: unassignedEndTimeHour.value,
          endMinute: unassignedEndTimeMinute.value,
          totalMinutes: totalMins,
        );
        groups.add(TaskGroup(
          key: 'unassigned',
          title: '미분류',
          colorHex: '#64748B',
          categoryId: null,
          endTimeHour: unassignedEndTimeHour.value,
          endTimeMinute: unassignedEndTimeMinute.value,
          startTimeResult: startTime,
          tasks: tasks,
        ));
        break;

      case TaskFilterByCategory(:final categoryId):
        final category = allCategories.firstWhereOrNull((c) => c.id == categoryId);
        final tasks = await _getTasksByFilterUseCase(filter);
        final totalMins = tasks.fold<int>(0, (s, t) => s + t.minutes);
        final endHour = category?.endTimeHour ?? 22;
        final endMinute = category?.endTimeMinute ?? 0;
        final startTime = _calculateStartTimeUseCase(
          endHour: endHour,
          endMinute: endMinute,
          totalMinutes: totalMins,
        );
        groups.add(TaskGroup(
          key: 'cat:$categoryId',
          title: category?.name ?? '카테고리',
          colorHex: category?.colorHex ?? '#64748B',
          categoryId: categoryId,
          endTimeHour: endHour,
          endTimeMinute: endMinute,
          startTimeResult: startTime,
          tasks: tasks,
        ));
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
    if (categoryId == null) {
      // 미분류
      unassignedEndTimeHour.value = time.hour;
      unassignedEndTimeMinute.value = time.minute;
      await _loadTasks();
    } else {
      // 카테고리
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
  }

  // ==================== Task Actions ====================

  /// 할 일 추가
  Future<void> addTask(String title, int minutes, String? categoryId) async {
    await _addTaskUseCase(
      title: title,
      minutes: minutes,
      categoryId: categoryId,
    );
    await _loadTasks();
  }

  /// 할 일 수정
  Future<void> updateTask({
    required TaskEntity task,
    required String title,
    required int minutes,
    required String? categoryId,
  }) async {
    await _updateTaskUseCase(
      task: task,
      title: title,
      minutes: minutes,
      categoryId: () => categoryId,
    );
    await _loadTasks();
  }

  /// 할 일 삭제
  Future<void> deleteTask(String taskId) async {
    await _deleteTaskUseCase(taskId);
    await _loadTasks();
  }

  /// 할 일 순서 변경
  Future<void> reorderTasks(String? categoryId, int oldIndex, int newIndex) async {
    // 해당 그룹 찾기
    final groupIndex = taskGroups.indexWhere((g) => g.categoryId == categoryId);
    if (groupIndex == -1) return;

    final group = taskGroups[groupIndex];
    final tasks = List<TaskEntity>.from(group.tasks);

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
    await _reorderTasksUseCase(tasks);
  }

  /// 데이터 새로고침
  @override
  Future<void> refresh() async {
    await loadData();
  }
}

/// 할 일 그룹 (카테고리 또는 미분류)
class TaskGroup {
  final String key;
  final String title;
  final String colorHex;
  final String? categoryId;
  final int endTimeHour;
  final int endTimeMinute;
  final StartTimeResult startTimeResult;
  final List<TaskEntity> tasks;

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

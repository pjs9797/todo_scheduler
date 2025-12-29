import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/domain.dart';

/// 홈 화면 컨트롤러
class HomeController extends GetxController {
  // UseCases
  final GetAllCategoriesUseCase _getAllCategoriesUseCase;
  final GetTasksByFilterUseCase _getTasksByFilterUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final CalculateStartTimeUseCase _calculateStartTimeUseCase;

  HomeController({
    required GetAllCategoriesUseCase getAllCategoriesUseCase,
    required GetTasksByFilterUseCase getTasksByFilterUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required CalculateStartTimeUseCase calculateStartTimeUseCase,
  })  : _getAllCategoriesUseCase = getAllCategoriesUseCase,
        _getTasksByFilterUseCase = getTasksByFilterUseCase,
        _deleteTaskUseCase = deleteTaskUseCase,
        _calculateStartTimeUseCase = calculateStartTimeUseCase;

  // ==================== State ====================

  /// 카테고리 목록
  final categories = <CategoryEntity>[].obs;

  /// 현재 필터
  final Rx<TaskFilter> currentFilter = Rx<TaskFilter>(const TaskFilterAll());

  /// 필터된 할 일 목록 (그룹별)
  final taskGroups = <TaskGroup>[].obs;

  /// 완료 시간 (시, 분)
  final endTimeHour = 22.obs;
  final endTimeMinute = 30.obs;

  /// 시작 시간 결과
  final Rx<StartTimeResult?> startTimeResult = Rx<StartTimeResult?>(null);

  /// 로딩 상태
  final isLoading = false.obs;

  // ==================== Getters ====================

  /// 총 소요 시간 (분)
  int get totalMinutes {
    return taskGroups.fold<int>(
      0,
      (sum, group) => sum + group.tasks.fold<int>(0, (s, t) => s + t.minutes),
    );
  }

  /// 완료 시간 문자열
  String get endTimeString {
    final h = endTimeHour.value.toString().padLeft(2, '0');
    final m = endTimeMinute.value.toString().padLeft(2, '0');
    return '$h:$m';
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
      _calculateStartTime();
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
          groups.add(TaskGroup(
            key: 'cat:${category.id}',
            title: category.name,
            colorHex: category.colorHex,
            categoryId: category.id,
            tasks: tasks,
          ));
        }
        // 미분류
        final unassigned = await _getTasksByFilterUseCase(
          const TaskFilterUnassigned(),
        );
        groups.add(TaskGroup(
          key: 'unassigned',
          title: '미분류',
          colorHex: '#64748B',
          categoryId: null,
          tasks: unassigned,
        ));
        break;

      case TaskFilterUnassigned():
        final tasks = await _getTasksByFilterUseCase(filter);
        groups.add(TaskGroup(
          key: 'unassigned',
          title: '미분류',
          colorHex: '#64748B',
          categoryId: null,
          tasks: tasks,
        ));
        break;

      case TaskFilterByCategory(:final categoryId):
        final category = allCategories.firstWhereOrNull((c) => c.id == categoryId);
        final tasks = await _getTasksByFilterUseCase(filter);
        groups.add(TaskGroup(
          key: 'cat:$categoryId',
          title: category?.name ?? '카테고리',
          colorHex: category?.colorHex ?? '#64748B',
          categoryId: categoryId,
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
    _loadTasks().then((_) => _calculateStartTime());
  }

  // ==================== Time ====================

  /// 완료 시간 설정
  void setEndTime(TimeOfDay time) {
    endTimeHour.value = time.hour;
    endTimeMinute.value = time.minute;
    _calculateStartTime();
  }

  /// 시작 시간 계산
  void _calculateStartTime() {
    startTimeResult.value = _calculateStartTimeUseCase(
      endHour: endTimeHour.value,
      endMinute: endTimeMinute.value,
      totalMinutes: totalMinutes,
    );
  }

  // ==================== Task Actions ====================

  /// 할 일 삭제
  Future<void> deleteTask(String taskId) async {
    await _deleteTaskUseCase(taskId);
    await _loadTasks();
    _calculateStartTime();
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
  final List<TaskEntity> tasks;

  const TaskGroup({
    required this.key,
    required this.title,
    required this.colorHex,
    required this.categoryId,
    required this.tasks,
  });
}

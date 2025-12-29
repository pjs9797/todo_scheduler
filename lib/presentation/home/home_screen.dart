import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';
import 'controller/home_controller.dart';
import 'widgets/filter_chips.dart';
import 'widgets/time_card.dart';
import 'widgets/task_group_card.dart';

/// 홈 화면
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: CustomScrollView(
              slivers: [
                // 헤더
                SliverToBoxAdapter(child: _buildHeader()),
                // 총 소요 시간
                SliverToBoxAdapter(child: _buildTotalDuration()),
                // 필터 칩
                SliverToBoxAdapter(child: _buildFilterChips()),
                // 시간 카드
                SliverToBoxAdapter(child: _buildTimeCards()),
                // 할 일 목록
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: _buildTaskList(),
                ),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 헤더
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                AppStrings.appSubtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.slate500,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: _onOpenCategoryManagement,
            icon: const Icon(Icons.settings_outlined),
            tooltip: AppStrings.categoryManage,
          ),
        ],
      ),
    );
  }

  /// 총 소요 시간 배지
  Widget _buildTotalDuration() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Obx(() => Text(
                      '${AppStrings.totalDuration}: ${controller.totalMinutes}분',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 필터 칩
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Obx(() => FilterChips(
            categories: controller.categories,
            currentFilter: controller.currentFilter.value,
            onFilterChanged: controller.setFilter,
          )),
    );
  }

  /// 시간 카드들
  Widget _buildTimeCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          // 완료 시간 카드
          Obx(() => EndTimeCard(
                hour: controller.endTimeHour.value,
                minute: controller.endTimeMinute.value,
                onTimePicked: controller.setEndTime,
              )),
          const SizedBox(height: 12),
          // 시작 시간 결과 카드
          Obx(() => StartTimeCard(
                result: controller.startTimeResult.value,
                totalMinutes: controller.totalMinutes,
              )),
        ],
      ),
    );
  }

  /// 할 일 목록
  Widget _buildTaskList() {
    return Obx(() {
      final groups = controller.taskGroups;
      final hasAnyTasks = groups.any((g) => g.tasks.isNotEmpty);

      if (!hasAnyTasks) {
        return SliverToBoxAdapter(
          child: _buildEmptyState(),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final group = groups[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskGroupCard(
                group: group,
                onAddTask: () => _onAddTaskToCategory(group.categoryId),
                onEditTask: _onEditTask,
                onDeleteTask: _onDeleteTask,
              ),
            );
          },
          childCount: groups.length,
        ),
      );
    });
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          const Text(
            '아직 할 일이 없어요',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.slate700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '아래 \'할 일 추가\'로 시작해보세요.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _onAddTask,
              child: const Text(AppStrings.taskAdd),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Actions ====================

  void _onAddTask() {
    final filter = controller.currentFilter.value;
    String? categoryId;
    if (filter is TaskFilterByCategory) {
      categoryId = filter.categoryId;
    }
    // 8단계에서 구현
    Get.snackbar('할 일 추가', '8단계에서 구현 예정 (categoryId: $categoryId)');
  }

  void _onAddTaskToCategory(String? categoryId) {
    // 8단계에서 구현
    Get.snackbar('할 일 추가', '8단계에서 구현 예정 (categoryId: $categoryId)');
  }

  void _onEditTask(TaskEntity task) {
    // 8단계에서 구현
    Get.snackbar('할 일 수정', '8단계에서 구현 예정 (${task.title})');
  }

  void _onDeleteTask(TaskEntity task) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('삭제'),
        content: Text('"${task.title}"${AppStrings.taskDeleteConfirm}'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deleteTask(task.id);
      Get.snackbar(
        '삭제 완료',
        AppStrings.taskDeleted,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _onOpenCategoryManagement() {
    // 9단계에서 구현
    Get.snackbar('카테고리 관리', '9단계에서 구현 예정');
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';
import '../category/category_management_screen.dart';
import '../task/task_selector_bottom_sheet.dart';
import '../task/task_template_form_bottom_sheet.dart';
import '../task_library/task_library_screen.dart';
import 'controller/home_controller.dart';
import 'widgets/filter_chips.dart';
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
                // 필터 칩
                SliverToBoxAdapter(child: _buildFilterChips()),
                // 할 일 목록
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: _buildTaskList(),
                ),
              ],
            ),
          );
        }),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _onOpenTaskLibrary,
                icon: const Icon(Icons.library_books_outlined),
                tooltip: AppStrings.taskLibrary,
              ),
              IconButton(
                onPressed: _onOpenCategoryManagement,
                icon: const Icon(Icons.folder_outlined),
                tooltip: AppStrings.categoryManage,
              ),
            ],
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

  /// 할 일 목록
  Widget _buildTaskList() {
    return Obx(() {
      final categories = controller.categories;
      final groups = controller.taskGroups;

      // 카테고리가 없으면 카테고리 추가 안내
      if (categories.isEmpty) {
        return SliverToBoxAdapter(
          child: _buildNoCategoryState(),
        );
      }

      // 카테고리는 있지만 그룹이 없으면 (필터 문제 등)
      if (groups.isEmpty) {
        return SliverToBoxAdapter(
          child: _buildEmptyState(),
        );
      }

      // 카테고리 카드 표시 (할일이 없어도 카드는 표시)
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final group = groups[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskGroupCard(
                group: group,
                onAddTask: () => _onAddTaskToCategory(group.categoryId),
                onDeleteTask: (task) => _onRemoveTask(task),
                onReorder: (oldIndex, newIndex) {
                  controller.reorderTasks(group.categoryId, oldIndex, newIndex);
                },
                onEndTimeChanged: (time) {
                  controller.setCategoryEndTime(group.categoryId, time);
                },
              ),
            );
          },
          childCount: groups.length,
        ),
      );
    });
  }

  /// 카테고리 없음 상태 위젯
  Widget _buildNoCategoryState() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_off_outlined, size: 48, color: AppColors.slate300),
          const SizedBox(height: 16),
          const Text(
            '카테고리가 없어요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.slate700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '할 일을 정리할 카테고리를 먼저 만들어주세요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _onOpenCategoryManagement,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('카테고리 추가'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.slate800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 빈 상태 위젯 (카테고리는 있지만 할일이 없는 경우)
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
          Icon(Icons.inbox_outlined, size: 40, color: AppColors.slate300),
          const SizedBox(height: 12),
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
            '카테고리 내 + 버튼으로 할 일을 추가해보세요',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Actions ====================

  Future<void> _onAddTaskToCategory(String? categoryId) async {
    if (categoryId == null) return;

    final allTemplates = await controller.getAllTemplates();
    final favorites = await controller.getFavoriteTemplates();
    final tags = await controller.getAllTags();
    final alreadyAdded = await controller.getAddedTemplateIds(categoryId);

    TaskSelectorBottomSheet.show(
      allTemplates: allTemplates,
      favorites: favorites,
      availableTags: tags,
      alreadyAddedIds: alreadyAdded,
      onSelect: (templateIds) async {
        await controller.addTasksToCategory(categoryId, templateIds);
      },
      onCreateNew: () {
        _onCreateNewTask(categoryId);
      },
    );
  }

  void _onCreateNewTask(String categoryId) {
    TaskTemplateFormBottomSheet.show(
      onSave: (title, minutes, isFavorite, tagIds) async {
        await controller.createAndAddTask(
          title: title,
          minutes: minutes,
          categoryId: categoryId,
          isFavorite: isFavorite,
          tagIds: tagIds,
        );
        // Return a dummy template for the result
        return TaskTemplateEntity(
          id: '',
          title: title,
          minutes: minutes,
          isFavorite: isFavorite,
          tagIds: tagIds,
          createdAt: DateTime.now(),
        );
      },
    );
  }

  void _onRemoveTask(DisplayTask task) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('제거'),
        content: Text('"${task.title}"을(를) 이 카테고리에서 제거할까요?\n(할일 라이브러리에는 남아있어요)'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              '제거',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.removeTaskFromCategory(task.categoryTaskId);
      Get.snackbar(
        '제거 완료',
        '카테고리에서 할일을 제거했어요.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _onOpenCategoryManagement() async {
    await Get.to(() => const CategoryManagementScreen());
    // 카테고리 변경 시 홈 화면 새로고침
    controller.loadData();
  }

  void _onOpenTaskLibrary() async {
    await Get.to(() => const TaskLibraryScreen());
    // 할 일 변경 시 홈 화면 새로고침
    controller.loadData();
  }
}

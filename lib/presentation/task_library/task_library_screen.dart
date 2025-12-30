import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';
import '../task/task_template_form_bottom_sheet.dart';
import 'controller/task_library_controller.dart';

/// 할 일 라이브러리 화면
class TaskLibraryScreen extends GetView<TaskLibraryController> {
  const TaskLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(AppStrings.taskLibrary),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.slate800,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.templates.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.templates.length,
          itemBuilder: (context, index) {
            final template = controller.templates[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TaskTemplateListItem(
                template: template,
                categoryCount: controller.getCategoryCount(template.id),
                onEdit: () => _onEditTemplate(template),
                onDelete: () => _onDeleteTemplate(template),
                onToggleFavorite: () => controller.toggleFavorite(template.id),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddTemplate,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 64,
              color: AppColors.slate300,
            ),
            const SizedBox(height: 16),
            const Text(
              '할 일이 없어요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.slate700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.taskLibraryEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _onAddTemplate,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.taskNewCreate),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Actions ====================

  void _onAddTemplate() {
    TaskTemplateFormBottomSheet.show(
      onSave: (title, minutes, isFavorite) async {
        return controller.addTemplate(
          title: title,
          minutes: minutes,
          isFavorite: isFavorite,
        );
      },
    );
  }

  void _onEditTemplate(TaskTemplateEntity template) {
    TaskTemplateFormBottomSheet.show(
      template: template,
      onSave: (title, minutes, isFavorite) async {
        final updated = template.copyWith(
          title: title,
          minutes: minutes,
          isFavorite: isFavorite,
        );
        await controller.updateTemplate(updated);
        return updated;
      },
    );
  }

  void _onDeleteTemplate(TaskTemplateEntity template) async {
    final categoryCount = controller.getCategoryCount(template.id);
    final message = categoryCount > 0
        ? '\'${template.title}\'을(를) 삭제할까요?\n($categoryCount${AppStrings.taskUsedIn})'
        : '\'${template.title}\'${AppStrings.taskDeleteConfirm}';

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('삭제'),
        content: Text(message),
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
      await controller.deleteTemplate(template.id);
      Get.snackbar(
        '삭제 완료',
        AppStrings.taskDeleted,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}

/// 할 일 템플릿 리스트 아이템
class _TaskTemplateListItem extends StatelessWidget {
  final TaskTemplateEntity template;
  final int categoryCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const _TaskTemplateListItem({
    required this.template,
    required this.categoryCount,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.slate200),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: GestureDetector(
            onTap: onToggleFavorite,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: template.isFavorite ? AppColors.amber100 : AppColors.slate100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                template.isFavorite ? Icons.star : Icons.star_outline,
                color: template.isFavorite ? AppColors.amber500 : AppColors.slate400,
                size: 20,
              ),
            ),
          ),
          title: Text(
            template.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.slate800,
            ),
          ),
          subtitle: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${template.minutes}분',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate600,
                  ),
                ),
              ),
              if (categoryCount > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '$categoryCount${AppStrings.taskUsedIn}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.slate500),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.slate600),
                    const SizedBox(width: 8),
                    const Text(AppStrings.edit),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.delete,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: onEdit,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';
import 'controller/category_controller.dart';
import 'widgets/category_form_bottom_sheet.dart';

/// 카테고리 관리 화면
class CategoryManagementScreen extends GetView<CategoryController> {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(AppStrings.categoryManage),
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

        if (controller.categories.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return _CategoryListItem(
              category: category,
              onEdit: () => _onEditCategory(category),
              onDelete: () => _onDeleteCategory(category),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddCategory,
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
              Icons.folder_outlined,
              size: 64,
              color: AppColors.slate300,
            ),
            const SizedBox(height: 16),
            const Text(
              '카테고리가 없어요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.slate700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.categoryEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _onAddCategory,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.categoryAdd),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Actions ====================

  void _onAddCategory() {
    CategoryFormBottomSheet.show(
      isDuplicateName: controller.isDuplicateName,
      onSave: (name, colorHex) async {
        await controller.addCategory(name, colorHex);
      },
    );
  }

  void _onEditCategory(CategoryEntity category) {
    CategoryFormBottomSheet.show(
      category: category,
      isDuplicateName: controller.isDuplicateName,
      onSave: (name, colorHex) async {
        await controller.updateCategory(
          category: category,
          name: name,
          colorHex: colorHex,
        );
      },
    );
  }

  void _onDeleteCategory(CategoryEntity category) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('삭제'),
        content: Text(AppStrings.categoryDeleteConfirm),
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
      await controller.deleteCategory(category.id);
      Get.snackbar(
        '삭제 완료',
        AppStrings.categoryDeleted,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}

/// 카테고리 리스트 아이템
class _CategoryListItem extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryListItem({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.hexToColor(category.colorHex);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.slate800,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들 (10단계에서 활성화)
            Icon(
              Icons.drag_indicator,
              color: AppColors.slate300,
              size: 20,
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
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
                      Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.slate600),
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
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}

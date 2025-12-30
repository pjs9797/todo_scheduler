import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';
import '../task/task_template_form_bottom_sheet.dart';
import 'controller/task_library_controller.dart';
import 'widgets/tag_form_bottom_sheet.dart';

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
        actions: [
          IconButton(
            onPressed: _onManageTags,
            icon: const Icon(Icons.label_outline, size: 22),
            tooltip: '태그 관리',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.templates.isEmpty) {
          return _buildEmptyState();
        }

        final filteredTemplates = controller.filteredTemplates;

        return Column(
          children: [
            // 태그 필터 칩
            _buildTagFilters(),
            // 템플릿 목록
            Expanded(
              child: filteredTemplates.isEmpty
                  ? _buildFilterEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredTemplates.length,
                      itemBuilder: (context, index) {
                        final template = filteredTemplates[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _TaskTemplateListItem(
                            template: template,
                            tags: controller.tags
                                .where((t) => template.tagIds.contains(t.id))
                                .toList(),
                            categoryCount: controller.getCategoryCount(template.id),
                            onEdit: () => _onEditTemplate(template),
                            onDelete: () => _onDeleteTemplate(template),
                            onToggleFavorite: () => controller.toggleFavorite(template.id),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddTemplate,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTagFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: [
                // 전체 필터
                _TagFilterChip(
                  label: '전체',
                  isSelected: controller.selectedTagId.value == null,
                  onTap: () => controller.setFilter(null),
                ),
                const SizedBox(width: 8),
                // 즐겨찾기 필터
                _TagFilterChip(
                  label: '즐겨찾기',
                  icon: Icons.star,
                  color: AppColors.amber500,
                  isSelected: controller.selectedTagId.value == 'favorites',
                  onTap: () => controller.setFilter('favorites'),
                ),
                const SizedBox(width: 8),
                // 태그 필터들
                ...controller.tags.map((tag) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _TagFilterChip(
                        label: tag.name,
                        colorHex: tag.colorHex,
                        isSelected: controller.selectedTagId.value == tag.id,
                        onTap: () => controller.setFilter(tag.id),
                      ),
                    )),
              ],
            )),
      ),
    );
  }

  Widget _buildFilterEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 48, color: AppColors.slate300),
          const SizedBox(height: 12),
          const Text(
            '해당 필터에 맞는 할 일이 없어요',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.slate500,
            ),
          ),
        ],
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
      availableTags: controller.tags.toList(),
      onSave: (title, minutes, isFavorite, tagIds) async {
        return controller.addTemplate(
          title: title,
          minutes: minutes,
          isFavorite: isFavorite,
          tagIds: tagIds,
        );
      },
    );
  }

  void _onEditTemplate(TaskTemplateEntity template) {
    TaskTemplateFormBottomSheet.show(
      template: template,
      availableTags: controller.tags.toList(),
      onSave: (title, minutes, isFavorite, tagIds) async {
        final updated = template.copyWith(
          title: title,
          minutes: minutes,
          isFavorite: isFavorite,
          tagIds: tagIds,
        );
        await controller.updateTemplate(updated);
        return updated;
      },
    );
  }

  void _onManageTags() {
    Get.bottomSheet(
      _TagManagementSheet(
        tags: controller.tags.toList(),
        onAddTag: (name, colorHex) => controller.addTag(name, colorHex),
        onEditTag: (tag) => controller.updateTag(tag),
        onDeleteTag: (id) => controller.deleteTag(id),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
  final List<TaskTagEntity> tags;
  final int categoryCount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;

  const _TaskTemplateListItem({
    required this.template,
    required this.tags,
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
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
              if (tags.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: tags.map((tag) {
                    final color = ColorUtils.hexToColor(tag.colorHex);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(38),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag.name,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    );
                  }).toList(),
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

/// 태그 필터 칩
class _TagFilterChip extends StatelessWidget {
  final String label;
  final String? colorHex;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagFilterChip({
    required this.label,
    this.colorHex,
    this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = colorHex != null
        ? ColorUtils.hexToColor(colorHex!)
        : (color ?? AppColors.slate500);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.slate300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : chipColor,
              ),
              const SizedBox(width: 4),
            ] else if (colorHex != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : chipColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.slate600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 태그 관리 바텀시트
class _TagManagementSheet extends StatefulWidget {
  final List<TaskTagEntity> tags;
  final Future<void> Function(String name, String colorHex) onAddTag;
  final Future<void> Function(TaskTagEntity tag) onEditTag;
  final Future<void> Function(String id) onDeleteTag;

  const _TagManagementSheet({
    required this.tags,
    required this.onAddTag,
    required this.onEditTag,
    required this.onDeleteTag,
  });

  @override
  State<_TagManagementSheet> createState() => _TagManagementSheetState();
}

class _TagManagementSheetState extends State<_TagManagementSheet> {
  late List<TaskTagEntity> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.tags);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeAreaBottom = mediaQuery.padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.slate200, width: 1),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '태그 관리',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, size: 22),
                  color: AppColors.slate600,
                ),
              ],
            ),
          ),
          // 태그 목록
          Flexible(
            child: _tags.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.label_off_outlined, size: 48, color: AppColors.slate300),
                          const SizedBox(height: 12),
                          const Text(
                            '태그가 없어요',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _tags.length,
                    itemBuilder: (context, index) {
                      final tag = _tags[index];
                      final color = ColorUtils.hexToColor(tag.colorHex);
                      return ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.withAlpha(51),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.label, color: color, size: 18),
                        ),
                        title: Text(
                          tag.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate800,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _onEditTag(tag),
                              icon: Icon(Icons.edit_outlined, size: 20, color: AppColors.slate500),
                            ),
                            IconButton(
                              onPressed: () => _onDeleteTag(tag),
                              icon: Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // 푸터
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + safeAreaBottom),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.slate200, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _onAddTag,
                icon: const Icon(Icons.add),
                label: const Text('태그 추가'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.slate700,
                  side: const BorderSide(color: AppColors.slate300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onAddTag() {
    TagFormBottomSheet.show(
      onSave: (name, colorHex) async {
        await widget.onAddTag(name, colorHex);
        // 새로 추가된 태그 반영
        final controller = Get.find<TaskLibraryController>();
        setState(() {
          _tags = controller.tags.toList();
        });
      },
    );
  }

  void _onEditTag(TaskTagEntity tag) {
    TagFormBottomSheet.show(
      tag: tag,
      onSave: (name, colorHex) async {
        final updated = tag.copyWith(name: name, colorHex: colorHex);
        await widget.onEditTag(updated);
        // 수정된 태그 반영
        final controller = Get.find<TaskLibraryController>();
        setState(() {
          _tags = controller.tags.toList();
        });
      },
    );
  }

  void _onDeleteTag(TaskTagEntity tag) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('삭제'),
        content: Text('\'${tag.name}\' 태그를 삭제할까요?\n이 태그가 적용된 할일에서도 제거됩니다.'),
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
      await widget.onDeleteTag(tag.id);
      // 삭제된 태그 반영
      final controller = Get.find<TaskLibraryController>();
      setState(() {
        _tags = controller.tags.toList();
      });
      Get.snackbar(
        '삭제 완료',
        '태그가 삭제되었어요.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}

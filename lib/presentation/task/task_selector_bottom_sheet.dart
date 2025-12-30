import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';

/// 할 일 선택 바텀시트 (카테고리에 할일 추가용)
class TaskSelectorBottomSheet extends StatefulWidget {
  final List<TaskTemplateEntity> allTemplates;
  final List<TaskTemplateEntity> favorites;
  final Set<String> alreadyAddedIds;
  final Future<void> Function(List<String> templateIds) onSelect;
  final VoidCallback onCreateNew;

  const TaskSelectorBottomSheet({
    super.key,
    required this.allTemplates,
    required this.favorites,
    required this.alreadyAddedIds,
    required this.onSelect,
    required this.onCreateNew,
  });

  /// 바텀시트 표시
  static Future<void> show({
    required List<TaskTemplateEntity> allTemplates,
    required List<TaskTemplateEntity> favorites,
    required Set<String> alreadyAddedIds,
    required Future<void> Function(List<String> templateIds) onSelect,
    required VoidCallback onCreateNew,
  }) {
    return Get.bottomSheet(
      TaskSelectorBottomSheet(
        allTemplates: allTemplates,
        favorites: favorites,
        alreadyAddedIds: alreadyAddedIds,
        onSelect: onSelect,
        onCreateNew: onCreateNew,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<TaskSelectorBottomSheet> createState() => _TaskSelectorBottomSheetState();
}

class _TaskSelectorBottomSheetState extends State<TaskSelectorBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  String _searchQuery = '';
  bool _isLoading = false;

  List<TaskTemplateEntity> get _filteredTemplates {
    if (_searchQuery.isEmpty) {
      return widget.allTemplates;
    }
    return widget.allTemplates
        .where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<TaskTemplateEntity> get _filteredFavorites {
    if (_searchQuery.isEmpty) {
      return widget.favorites;
    }
    return widget.favorites
        .where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;
    final safeAreaBottom = mediaQuery.padding.bottom;

    final availableHeight = screenHeight - keyboardHeight;
    final maxSheetHeight = availableHeight * 0.85;
    final bottomPadding = keyboardHeight > 0 ? 0.0 : safeAreaBottom;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Flexible(child: _buildContent()),
          _buildFooter(bottomPadding),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
              AppStrings.taskSelect,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.slate800,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.close, size: 22),
              color: AppColors.slate600,
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppStrings.taskSelectHint,
          hintStyle: const TextStyle(color: AppColors.slate400),
          prefixIcon: const Icon(Icons.search, color: AppColors.slate400),
          filled: true,
          fillColor: AppColors.slate50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.allTemplates.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // 즐겨찾기 섹션
        if (_filteredFavorites.isNotEmpty) ...[
          _buildSectionHeader(AppStrings.taskFavorites, Icons.star, AppColors.amber500),
          ..._filteredFavorites.map((t) => _buildTaskItem(t)),
          const SizedBox(height: 16),
        ],
        // 전체 할일 섹션
        _buildSectionHeader(AppStrings.taskAll, Icons.list_alt, AppColors.slate600),
        ..._filteredTemplates.map((t) => _buildTaskItem(t)),
        const SizedBox(height: 8),
        // 새 할일 만들기
        _buildCreateNewButton(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.slate300),
          const SizedBox(height: 16),
          Text(
            AppStrings.taskLibraryEmpty,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.slate500,
            ),
          ),
          const SizedBox(height: 24),
          _buildCreateNewButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.slate600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskTemplateEntity template) {
    final isAlreadyAdded = widget.alreadyAddedIds.contains(template.id);
    final isSelected = _selectedIds.contains(template.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isAlreadyAdded
            ? AppColors.slate100
            : isSelected
                ? AppColors.slate100
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isAlreadyAdded
              ? null
              : () {
                  setState(() {
                    if (isSelected) {
                      _selectedIds.remove(template.id);
                    } else {
                      _selectedIds.add(template.id);
                    }
                  });
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.slate400 : AppColors.slate200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // 선택 체크박스
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isAlreadyAdded
                        ? AppColors.slate300
                        : isSelected
                            ? AppColors.slate800
                            : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isAlreadyAdded
                          ? AppColors.slate300
                          : isSelected
                              ? AppColors.slate800
                              : AppColors.slate300,
                      width: 1.5,
                    ),
                  ),
                  child: isAlreadyAdded || isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                // 즐겨찾기 아이콘
                if (template.isFavorite)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.star,
                      size: 14,
                      color: AppColors.amber500,
                    ),
                  ),
                // 할일 이름
                Expanded(
                  child: Text(
                    template.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isAlreadyAdded ? AppColors.slate400 : AppColors.slate800,
                    ),
                  ),
                ),
                // 시간
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAlreadyAdded ? AppColors.slate200 : AppColors.slate100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${template.minutes}분',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAlreadyAdded ? AppColors.slate400 : AppColors.slate600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateNewButton() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.back();
          widget.onCreateNew();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: AppColors.slate600),
              const SizedBox(width: 6),
              Text(
                AppStrings.taskNewCreate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(double bottomPadding) {
    final selectedCount = _selectedIds.length;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.slate200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.slate700,
                  side: const BorderSide(color: AppColors.slate300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  AppStrings.cancel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: selectedCount == 0 || _isLoading ? null : _onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.slate900,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.slate300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        selectedCount > 0
                            ? '${AppStrings.add} ($selectedCount${AppStrings.taskSelected})'
                            : AppStrings.add,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSelect() async {
    if (_selectedIds.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await widget.onSelect(_selectedIds.toList());
      Get.back();
      Get.snackbar(
        '추가 완료',
        '${_selectedIds.length}개의 할 일을 추가했어요.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';

/// 할 일 선택 바텀시트 (카테고리에 할일 추가용)
class TaskSelectorBottomSheet extends StatefulWidget {
  final List<TaskTemplateEntity> allTemplates;
  final List<TaskTemplateEntity> favorites;
  final List<TaskTagEntity> availableTags;
  final Set<String> alreadyAddedIds;
  final Future<void> Function(List<String> templateIds) onSelect;
  final VoidCallback onCreateNew;

  const TaskSelectorBottomSheet({
    super.key,
    required this.allTemplates,
    required this.favorites,
    this.availableTags = const [],
    required this.alreadyAddedIds,
    required this.onSelect,
    required this.onCreateNew,
  });

  /// 바텀시트 표시
  static Future<void> show({
    required List<TaskTemplateEntity> allTemplates,
    required List<TaskTemplateEntity> favorites,
    List<TaskTagEntity> availableTags = const [],
    required Set<String> alreadyAddedIds,
    required Future<void> Function(List<String> templateIds) onSelect,
    required VoidCallback onCreateNew,
  }) {
    return Get.bottomSheet(
      TaskSelectorBottomSheet(
        allTemplates: allTemplates,
        favorites: favorites,
        availableTags: availableTags,
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
  String? _selectedFilter; // null = 전체, 'favorites' = 즐겨찾기, 그 외 = 태그 ID
  bool _isLoading = false;

  List<TaskTemplateEntity> get _filteredTemplates {
    var templates = widget.allTemplates;

    // 필터 적용
    if (_selectedFilter == 'favorites') {
      templates = templates.where((t) => t.isFavorite).toList();
    } else if (_selectedFilter != null) {
      templates = templates.where((t) => t.tagIds.contains(_selectedFilter)).toList();
    }

    // 검색 적용
    if (_searchQuery.isNotEmpty) {
      templates = templates
          .where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return templates;
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
          _buildFilterChips(),
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

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 전체 필터
            _FilterChip(
              label: '전체',
              isSelected: _selectedFilter == null,
              onTap: () => setState(() => _selectedFilter = null),
            ),
            const SizedBox(width: 8),
            // 즐겨찾기 필터
            _FilterChip(
              label: '즐겨찾기',
              icon: Icons.star,
              color: AppColors.amber500,
              isSelected: _selectedFilter == 'favorites',
              onTap: () => setState(() => _selectedFilter = 'favorites'),
            ),
            const SizedBox(width: 8),
            // 태그 필터들
            ...widget.availableTags.map((tag) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: tag.name,
                    colorHex: tag.colorHex,
                    isSelected: _selectedFilter == tag.id,
                    onTap: () => setState(() => _selectedFilter = tag.id),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
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

    final templates = _filteredTemplates;

    if (templates.isEmpty) {
      return _buildFilterEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        ...templates.map((t) => _buildTaskItem(t)),
        const SizedBox(height: 8),
        // 새 할일 만들기
        _buildCreateNewButton(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilterEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 48, color: AppColors.slate300),
          const SizedBox(height: 16),
          const Text(
            '해당 필터에 맞는 할 일이 없어요',
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

/// 필터 칩 위젯
class _FilterChip extends StatelessWidget {
  final String label;
  final String? colorHex;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
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

import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../domain/domain.dart';

/// 필터 칩 위젯
class FilterChips extends StatelessWidget {
  final List<CategoryEntity> categories;
  final TaskFilter currentFilter;
  final ValueChanged<TaskFilter> onFilterChanged;

  const FilterChips({
    super.key,
    required this.categories,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 전체 필터
          _FilterChip(
            label: AppStrings.filterAll,
            isSelected: currentFilter is TaskFilterAll,
            onTap: () => onFilterChanged(const TaskFilterAll()),
          ),
          const SizedBox(width: 8),
          // 카테고리 필터들
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: category.name,
                  colorHex: category.colorHex,
                  isSelected: currentFilter is TaskFilterByCategory &&
                      (currentFilter as TaskFilterByCategory).categoryId ==
                          category.id,
                  onTap: () =>
                      onFilterChanged(TaskFilterByCategory(category.id)),
                ),
              )),
          // 미분류 필터
          _FilterChip(
            label: AppStrings.filterUnassigned,
            isSelected: currentFilter is TaskFilterUnassigned,
            onTap: () => onFilterChanged(const TaskFilterUnassigned()),
          ),
        ],
      ),
    );
  }
}

/// 개별 필터 칩
class _FilterChip extends StatelessWidget {
  final String label;
  final String? colorHex;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.colorHex,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = colorHex != null
        ? ColorUtils.hexToColor(colorHex!)
        : AppColors.slate500;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.slate300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (colorHex != null) ...[
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
                fontSize: 13,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/core.dart';
import '../../../domain/domain.dart';

/// 카테고리 추가/수정 바텀시트
class CategoryFormBottomSheet extends StatefulWidget {
  final CategoryEntity? category;
  final bool Function(String name, {String? excludeId}) isDuplicateName;
  final Future<void> Function(String name, String colorHex) onSave;

  const CategoryFormBottomSheet({
    super.key,
    this.category,
    required this.isDuplicateName,
    required this.onSave,
  });

  /// 바텀시트 표시
  static Future<void> show({
    CategoryEntity? category,
    required bool Function(String name, {String? excludeId}) isDuplicateName,
    required Future<void> Function(String name, String colorHex) onSave,
  }) {
    return Get.bottomSheet(
      CategoryFormBottomSheet(
        category: category,
        isDuplicateName: isDuplicateName,
        onSave: onSave,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  State<CategoryFormBottomSheet> createState() =>
      _CategoryFormBottomSheetState();
}

class _CategoryFormBottomSheetState extends State<CategoryFormBottomSheet> {
  late final TextEditingController _nameController;
  late String _selectedColorHex;
  bool _isLoading = false;

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedColorHex =
        widget.category?.colorHex ?? AppColors.categoryColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = bottomInset > 0 ? 20.0 + bottomInset : 24.0;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들바
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 제목
              Text(
                isEditing ? AppStrings.categoryEdit : AppStrings.categoryAdd,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate800,
                ),
              ),
              const SizedBox(height: 20),
              // 카테고리 이름
              _buildLabel(AppStrings.categoryName),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '예: 공부',
                  hintStyle: TextStyle(color: AppColors.slate400),
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              // 색상 선택
              _buildLabel(AppStrings.categoryColor),
              const SizedBox(height: 12),
              _buildColorSelector(),
              const SizedBox(height: 24),
              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slate800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                          isEditing ? AppStrings.save : AppStrings.add,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.slate700,
      ),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppColors.categoryColors.map((colorHex) {
        final color = ColorUtils.hexToColor(colorHex);
        final isSelected = _selectedColorHex == colorHex;

        return GestureDetector(
          onTap: () => setState(() => _selectedColorHex = colorHex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppColors.slate800, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _onSave() async {
    final name = _nameController.text.trim();

    // 유효성 검사: 빈 이름
    if (name.isEmpty) {
      Get.snackbar(
        '입력 오류',
        AppStrings.errorCategoryNameEmpty,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // 유효성 검사: 중복 이름
    if (widget.isDuplicateName(name, excludeId: widget.category?.id)) {
      Get.snackbar(
        '입력 오류',
        AppStrings.errorCategoryNameDuplicate,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onSave(name, _selectedColorHex);
      Get.back();
      Get.snackbar(
        isEditing ? '수정 완료' : '추가 완료',
        AppStrings.categorySaved,
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

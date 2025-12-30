import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/core.dart';
import '../../../domain/domain.dart';

/// 태그 추가/수정 바텀시트
class TagFormBottomSheet extends StatefulWidget {
  final TaskTagEntity? tag;
  final Future<void> Function(String name, String colorHex) onSave;

  const TagFormBottomSheet({
    super.key,
    this.tag,
    required this.onSave,
  });

  static Future<void> show({
    TaskTagEntity? tag,
    required Future<void> Function(String name, String colorHex) onSave,
  }) {
    return Get.bottomSheet(
      TagFormBottomSheet(tag: tag, onSave: onSave),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<TagFormBottomSheet> createState() => _TagFormBottomSheetState();
}

class _TagFormBottomSheetState extends State<TagFormBottomSheet> {
  late final TextEditingController _nameController;
  late String _selectedColor;
  bool _isLoading = false;

  bool get isEditing => widget.tag != null;

  static const List<String> _tagColors = [
    '#EF4444', // red
    '#F97316', // orange
    '#F59E0B', // amber
    '#84CC16', // lime
    '#22C55E', // green
    '#14B8A6', // teal
    '#06B6D4', // cyan
    '#3B82F6', // blue
    '#8B5CF6', // violet
    '#EC4899', // pink
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tag?.name ?? '');
    _selectedColor = widget.tag?.colorHex ?? _tagColors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;
    final safeAreaBottom = mediaQuery.padding.bottom;

    final availableHeight = screenHeight - keyboardHeight;
    final maxSheetHeight = availableHeight * 0.9;
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
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: _buildContent(),
            ),
          ),
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
          Expanded(
            child: Text(
              isEditing ? '태그 수정' : '태그 추가',
              style: const TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '태그 이름',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.slate700,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '예: 공부, 운동',
            hintStyle: const TextStyle(color: AppColors.slate400),
            filled: true,
            fillColor: AppColors.slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '색상',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.slate700,
          ),
        ),
        const SizedBox(height: 12),
        _buildColorPicker(),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _tagColors.map((colorHex) {
        final color = ColorUtils.hexToColor(colorHex);
        final isSelected = _selectedColor == colorHex;

        return GestureDetector(
          onTap: () => setState(() => _selectedColor = colorHex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.slate800 : Colors.transparent,
                width: 3,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(double bottomPadding) {
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
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSave,
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
                        isEditing ? AppStrings.save : AppStrings.add,
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

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        '입력 오류',
        '태그 이름을 입력해주세요.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onSave(name, _selectedColor);
      Get.back();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

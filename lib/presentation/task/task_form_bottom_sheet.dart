import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';

/// 할 일 추가/수정 바텀시트
class TaskFormBottomSheet extends StatefulWidget {
  final TaskEntity? task;
  final String? initialCategoryId;
  final List<CategoryEntity> categories;
  final Future<void> Function(String title, int minutes, String? categoryId) onSave;

  const TaskFormBottomSheet({
    super.key,
    this.task,
    this.initialCategoryId,
    required this.categories,
    required this.onSave,
  });

  /// 바텀시트 표시
  static Future<void> show({
    required List<CategoryEntity> categories,
    TaskEntity? task,
    String? initialCategoryId,
    required Future<void> Function(String title, int minutes, String? categoryId) onSave,
  }) {
    return Get.bottomSheet(
      TaskFormBottomSheet(
        task: task,
        initialCategoryId: initialCategoryId,
        categories: categories,
        onSave: onSave,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<TaskFormBottomSheet> createState() => _TaskFormBottomSheetState();
}

class _TaskFormBottomSheetState extends State<TaskFormBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _minutesController;
  String? _selectedCategoryId;
  bool _isLoading = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _minutesController = TextEditingController(
      text: widget.task?.minutes.toString() ?? '',
    );
    _selectedCategoryId = widget.task?.categoryId ?? widget.initialCategoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;
    final safeAreaBottom = mediaQuery.padding.bottom;

    // 키보드가 올라오면 사용 가능한 높이 계산
    final availableHeight = screenHeight - keyboardHeight;
    final maxSheetHeight = availableHeight * 0.9;

    // 키보드가 올라왔을 때는 safeArea 패딩 불필요
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
              isEditing ? AppStrings.taskEdit : AppStrings.taskAdd,
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

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 할 일 이름
        _buildLabel(AppStrings.taskName),
        const SizedBox(height: 10),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: AppStrings.taskNameHint,
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
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        // 소요 시간
        _buildLabel(AppStrings.taskDuration),
        const SizedBox(height: 10),
        TextField(
          controller: _minutesController,
          decoration: InputDecoration(
            hintText: AppStrings.taskDurationHint,
            hintStyle: const TextStyle(color: AppColors.slate400),
            helperText: AppStrings.taskDurationHelper,
            helperStyle: const TextStyle(color: AppColors.slate400, fontSize: 12),
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
            suffixText: '분',
            suffixStyle: const TextStyle(color: AppColors.slate600),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 20),
        // 카테고리
        _buildLabel(AppStrings.taskCategory),
        const SizedBox(height: 12),
        _buildCategorySelector(),
      ],
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

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // 미분류 옵션
        _CategoryChip(
          label: AppStrings.filterUnassigned,
          isSelected: _selectedCategoryId == null,
          onTap: () => setState(() => _selectedCategoryId = null),
        ),
        // 카테고리 옵션들
        ...widget.categories.map((category) => _CategoryChip(
              label: category.name,
              colorHex: category.colorHex,
              isSelected: _selectedCategoryId == category.id,
              onTap: () => setState(() => _selectedCategoryId = category.id),
            )),
      ],
    );
  }

  Future<void> _onSave() async {
    final title = _titleController.text.trim();
    final minutesText = _minutesController.text.trim();

    if (title.isEmpty) {
      Get.snackbar(
        '입력 오류',
        AppStrings.errorTaskNameEmpty,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final minutes = int.tryParse(minutesText);
    if (minutes == null || minutes < 1) {
      Get.snackbar(
        '입력 오류',
        AppStrings.errorTaskDurationInvalid,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onSave(title, minutes, _selectedCategoryId);
      Get.back();
      Get.snackbar(
        isEditing ? '수정 완료' : '추가 완료',
        AppStrings.taskSaved,
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

/// 카테고리 선택 칩
class _CategoryChip extends StatelessWidget {
  final String label;
  final String? colorHex;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
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

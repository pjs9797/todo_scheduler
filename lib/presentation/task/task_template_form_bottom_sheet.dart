import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/core.dart';
import '../../domain/domain.dart';

/// 할 일 템플릿 추가/수정 바텀시트
class TaskTemplateFormBottomSheet extends StatefulWidget {
  final TaskTemplateEntity? template;
  final List<TaskTagEntity> availableTags;
  final Future<TaskTemplateEntity> Function(String title, int minutes, bool isFavorite, List<String> tagIds) onSave;

  const TaskTemplateFormBottomSheet({
    super.key,
    this.template,
    this.availableTags = const [],
    required this.onSave,
  });

  /// 바텀시트 표시
  static Future<TaskTemplateEntity?> show({
    TaskTemplateEntity? template,
    List<TaskTagEntity> availableTags = const [],
    required Future<TaskTemplateEntity> Function(String title, int minutes, bool isFavorite, List<String> tagIds) onSave,
  }) async {
    return Get.bottomSheet<TaskTemplateEntity>(
      TaskTemplateFormBottomSheet(
        template: template,
        availableTags: availableTags,
        onSave: onSave,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<TaskTemplateFormBottomSheet> createState() => _TaskTemplateFormBottomSheetState();
}

class _TaskTemplateFormBottomSheetState extends State<TaskTemplateFormBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _minutesController;
  late bool _isFavorite;
  late List<String> _selectedTagIds;
  bool _isLoading = false;

  bool get isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.template?.title ?? '');
    _minutesController = TextEditingController(
      text: widget.template?.minutes.toString() ?? '',
    );
    _isFavorite = widget.template?.isFavorite ?? false;
    _selectedTagIds = List.from(widget.template?.tagIds ?? []);
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
              isEditing ? AppStrings.taskEdit : AppStrings.taskNewCreate,
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
        // 태그 선택
        if (widget.availableTags.isNotEmpty) ...[
          _buildLabel('태그'),
          const SizedBox(height: 10),
          _buildTagSelector(),
          const SizedBox(height: 20),
        ],
        // 즐겨찾기
        _buildFavoriteToggle(),
      ],
    );
  }

  Widget _buildTagSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.availableTags.map((tag) {
        final isSelected = _selectedTagIds.contains(tag.id);
        final color = ColorUtils.hexToColor(tag.colorHex);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedTagIds.remove(tag.id);
              } else {
                _selectedTagIds.add(tag.id);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : AppColors.slate300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  tag.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.slate600,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFavoriteToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isFavorite = !_isFavorite),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _isFavorite ? AppColors.amber50 : AppColors.slate50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isFavorite ? AppColors.amber300 : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isFavorite ? Icons.star : Icons.star_outline,
              size: 20,
              color: _isFavorite ? AppColors.amber500 : AppColors.slate400,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppStrings.taskFavorites,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _isFavorite ? AppColors.amber700 : AppColors.slate600,
                ),
              ),
            ),
            Container(
              width: 44,
              height: 26,
              decoration: BoxDecoration(
                color: _isFavorite ? AppColors.amber500 : AppColors.slate300,
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: _isFavorite ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
      final result = await widget.onSave(title, minutes, _isFavorite, _selectedTagIds);
      Get.back(result: result);
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

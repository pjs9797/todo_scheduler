import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../domain/domain.dart';
import '../controller/home_controller.dart';

/// 할 일 그룹 카드
class TaskGroupCard extends StatelessWidget {
  final TaskGroup group;
  final VoidCallback onAddTask;
  final ValueChanged<TaskEntity> onEditTask;
  final ValueChanged<TaskEntity> onDeleteTask;
  final void Function(int oldIndex, int newIndex) onReorder;

  const TaskGroupCard({
    super.key,
    required this.group,
    required this.onAddTask,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.hexToColor(group.colorHex);
    final totalMinutes =
        group.tasks.fold<int>(0, (sum, task) => sum + task.minutes);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    group.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate800,
                    ),
                  ),
                ),
                Text(
                  '${group.tasks.length}개 · $totalMinutes분',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onAddTask,
                  icon: const Icon(Icons.add, size: 20),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  color: AppColors.slate500,
                ),
              ],
            ),
          ),
          // 구분선
          const Divider(height: 1, color: AppColors.slate200),
          // 할 일 목록
          if (group.tasks.isEmpty)
            _buildEmptyTasks()
          else
            _buildReorderableList(),
        ],
      ),
    );
  }

  Widget _buildEmptyTasks() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          '할 일이 없습니다',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.slate400,
          ),
        ),
      ),
    );
  }

  Widget _buildReorderableList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: group.tasks.length,
      onReorder: onReorder,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final elevation = Tween<double>(begin: 0, end: 4).animate(animation).value;
            return Material(
              elevation: elevation,
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final task = group.tasks[index];
        return _TaskItem(
          key: ValueKey(task.id),
          task: task,
          index: index,
          onEdit: () => onEditTask(task),
          onDelete: () => onDeleteTask(task),
        );
      },
    );
  }
}

/// 개별 할 일 아이템
class _TaskItem extends StatelessWidget {
  final TaskEntity task;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskItem({
    super.key,
    required this.task,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 드래그 핸들
              ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_indicator,
                  size: 18,
                  color: AppColors.slate300,
                ),
              ),
              const SizedBox(width: 8),
              // 할 일 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${task.minutes}분',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              // 삭제 버튼
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 18),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                color: AppColors.slate400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

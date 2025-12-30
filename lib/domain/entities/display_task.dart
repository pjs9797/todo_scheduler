import 'task_template_entity.dart';
import 'category_task_entity.dart';

/// UI에서 사용할 할일 표시 데이터
/// CategoryTask와 TaskTemplate을 결합한 형태
class DisplayTask {
  final String categoryTaskId;
  final String taskTemplateId;
  final String? categoryId;
  final String title;
  final int minutes;
  final int sortOrder;
  final bool isFavorite;

  const DisplayTask({
    required this.categoryTaskId,
    required this.taskTemplateId,
    this.categoryId,
    required this.title,
    required this.minutes,
    required this.sortOrder,
    required this.isFavorite,
  });

  /// CategoryTask와 TaskTemplate에서 생성
  factory DisplayTask.fromEntities({
    required CategoryTaskEntity categoryTask,
    required TaskTemplateEntity template,
  }) {
    return DisplayTask(
      categoryTaskId: categoryTask.id,
      taskTemplateId: template.id,
      categoryId: categoryTask.categoryId,
      title: template.title,
      minutes: template.minutes,
      sortOrder: categoryTask.sortOrder,
      isFavorite: template.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DisplayTask &&
        other.categoryTaskId == categoryTaskId &&
        other.taskTemplateId == taskTemplateId &&
        other.categoryId == categoryId &&
        other.title == title &&
        other.minutes == minutes &&
        other.sortOrder == sortOrder &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode => Object.hash(
        categoryTaskId,
        taskTemplateId,
        categoryId,
        title,
        minutes,
        sortOrder,
        isFavorite,
      );
}

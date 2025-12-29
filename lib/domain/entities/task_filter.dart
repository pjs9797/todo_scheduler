/// 할 일 필터 타입 (Domain Layer)
sealed class TaskFilter {
  const TaskFilter();
}

/// 전체 보기
class TaskFilterAll extends TaskFilter {
  const TaskFilterAll();
}

/// 미분류만 보기
class TaskFilterUnassigned extends TaskFilter {
  const TaskFilterUnassigned();
}

/// 특정 카테고리만 보기
class TaskFilterByCategory extends TaskFilter {
  final String categoryId;

  const TaskFilterByCategory(this.categoryId);
}

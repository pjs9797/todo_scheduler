/// 할 일 엔티티 (Domain Layer)
/// 프레임워크에 의존하지 않는 순수 Dart 클래스
class TaskEntity {
  final String id;
  final String title;
  final int minutes;
  final String? categoryId; // null이면 미분류
  final int sortOrder;
  final DateTime createdAt;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.minutes,
    this.categoryId,
    required this.sortOrder,
    required this.createdAt,
  });

  /// 미분류 여부
  bool get isUnassigned => categoryId == null;

  /// copyWith 패턴
  TaskEntity copyWith({
    String? id,
    String? title,
    int? minutes,
    String? Function()? categoryId,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      minutes: minutes ?? this.minutes,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskEntity &&
        other.id == id &&
        other.title == title &&
        other.minutes == minutes &&
        other.categoryId == categoryId &&
        other.sortOrder == sortOrder &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, minutes, categoryId, sortOrder, createdAt);
  }

  @override
  String toString() {
    return 'TaskEntity(id: $id, title: $title, minutes: $minutes, categoryId: $categoryId, sortOrder: $sortOrder)';
  }
}

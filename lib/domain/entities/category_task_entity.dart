/// 카테고리-할일 연결 엔티티 (Domain Layer)
/// 어떤 카테고리에 어떤 할일이 포함되어 있는지 관리
class CategoryTaskEntity {
  final String id;
  final String categoryId;
  final String taskTemplateId;
  final int sortOrder;
  final DateTime addedAt;

  const CategoryTaskEntity({
    required this.id,
    required this.categoryId,
    required this.taskTemplateId,
    required this.sortOrder,
    required this.addedAt,
  });

  CategoryTaskEntity copyWith({
    String? id,
    String? categoryId,
    String? taskTemplateId,
    int? sortOrder,
    DateTime? addedAt,
  }) {
    return CategoryTaskEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      taskTemplateId: taskTemplateId ?? this.taskTemplateId,
      sortOrder: sortOrder ?? this.sortOrder,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryTaskEntity &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.taskTemplateId == taskTemplateId &&
        other.sortOrder == sortOrder &&
        other.addedAt == addedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, categoryId, taskTemplateId, sortOrder, addedAt);
  }

  @override
  String toString() {
    return 'CategoryTaskEntity(id: $id, categoryId: $categoryId, taskTemplateId: $taskTemplateId, sortOrder: $sortOrder)';
  }
}

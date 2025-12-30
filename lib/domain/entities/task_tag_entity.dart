/// 할일 태그 엔티티 (Domain Layer)
class TaskTagEntity {
  final String id;
  final String name;
  final String colorHex;
  final int sortOrder;
  final DateTime createdAt;

  const TaskTagEntity({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.sortOrder,
    required this.createdAt,
  });

  TaskTagEntity copyWith({
    String? id,
    String? name,
    String? colorHex,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return TaskTagEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskTagEntity &&
        other.id == id &&
        other.name == name &&
        other.colorHex == colorHex &&
        other.sortOrder == sortOrder &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, colorHex, sortOrder, createdAt);
  }

  @override
  String toString() {
    return 'TaskTagEntity(id: $id, name: $name, colorHex: $colorHex)';
  }
}

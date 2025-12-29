/// 카테고리 엔티티 (Domain Layer)
/// 프레임워크에 의존하지 않는 순수 Dart 클래스
class CategoryEntity {
  final String id;
  final String name;
  final String colorHex;
  final int sortOrder;
  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.sortOrder,
    required this.createdAt,
  });

  /// copyWith 패턴
  CategoryEntity copyWith({
    String? id,
    String? name,
    String? colorHex,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return CategoryEntity(
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
    return other is CategoryEntity &&
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
    return 'CategoryEntity(id: $id, name: $name, colorHex: $colorHex, sortOrder: $sortOrder)';
  }
}

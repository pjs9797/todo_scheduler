/// 카테고리 엔티티 (Domain Layer)
/// 프레임워크에 의존하지 않는 순수 Dart 클래스
class CategoryEntity {
  final String id;
  final String name;
  final String colorHex;
  final int sortOrder;
  final int endTimeHour; // 완료 시간 (시)
  final int endTimeMinute; // 완료 시간 (분)
  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.sortOrder,
    this.endTimeHour = 9,
    this.endTimeMinute = 0,
    required this.createdAt,
  });

  /// 완료 시간 문자열 (HH:mm)
  String get endTimeString {
    final h = endTimeHour.toString().padLeft(2, '0');
    final m = endTimeMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// copyWith 패턴
  CategoryEntity copyWith({
    String? id,
    String? name,
    String? colorHex,
    int? sortOrder,
    int? endTimeHour,
    int? endTimeMinute,
    DateTime? createdAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      endTimeHour: endTimeHour ?? this.endTimeHour,
      endTimeMinute: endTimeMinute ?? this.endTimeMinute,
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
        other.endTimeHour == endTimeHour &&
        other.endTimeMinute == endTimeMinute &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, colorHex, sortOrder, endTimeHour, endTimeMinute, createdAt);
  }

  @override
  String toString() {
    return 'CategoryEntity(id: $id, name: $name, colorHex: $colorHex, endTime: $endTimeString)';
  }
}

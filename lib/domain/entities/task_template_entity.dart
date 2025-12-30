/// 할일 템플릿 엔티티 (Domain Layer)
/// 사용자가 만든 모든 할일의 원본
class TaskTemplateEntity {
  final String id;
  final String title;
  final int minutes;
  final bool isFavorite;
  final List<String> tagIds;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  const TaskTemplateEntity({
    required this.id,
    required this.title,
    required this.minutes,
    this.isFavorite = false,
    this.tagIds = const [],
    required this.createdAt,
    this.lastUsedAt,
  });

  TaskTemplateEntity copyWith({
    String? id,
    String? title,
    int? minutes,
    bool? isFavorite,
    List<String>? tagIds,
    DateTime? createdAt,
    DateTime? Function()? lastUsedAt,
  }) {
    return TaskTemplateEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      minutes: minutes ?? this.minutes,
      isFavorite: isFavorite ?? this.isFavorite,
      tagIds: tagIds ?? this.tagIds,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt != null ? lastUsedAt() : this.lastUsedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskTemplateEntity &&
        other.id == id &&
        other.title == title &&
        other.minutes == minutes &&
        other.isFavorite == isFavorite &&
        _listEquals(other.tagIds, tagIds) &&
        other.createdAt == createdAt &&
        other.lastUsedAt == lastUsedAt;
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, minutes, isFavorite, tagIds, createdAt, lastUsedAt);
  }

  @override
  String toString() {
    return 'TaskTemplateEntity(id: $id, title: $title, minutes: $minutes, isFavorite: $isFavorite)';
  }
}

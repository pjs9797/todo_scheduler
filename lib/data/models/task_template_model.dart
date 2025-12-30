import 'package:hive/hive.dart';
import '../../domain/entities/task_template_entity.dart';

part 'task_template_model.g.dart';

@HiveType(typeId: 2)
class TaskTemplateModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int minutes;

  @HiveField(3, defaultValue: false)
  final bool isFavorite;

  @HiveField(4, defaultValue: [])
  final List<String> tagIds;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? lastUsedAt;

  TaskTemplateModel({
    required this.id,
    required this.title,
    required this.minutes,
    this.isFavorite = false,
    this.tagIds = const [],
    required this.createdAt,
    this.lastUsedAt,
  });

  factory TaskTemplateModel.fromEntity(TaskTemplateEntity entity) {
    return TaskTemplateModel(
      id: entity.id,
      title: entity.title,
      minutes: entity.minutes,
      isFavorite: entity.isFavorite,
      tagIds: entity.tagIds,
      createdAt: entity.createdAt,
      lastUsedAt: entity.lastUsedAt,
    );
  }

  TaskTemplateEntity toEntity() {
    return TaskTemplateEntity(
      id: id,
      title: title,
      minutes: minutes,
      isFavorite: isFavorite,
      tagIds: tagIds,
      createdAt: createdAt,
      lastUsedAt: lastUsedAt,
    );
  }

  TaskTemplateModel copyWith({
    String? id,
    String? title,
    int? minutes,
    bool? isFavorite,
    List<String>? tagIds,
    DateTime? createdAt,
    DateTime? Function()? lastUsedAt,
  }) {
    return TaskTemplateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      minutes: minutes ?? this.minutes,
      isFavorite: isFavorite ?? this.isFavorite,
      tagIds: tagIds ?? this.tagIds,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt != null ? lastUsedAt() : this.lastUsedAt,
    );
  }
}

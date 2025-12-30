import 'package:hive/hive.dart';
import '../../domain/entities/task_tag_entity.dart';

part 'task_tag_model.g.dart';

@HiveType(typeId: 4)
class TaskTagModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String colorHex;

  @HiveField(3)
  final int sortOrder;

  @HiveField(4)
  final DateTime createdAt;

  TaskTagModel({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.sortOrder,
    required this.createdAt,
  });

  factory TaskTagModel.fromEntity(TaskTagEntity entity) {
    return TaskTagModel(
      id: entity.id,
      name: entity.name,
      colorHex: entity.colorHex,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
    );
  }

  TaskTagEntity toEntity() {
    return TaskTagEntity(
      id: id,
      name: name,
      colorHex: colorHex,
      sortOrder: sortOrder,
      createdAt: createdAt,
    );
  }

  TaskTagModel copyWith({
    String? id,
    String? name,
    String? colorHex,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return TaskTagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

import 'package:hive/hive.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final int minutes;

  @HiveField(3)
  final String? categoryId;

  @HiveField(4)
  final int sortOrder;

  @HiveField(5)
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.minutes,
    this.categoryId,
    required this.sortOrder,
    required this.createdAt,
  });

  /// Entity -> Model 변환
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      minutes: entity.minutes,
      categoryId: entity.categoryId,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
    );
  }

  /// Model -> Entity 변환
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      minutes: minutes,
      categoryId: categoryId,
      sortOrder: sortOrder,
      createdAt: createdAt,
    );
  }

  /// copyWith
  TaskModel copyWith({
    String? id,
    String? title,
    int? minutes,
    String? Function()? categoryId,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      minutes: minutes ?? this.minutes,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

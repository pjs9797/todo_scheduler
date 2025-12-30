import 'package:hive/hive.dart';
import '../../domain/entities/category_task_entity.dart';

part 'category_task_model.g.dart';

@HiveType(typeId: 3)
class CategoryTaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String taskTemplateId;

  @HiveField(3)
  final int sortOrder;

  @HiveField(4)
  final DateTime addedAt;

  CategoryTaskModel({
    required this.id,
    required this.categoryId,
    required this.taskTemplateId,
    required this.sortOrder,
    required this.addedAt,
  });

  factory CategoryTaskModel.fromEntity(CategoryTaskEntity entity) {
    return CategoryTaskModel(
      id: entity.id,
      categoryId: entity.categoryId,
      taskTemplateId: entity.taskTemplateId,
      sortOrder: entity.sortOrder,
      addedAt: entity.addedAt,
    );
  }

  CategoryTaskEntity toEntity() {
    return CategoryTaskEntity(
      id: id,
      categoryId: categoryId,
      taskTemplateId: taskTemplateId,
      sortOrder: sortOrder,
      addedAt: addedAt,
    );
  }

  CategoryTaskModel copyWith({
    String? id,
    String? categoryId,
    String? taskTemplateId,
    int? sortOrder,
    DateTime? addedAt,
  }) {
    return CategoryTaskModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      taskTemplateId: taskTemplateId ?? this.taskTemplateId,
      sortOrder: sortOrder ?? this.sortOrder,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

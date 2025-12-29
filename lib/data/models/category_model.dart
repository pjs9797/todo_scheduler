import 'package:hive/hive.dart';
import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
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

  @HiveField(5, defaultValue: 9)
  final int endTimeHour;

  @HiveField(6, defaultValue: 0)
  final int endTimeMinute;

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.sortOrder,
    required this.createdAt,
    this.endTimeHour = 9,
    this.endTimeMinute = 0,
  });

  /// Entity -> Model 변환
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      colorHex: entity.colorHex,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      endTimeHour: entity.endTimeHour,
      endTimeMinute: entity.endTimeMinute,
    );
  }

  /// Model -> Entity 변환
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      colorHex: colorHex,
      sortOrder: sortOrder,
      createdAt: createdAt,
      endTimeHour: endTimeHour,
      endTimeMinute: endTimeMinute,
    );
  }

  /// copyWith
  CategoryModel copyWith({
    String? id,
    String? name,
    String? colorHex,
    int? sortOrder,
    DateTime? createdAt,
    int? endTimeHour,
    int? endTimeMinute,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      endTimeHour: endTimeHour ?? this.endTimeHour,
      endTimeMinute: endTimeMinute ?? this.endTimeMinute,
    );
  }
}

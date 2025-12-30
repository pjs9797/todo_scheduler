// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryTaskModelAdapter extends TypeAdapter<CategoryTaskModel> {
  @override
  final int typeId = 3;

  @override
  CategoryTaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryTaskModel(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      taskTemplateId: fields[2] as String,
      sortOrder: fields[3] as int,
      addedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryTaskModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.taskTemplateId)
      ..writeByte(3)
      ..write(obj.sortOrder)
      ..writeByte(4)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryTaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

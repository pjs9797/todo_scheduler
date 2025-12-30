// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_template_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskTemplateModelAdapter extends TypeAdapter<TaskTemplateModel> {
  @override
  final int typeId = 2;

  @override
  TaskTemplateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskTemplateModel(
      id: fields[0] as String,
      title: fields[1] as String,
      minutes: fields[2] as int,
      isFavorite: fields[3] == null ? false : fields[3] as bool,
      tagIds: fields[4] == null ? [] : (fields[4] as List).cast<String>(),
      createdAt: fields[5] as DateTime,
      lastUsedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskTemplateModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.minutes)
      ..writeByte(3)
      ..write(obj.isFavorite)
      ..writeByte(4)
      ..write(obj.tagIds)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.lastUsedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTemplateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

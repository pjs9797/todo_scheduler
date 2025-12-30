import 'package:uuid/uuid.dart';

import '../../domain/entities/task_tag_entity.dart';
import '../../domain/repositories/task_tag_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/task_tag_model.dart';

/// 할일 태그 Repository 구현체
class TaskTagRepositoryImpl implements TaskTagRepository {
  final LocalDataSource _localDataSource;
  final _uuid = const Uuid();

  TaskTagRepositoryImpl(this._localDataSource);

  @override
  Future<List<TaskTagEntity>> getAll() async {
    final models = _localDataSource.getAllTaskTags();
    final entities = models.map((m) => m.toEntity()).toList();
    entities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return entities;
  }

  @override
  Future<TaskTagEntity?> getById(String id) async {
    final model = _localDataSource.getTaskTagById(id);
    return model?.toEntity();
  }

  @override
  Future<TaskTagEntity> add({
    required String name,
    required String colorHex,
  }) async {
    final models = _localDataSource.getAllTaskTags();
    final nextSortOrder = models.isEmpty
        ? 0
        : models.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    final model = TaskTagModel(
      id: _uuid.v4(),
      name: name,
      colorHex: colorHex,
      sortOrder: nextSortOrder,
      createdAt: DateTime.now(),
    );
    await _localDataSource.saveTaskTag(model);
    return model.toEntity();
  }

  @override
  Future<void> update(TaskTagEntity tag) async {
    final model = TaskTagModel.fromEntity(tag);
    await _localDataSource.saveTaskTag(model);
  }

  @override
  Future<void> delete(String id) async {
    await _localDataSource.deleteTaskTag(id);
  }

  @override
  Future<void> reorder(List<String> orderedIds) async {
    final models = _localDataSource.getAllTaskTags();
    final updatedModels = <TaskTagModel>[];

    for (int i = 0; i < orderedIds.length; i++) {
      final model = models.firstWhere(
        (t) => t.id == orderedIds[i],
        orElse: () => throw Exception('Tag not found: ${orderedIds[i]}'),
      );
      updatedModels.add(TaskTagModel(
        id: model.id,
        name: model.name,
        colorHex: model.colorHex,
        sortOrder: i,
        createdAt: model.createdAt,
      ));
    }
    await _localDataSource.saveAllTaskTags(updatedModels);
  }

  @override
  Future<bool> isNameDuplicate(String name, {String? excludeId}) async {
    final models = _localDataSource.getAllTaskTags();
    final lowerName = name.trim().toLowerCase();
    return models.any((t) =>
        t.name.trim().toLowerCase() == lowerName &&
        (excludeId == null || t.id != excludeId));
  }
}

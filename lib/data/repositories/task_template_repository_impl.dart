import 'package:uuid/uuid.dart';

import '../../domain/entities/task_template_entity.dart';
import '../../domain/repositories/task_template_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/task_template_model.dart';

/// 할일 템플릿 Repository 구현체
class TaskTemplateRepositoryImpl implements TaskTemplateRepository {
  final LocalDataSource _localDataSource;
  final _uuid = const Uuid();

  TaskTemplateRepositoryImpl(this._localDataSource);

  @override
  Future<List<TaskTemplateEntity>> getAll() async {
    final models = _localDataSource.getAllTaskTemplates();
    final entities = models.map((m) => m.toEntity()).toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entities;
  }

  @override
  Future<TaskTemplateEntity?> getById(String id) async {
    final model = _localDataSource.getTaskTemplateById(id);
    return model?.toEntity();
  }

  @override
  Future<List<TaskTemplateEntity>> getFavorites() async {
    final models = _localDataSource.getAllTaskTemplates();
    final favorites = models.where((m) => m.isFavorite).toList();
    final entities = favorites.map((m) => m.toEntity()).toList();
    entities.sort((a, b) {
      final lastUsedA = a.lastUsedAt ?? DateTime(1970);
      final lastUsedB = b.lastUsedAt ?? DateTime(1970);
      return lastUsedB.compareTo(lastUsedA);
    });
    return entities;
  }

  @override
  Future<List<TaskTemplateEntity>> getByTagId(String tagId) async {
    final models = _localDataSource.getAllTaskTemplates();
    final filtered = models.where((m) => m.tagIds.contains(tagId)).toList();
    final entities = filtered.map((m) => m.toEntity()).toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entities;
  }

  @override
  Future<TaskTemplateEntity> add({
    required String title,
    required int minutes,
    bool isFavorite = false,
    List<String> tagIds = const [],
  }) async {
    final now = DateTime.now();
    final model = TaskTemplateModel(
      id: _uuid.v4(),
      title: title,
      minutes: minutes,
      isFavorite: isFavorite,
      tagIds: tagIds,
      createdAt: now,
      lastUsedAt: null,
    );
    await _localDataSource.saveTaskTemplate(model);
    return model.toEntity();
  }

  @override
  Future<void> update(TaskTemplateEntity template) async {
    final model = TaskTemplateModel.fromEntity(template);
    await _localDataSource.saveTaskTemplate(model);
  }

  @override
  Future<void> delete(String id) async {
    await _localDataSource.deleteTaskTemplate(id);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final model = _localDataSource.getTaskTemplateById(id);
    if (model != null) {
      final updated = TaskTemplateModel(
        id: model.id,
        title: model.title,
        minutes: model.minutes,
        isFavorite: !model.isFavorite,
        tagIds: model.tagIds,
        createdAt: model.createdAt,
        lastUsedAt: model.lastUsedAt,
      );
      await _localDataSource.saveTaskTemplate(updated);
    }
  }

  @override
  Future<void> updateLastUsedAt(String id) async {
    final model = _localDataSource.getTaskTemplateById(id);
    if (model != null) {
      final updated = TaskTemplateModel(
        id: model.id,
        title: model.title,
        minutes: model.minutes,
        isFavorite: model.isFavorite,
        tagIds: model.tagIds,
        createdAt: model.createdAt,
        lastUsedAt: DateTime.now(),
      );
      await _localDataSource.saveTaskTemplate(updated);
    }
  }

  @override
  Future<List<TaskTemplateEntity>> search(String query) async {
    final models = _localDataSource.getAllTaskTemplates();
    final lowerQuery = query.toLowerCase().trim();
    final filtered = models
        .where((m) => m.title.toLowerCase().contains(lowerQuery))
        .toList();
    final entities = filtered.map((m) => m.toEntity()).toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entities;
  }
}

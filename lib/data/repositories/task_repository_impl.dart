import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/task_model.dart';

/// 할 일 저장소 구현체
class TaskRepositoryImpl implements TaskRepository {
  final LocalDataSource _localDataSource;

  TaskRepositoryImpl(this._localDataSource);

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    final models = _localDataSource.getAllTasks();
    final entities = models.map((m) => m.toEntity()).toList();
    entities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return entities;
  }

  @override
  Future<List<TaskEntity>> getTasksByFilter(TaskFilter filter) async {
    final models = _localDataSource.getAllTasks();
    List<TaskModel> filtered;

    switch (filter) {
      case TaskFilterAll():
        filtered = models;
      case TaskFilterUnassigned():
        filtered = models.where((t) => t.categoryId == null).toList();
      case TaskFilterByCategory(:final categoryId):
        filtered = models.where((t) => t.categoryId == categoryId).toList();
    }

    final entities = filtered.map((m) => m.toEntity()).toList();
    entities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return entities;
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final model = _localDataSource.getTaskById(id);
    return model?.toEntity();
  }

  @override
  Future<int> getTaskCountByCategory(String categoryId) async {
    final models = _localDataSource.getAllTasks();
    return models.where((t) => t.categoryId == categoryId).length;
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _localDataSource.saveTask(model);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _localDataSource.saveTask(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDataSource.deleteTask(id);
  }

  @override
  Future<void> reorderTasks(List<TaskEntity> tasks) async {
    final models = tasks
        .asMap()
        .entries
        .map((e) => TaskModel.fromEntity(
              e.value.copyWith(sortOrder: e.key),
            ))
        .toList();
    await _localDataSource.saveAllTasks(models);
  }

  @override
  Future<void> unassignTasksByCategory(String categoryId) async {
    final models = _localDataSource.getAllTasks();
    final toUpdate = models.where((t) => t.categoryId == categoryId).toList();

    for (final model in toUpdate) {
      final updated = model.copyWith(categoryId: () => null);
      await _localDataSource.saveTask(updated);
    }
  }

  @override
  Future<int> getNextSortOrder(TaskFilter filter) async {
    final tasks = await getTasksByFilter(filter);
    if (tasks.isEmpty) return 0;
    final maxOrder = tasks.map((t) => t.sortOrder).reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }
}

import 'package:uuid/uuid.dart';

import '../../domain/entities/category_task_entity.dart';
import '../../domain/repositories/category_task_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/category_task_model.dart';

/// 카테고리-할일 연결 Repository 구현체
class CategoryTaskRepositoryImpl implements CategoryTaskRepository {
  final LocalDataSource _localDataSource;
  final _uuid = const Uuid();

  CategoryTaskRepositoryImpl(this._localDataSource);

  @override
  Future<List<CategoryTaskEntity>> getByCategoryId(String categoryId) async {
    final models = _localDataSource.getAllCategoryTasks();
    final filtered = models.where((ct) => ct.categoryId == categoryId).toList();
    final entities = filtered.map((m) => m.toEntity()).toList();
    entities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return entities;
  }

  @override
  Future<List<CategoryTaskEntity>> getByTaskTemplateId(String taskTemplateId) async {
    final models = _localDataSource.getAllCategoryTasks();
    final filtered = models.where((ct) => ct.taskTemplateId == taskTemplateId).toList();
    return filtered.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CategoryTaskEntity> add({
    required String categoryId,
    required String taskTemplateId,
    required int sortOrder,
  }) async {
    final model = CategoryTaskModel(
      id: _uuid.v4(),
      categoryId: categoryId,
      taskTemplateId: taskTemplateId,
      sortOrder: sortOrder,
      addedAt: DateTime.now(),
    );
    await _localDataSource.saveCategoryTask(model);
    return model.toEntity();
  }

  @override
  Future<List<CategoryTaskEntity>> addMultiple({
    required String categoryId,
    required List<String> taskTemplateIds,
  }) async {
    final existing = await getByCategoryId(categoryId);
    int nextSortOrder = existing.isEmpty
        ? 0
        : existing.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1;

    final results = <CategoryTaskEntity>[];
    for (final templateId in taskTemplateIds) {
      final entity = await add(
        categoryId: categoryId,
        taskTemplateId: templateId,
        sortOrder: nextSortOrder++,
      );
      results.add(entity);
    }
    return results;
  }

  @override
  Future<void> delete(String id) async {
    await _localDataSource.deleteCategoryTask(id);
  }

  @override
  Future<void> deleteByCategoryId(String categoryId) async {
    await _localDataSource.deleteCategoryTasksByCategoryId(categoryId);
  }

  @override
  Future<void> deleteByTaskTemplateId(String taskTemplateId) async {
    await _localDataSource.deleteCategoryTasksByTemplateId(taskTemplateId);
  }

  @override
  Future<void> updateSortOrder(String id, int sortOrder) async {
    final model = _localDataSource.getCategoryTaskById(id);
    if (model != null) {
      final updated = CategoryTaskModel(
        id: model.id,
        categoryId: model.categoryId,
        taskTemplateId: model.taskTemplateId,
        sortOrder: sortOrder,
        addedAt: model.addedAt,
      );
      await _localDataSource.saveCategoryTask(updated);
    }
  }

  @override
  Future<void> reorder(String categoryId, List<String> orderedIds) async {
    final models = _localDataSource.getAllCategoryTasks();
    final categoryModels = models.where((ct) => ct.categoryId == categoryId).toList();

    final updatedModels = <CategoryTaskModel>[];
    for (int i = 0; i < orderedIds.length; i++) {
      final model = categoryModels.firstWhere(
        (ct) => ct.id == orderedIds[i],
        orElse: () => throw Exception('CategoryTask not found: ${orderedIds[i]}'),
      );
      updatedModels.add(CategoryTaskModel(
        id: model.id,
        categoryId: model.categoryId,
        taskTemplateId: model.taskTemplateId,
        sortOrder: i,
        addedAt: model.addedAt,
      ));
    }
    await _localDataSource.saveAllCategoryTasks(updatedModels);
  }

  @override
  Future<bool> exists({
    required String categoryId,
    required String taskTemplateId,
  }) async {
    final models = _localDataSource.getAllCategoryTasks();
    return models.any((ct) =>
        ct.categoryId == categoryId && ct.taskTemplateId == taskTemplateId);
  }
}

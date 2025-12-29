import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/category_model.dart';

/// 카테고리 저장소 구현체
class CategoryRepositoryImpl implements CategoryRepository {
  final LocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    final models = _localDataSource.getAllCategories();
    final entities = models.map((m) => m.toEntity()).toList();
    entities.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return entities;
  }

  @override
  Future<CategoryEntity?> getCategoryById(String id) async {
    final model = _localDataSource.getCategoryById(id);
    return model?.toEntity();
  }

  @override
  Future<bool> existsByName(String name, {String? excludeId}) async {
    final models = _localDataSource.getAllCategories();
    final lowerName = name.trim().toLowerCase();
    return models.any((c) =>
        c.name.trim().toLowerCase() == lowerName &&
        (excludeId == null || c.id != excludeId));
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await _localDataSource.saveCategory(model);
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await _localDataSource.saveCategory(model);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _localDataSource.deleteCategory(id);
  }

  @override
  Future<void> reorderCategories(List<CategoryEntity> categories) async {
    final models = categories
        .asMap()
        .entries
        .map((e) => CategoryModel.fromEntity(
              e.value.copyWith(sortOrder: e.key),
            ))
        .toList();
    await _localDataSource.saveAllCategories(models);
  }

  @override
  Future<int> getNextSortOrder() async {
    final models = _localDataSource.getAllCategories();
    if (models.isEmpty) return 0;
    final maxOrder = models.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }
}

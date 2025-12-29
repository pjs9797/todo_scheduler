import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

/// 모든 카테고리 조회 UseCase
class GetAllCategoriesUseCase {
  final CategoryRepository _repository;

  GetAllCategoriesUseCase(this._repository);

  Future<List<CategoryEntity>> call() {
    return _repository.getAllCategories();
  }
}

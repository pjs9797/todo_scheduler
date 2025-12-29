import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

/// 카테고리 순서 변경 UseCase
class ReorderCategoriesUseCase {
  final CategoryRepository _repository;

  ReorderCategoriesUseCase(this._repository);

  /// 카테고리 순서 변경
  /// [categories]: 새로운 순서로 정렬된 카테고리 목록
  Future<void> call(List<CategoryEntity> categories) async {
    // sortOrder 재할당 (0부터 시작)
    final reordered = categories.asMap().entries.map((e) {
      return e.value.copyWith(sortOrder: e.key);
    }).toList();

    await _repository.reorderCategories(reordered);
  }
}

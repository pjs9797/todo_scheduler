import '../entities/category_entity.dart';

/// 카테고리 저장소 인터페이스 (Domain Layer)
/// Data Layer에서 구현
abstract class CategoryRepository {
  /// 모든 카테고리 조회 (sortOrder 기준 정렬)
  Future<List<CategoryEntity>> getAllCategories();

  /// 카테고리 ID로 조회
  Future<CategoryEntity?> getCategoryById(String id);

  /// 카테고리 이름 중복 확인
  Future<bool> existsByName(String name, {String? excludeId});

  /// 카테고리 추가
  Future<void> addCategory(CategoryEntity category);

  /// 카테고리 수정
  Future<void> updateCategory(CategoryEntity category);

  /// 카테고리 삭제
  Future<void> deleteCategory(String id);

  /// 카테고리 순서 일괄 업데이트 (드래그 정렬용)
  Future<void> reorderCategories(List<CategoryEntity> categories);

  /// 다음 sortOrder 값 조회
  Future<int> getNextSortOrder();
}

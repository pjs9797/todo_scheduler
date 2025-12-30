import '../entities/category_task_entity.dart';

/// 카테고리-할일 연결 Repository 인터페이스
abstract class CategoryTaskRepository {
  /// 카테고리별 할일 연결 조회
  Future<List<CategoryTaskEntity>> getByCategoryId(String categoryId);

  /// 할일 템플릿이 사용된 카테고리 연결 조회
  Future<List<CategoryTaskEntity>> getByTaskTemplateId(String taskTemplateId);

  /// 카테고리에 할일 추가
  Future<CategoryTaskEntity> add({
    required String categoryId,
    required String taskTemplateId,
    required int sortOrder,
  });

  /// 카테고리에 여러 할일 추가
  Future<List<CategoryTaskEntity>> addMultiple({
    required String categoryId,
    required List<String> taskTemplateIds,
  });

  /// 카테고리에서 할일 제거
  Future<void> delete(String id);

  /// 카테고리의 모든 할일 제거
  Future<void> deleteByCategoryId(String categoryId);

  /// 할일 템플릿의 모든 연결 제거
  Future<void> deleteByTaskTemplateId(String taskTemplateId);

  /// 정렬 순서 업데이트
  Future<void> updateSortOrder(String id, int sortOrder);

  /// 카테고리 내 할일 순서 재정렬
  Future<void> reorder(String categoryId, List<String> orderedIds);

  /// 카테고리에 할일이 이미 있는지 확인
  Future<bool> exists({
    required String categoryId,
    required String taskTemplateId,
  });
}

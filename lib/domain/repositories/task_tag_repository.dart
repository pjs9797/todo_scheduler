import '../entities/task_tag_entity.dart';

/// 할일 태그 Repository 인터페이스
abstract class TaskTagRepository {
  /// 모든 태그 조회
  Future<List<TaskTagEntity>> getAll();

  /// ID로 태그 조회
  Future<TaskTagEntity?> getById(String id);

  /// 태그 추가
  Future<TaskTagEntity> add({
    required String name,
    required String colorHex,
  });

  /// 태그 수정
  Future<void> update(TaskTagEntity tag);

  /// 태그 삭제
  Future<void> delete(String id);

  /// 태그 순서 재정렬
  Future<void> reorder(List<String> orderedIds);

  /// 이름 중복 확인
  Future<bool> isNameDuplicate(String name, {String? excludeId});
}

import '../entities/task_template_entity.dart';

/// 할일 템플릿 Repository 인터페이스
abstract class TaskTemplateRepository {
  /// 모든 할일 템플릿 조회
  Future<List<TaskTemplateEntity>> getAll();

  /// ID로 할일 템플릿 조회
  Future<TaskTemplateEntity?> getById(String id);

  /// 즐겨찾기 할일 템플릿 조회
  Future<List<TaskTemplateEntity>> getFavorites();

  /// 태그로 할일 템플릿 조회
  Future<List<TaskTemplateEntity>> getByTagId(String tagId);

  /// 할일 템플릿 추가
  Future<TaskTemplateEntity> add({
    required String title,
    required int minutes,
    bool isFavorite = false,
    List<String> tagIds = const [],
  });

  /// 할일 템플릿 수정
  Future<void> update(TaskTemplateEntity template);

  /// 할일 템플릿 삭제
  Future<void> delete(String id);

  /// 즐겨찾기 토글
  Future<void> toggleFavorite(String id);

  /// 최근 사용일 업데이트
  Future<void> updateLastUsedAt(String id);

  /// 검색
  Future<List<TaskTemplateEntity>> search(String query);
}

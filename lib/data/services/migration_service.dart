import 'package:uuid/uuid.dart';
import '../datasources/local/local_data_source.dart';
import '../models/task_template_model.dart';
import '../models/category_task_model.dart';

/// 기존 Task → TaskTemplate 마이그레이션 서비스
class MigrationService {
  final LocalDataSource _localDataSource;
  final _uuid = const Uuid();

  MigrationService(this._localDataSource);

  /// 마이그레이션 필요 여부 확인
  bool needsMigration() {
    final existingTasks = _localDataSource.getAllTasks();
    final existingTemplates = _localDataSource.getAllTaskTemplates();

    // 기존 Task가 있고 TaskTemplate이 없으면 마이그레이션 필요
    return existingTasks.isNotEmpty && existingTemplates.isEmpty;
  }

  /// 마이그레이션 실행
  Future<MigrationResult> migrate() async {
    if (!needsMigration()) {
      return MigrationResult(
        success: true,
        migratedTasksCount: 0,
        migratedCategoryTasksCount: 0,
        message: '마이그레이션이 필요하지 않습니다.',
      );
    }

    try {
      final existingTasks = _localDataSource.getAllTasks();
      int migratedTemplates = 0;
      int migratedCategoryTasks = 0;

      // title+minutes 조합으로 그룹핑 (중복 방지)
      final taskGroups = <String, List<_TaskInfo>>{};

      for (final task in existingTasks) {
        final key = '${task.title}|${task.minutes}';
        taskGroups.putIfAbsent(key, () => []);
        taskGroups[key]!.add(_TaskInfo(
          categoryId: task.categoryId,
          sortOrder: task.sortOrder,
          createdAt: task.createdAt,
        ));
      }

      // 각 고유 할일에 대해 TaskTemplate 생성
      for (final entry in taskGroups.entries) {
        final parts = entry.key.split('|');
        final title = parts[0];
        final minutes = int.parse(parts[1]);
        final taskInfoList = entry.value;

        // TaskTemplate 생성
        final templateId = _uuid.v4();
        final earliestCreatedAt = taskInfoList
            .map((t) => t.createdAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);

        final template = TaskTemplateModel(
          id: templateId,
          title: title,
          minutes: minutes,
          isFavorite: false,
          tagIds: [],
          createdAt: earliestCreatedAt,
          lastUsedAt: DateTime.now(),
        );

        await _localDataSource.saveTaskTemplate(template);
        migratedTemplates++;

        // 각 카테고리에 대해 CategoryTask 생성
        for (final taskInfo in taskInfoList) {
          if (taskInfo.categoryId != null) {
            final categoryTask = CategoryTaskModel(
              id: _uuid.v4(),
              categoryId: taskInfo.categoryId!,
              taskTemplateId: templateId,
              sortOrder: taskInfo.sortOrder,
              addedAt: taskInfo.createdAt,
            );

            await _localDataSource.saveCategoryTask(categoryTask);
            migratedCategoryTasks++;
          }
        }
      }

      return MigrationResult(
        success: true,
        migratedTasksCount: migratedTemplates,
        migratedCategoryTasksCount: migratedCategoryTasks,
        message: '마이그레이션 완료: $migratedTemplates개 할일 템플릿, $migratedCategoryTasks개 카테고리 연결',
      );
    } catch (e) {
      return MigrationResult(
        success: false,
        migratedTasksCount: 0,
        migratedCategoryTasksCount: 0,
        message: '마이그레이션 실패: $e',
      );
    }
  }
}

/// 마이그레이션을 위한 임시 Task 정보
class _TaskInfo {
  final String? categoryId;
  final int sortOrder;
  final DateTime createdAt;

  _TaskInfo({
    required this.categoryId,
    required this.sortOrder,
    required this.createdAt,
  });
}

/// 마이그레이션 결과
class MigrationResult {
  final bool success;
  final int migratedTasksCount;
  final int migratedCategoryTasksCount;
  final String message;

  MigrationResult({
    required this.success,
    required this.migratedTasksCount,
    required this.migratedCategoryTasksCount,
    required this.message,
  });

  @override
  String toString() => message;
}

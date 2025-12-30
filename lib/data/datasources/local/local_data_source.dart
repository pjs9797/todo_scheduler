import 'package:hive_flutter/hive_flutter.dart';
import '../../models/category_model.dart';
import '../../models/task_model.dart';
import '../../models/task_template_model.dart';
import '../../models/category_task_model.dart';
import '../../models/task_tag_model.dart';

/// 로컬 데이터 소스 (Hive)
class LocalDataSource {
  static const String _categoryBoxName = 'categories';
  static const String _taskBoxName = 'tasks';
  static const String _taskTemplateBoxName = 'task_templates';
  static const String _categoryTaskBoxName = 'category_tasks';
  static const String _taskTagBoxName = 'task_tags';

  late Box<CategoryModel> _categoryBox;
  late Box<TaskModel> _taskBox;
  late Box<TaskTemplateModel> _taskTemplateBox;
  late Box<CategoryTaskModel> _categoryTaskBox;
  late Box<TaskTagModel> _taskTagBox;

  /// 초기화 (앱 시작 시 호출)
  Future<void> init() async {
    // 어댑터 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TaskTemplateModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CategoryTaskModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TaskTagModelAdapter());
    }

    // 박스 열기
    _categoryBox = await Hive.openBox<CategoryModel>(_categoryBoxName);
    _taskBox = await Hive.openBox<TaskModel>(_taskBoxName);
    _taskTemplateBox = await Hive.openBox<TaskTemplateModel>(_taskTemplateBoxName);
    _categoryTaskBox = await Hive.openBox<CategoryTaskModel>(_categoryTaskBoxName);
    _taskTagBox = await Hive.openBox<TaskTagModel>(_taskTagBoxName);
  }

  // ==================== Category ====================

  /// 모든 카테고리 조회
  List<CategoryModel> getAllCategories() {
    return _categoryBox.values.toList();
  }

  /// 카테고리 ID로 조회
  CategoryModel? getCategoryById(String id) {
    try {
      return _categoryBox.values.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 카테고리 추가/수정
  Future<void> saveCategory(CategoryModel category) async {
    await _categoryBox.put(category.id, category);
  }

  /// 카테고리 삭제
  Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
  }

  /// 카테고리 일괄 저장 (순서 변경용)
  Future<void> saveAllCategories(List<CategoryModel> categories) async {
    final map = {for (var c in categories) c.id: c};
    await _categoryBox.putAll(map);
  }

  // ==================== Task ====================

  /// 모든 할 일 조회
  List<TaskModel> getAllTasks() {
    return _taskBox.values.toList();
  }

  /// 할 일 ID로 조회
  TaskModel? getTaskById(String id) {
    try {
      return _taskBox.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 할 일 추가/수정
  Future<void> saveTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
  }

  /// 할 일 삭제
  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  /// 할 일 일괄 저장 (순서 변경용)
  Future<void> saveAllTasks(List<TaskModel> tasks) async {
    final map = {for (var t in tasks) t.id: t};
    await _taskBox.putAll(map);
  }

  // ==================== TaskTemplate ====================

  /// 모든 할일 템플릿 조회
  List<TaskTemplateModel> getAllTaskTemplates() {
    return _taskTemplateBox.values.toList();
  }

  /// 할일 템플릿 ID로 조회
  TaskTemplateModel? getTaskTemplateById(String id) {
    try {
      return _taskTemplateBox.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 할일 템플릿 저장
  Future<void> saveTaskTemplate(TaskTemplateModel template) async {
    await _taskTemplateBox.put(template.id, template);
  }

  /// 할일 템플릿 삭제
  Future<void> deleteTaskTemplate(String id) async {
    await _taskTemplateBox.delete(id);
  }

  /// 할일 템플릿 일괄 저장
  Future<void> saveAllTaskTemplates(List<TaskTemplateModel> templates) async {
    final map = {for (var t in templates) t.id: t};
    await _taskTemplateBox.putAll(map);
  }

  // ==================== CategoryTask ====================

  /// 모든 카테고리-할일 연결 조회
  List<CategoryTaskModel> getAllCategoryTasks() {
    return _categoryTaskBox.values.toList();
  }

  /// 카테고리-할일 연결 ID로 조회
  CategoryTaskModel? getCategoryTaskById(String id) {
    try {
      return _categoryTaskBox.values.firstWhere((ct) => ct.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 카테고리-할일 연결 저장
  Future<void> saveCategoryTask(CategoryTaskModel categoryTask) async {
    await _categoryTaskBox.put(categoryTask.id, categoryTask);
  }

  /// 카테고리-할일 연결 삭제
  Future<void> deleteCategoryTask(String id) async {
    await _categoryTaskBox.delete(id);
  }

  /// 카테고리-할일 연결 일괄 저장
  Future<void> saveAllCategoryTasks(List<CategoryTaskModel> categoryTasks) async {
    final map = {for (var ct in categoryTasks) ct.id: ct};
    await _categoryTaskBox.putAll(map);
  }

  /// 카테고리별 연결 삭제
  Future<void> deleteCategoryTasksByCategoryId(String categoryId) async {
    final toDelete = _categoryTaskBox.values
        .where((ct) => ct.categoryId == categoryId)
        .map((ct) => ct.id)
        .toList();
    for (final id in toDelete) {
      await _categoryTaskBox.delete(id);
    }
  }

  /// 템플릿별 연결 삭제
  Future<void> deleteCategoryTasksByTemplateId(String taskTemplateId) async {
    final toDelete = _categoryTaskBox.values
        .where((ct) => ct.taskTemplateId == taskTemplateId)
        .map((ct) => ct.id)
        .toList();
    for (final id in toDelete) {
      await _categoryTaskBox.delete(id);
    }
  }

  // ==================== TaskTag ====================

  /// 모든 태그 조회
  List<TaskTagModel> getAllTaskTags() {
    return _taskTagBox.values.toList();
  }

  /// 태그 ID로 조회
  TaskTagModel? getTaskTagById(String id) {
    try {
      return _taskTagBox.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 태그 저장
  Future<void> saveTaskTag(TaskTagModel tag) async {
    await _taskTagBox.put(tag.id, tag);
  }

  /// 태그 삭제
  Future<void> deleteTaskTag(String id) async {
    await _taskTagBox.delete(id);
  }

  /// 태그 일괄 저장
  Future<void> saveAllTaskTags(List<TaskTagModel> tags) async {
    final map = {for (var t in tags) t.id: t};
    await _taskTagBox.putAll(map);
  }

  /// 박스 닫기 (앱 종료 시)
  Future<void> close() async {
    await _categoryBox.close();
    await _taskBox.close();
    await _taskTemplateBox.close();
    await _categoryTaskBox.close();
    await _taskTagBox.close();
  }
}

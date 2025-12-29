import 'package:hive_flutter/hive_flutter.dart';
import '../../models/category_model.dart';
import '../../models/task_model.dart';

/// 로컬 데이터 소스 (Hive)
class LocalDataSource {
  static const String _categoryBoxName = 'categories';
  static const String _taskBoxName = 'tasks';

  late Box<CategoryModel> _categoryBox;
  late Box<TaskModel> _taskBox;

  /// 초기화 (앱 시작 시 호출)
  Future<void> init() async {
    // 어댑터 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskModelAdapter());
    }

    // 박스 열기
    _categoryBox = await Hive.openBox<CategoryModel>(_categoryBoxName);
    _taskBox = await Hive.openBox<TaskModel>(_taskBoxName);
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

  /// 박스 닫기 (앱 종료 시)
  Future<void> close() async {
    await _categoryBox.close();
    await _taskBox.close();
  }
}

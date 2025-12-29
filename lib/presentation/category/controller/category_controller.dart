import 'package:get/get.dart';
import '../../../domain/domain.dart';

/// 카테고리 관리 컨트롤러
class CategoryController extends GetxController {
  // UseCases
  final GetAllCategoriesUseCase _getAllCategoriesUseCase;
  final AddCategoryUseCase _addCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;
  final ReorderCategoriesUseCase _reorderCategoriesUseCase;

  CategoryController({
    required GetAllCategoriesUseCase getAllCategoriesUseCase,
    required AddCategoryUseCase addCategoryUseCase,
    required UpdateCategoryUseCase updateCategoryUseCase,
    required DeleteCategoryUseCase deleteCategoryUseCase,
    required ReorderCategoriesUseCase reorderCategoriesUseCase,
  })  : _getAllCategoriesUseCase = getAllCategoriesUseCase,
        _addCategoryUseCase = addCategoryUseCase,
        _updateCategoryUseCase = updateCategoryUseCase,
        _deleteCategoryUseCase = deleteCategoryUseCase,
        _reorderCategoriesUseCase = reorderCategoriesUseCase;

  // ==================== State ====================

  /// 카테고리 목록
  final categories = <CategoryEntity>[].obs;

  /// 로딩 상태
  final isLoading = false.obs;

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  // ==================== Data Loading ====================

  /// 카테고리 로드
  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      categories.value = await _getAllCategoriesUseCase();
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Category Actions ====================

  /// 카테고리 추가
  Future<void> addCategory(String name, String colorHex) async {
    await _addCategoryUseCase(name: name, colorHex: colorHex);
    await loadCategories();
  }

  /// 카테고리 수정
  Future<void> updateCategory({
    required CategoryEntity category,
    required String name,
    required String colorHex,
  }) async {
    await _updateCategoryUseCase(
      category: category,
      name: name,
      colorHex: colorHex,
    );
    await loadCategories();
  }

  /// 카테고리 삭제
  Future<void> deleteCategory(String categoryId) async {
    await _deleteCategoryUseCase(categoryId);
    await loadCategories();
  }

  /// 카테고리 이름 중복 체크
  bool isDuplicateName(String name, {String? excludeId}) {
    return categories.any((c) =>
        c.name.toLowerCase() == name.toLowerCase() && c.id != excludeId);
  }

  /// 카테고리 순서 변경
  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    // 순서 조정
    if (newIndex > oldIndex) newIndex--;
    final items = List<CategoryEntity>.from(categories);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // UI 즉시 업데이트
    categories.value = items;

    // DB 저장
    await _reorderCategoriesUseCase(items);
  }
}

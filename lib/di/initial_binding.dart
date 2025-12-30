import 'package:get/get.dart';
import '../data/data.dart';
import '../domain/domain.dart';
import '../presentation/category/controller/category_controller.dart';
import '../presentation/home/controller/home_controller.dart';
import '../presentation/task_library/controller/task_library_controller.dart';

/// 앱 시작 시 의존성 주입
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // ==================== Data Layer ====================

    // LocalDataSource는 main.dart에서 초기화 후 등록됨
    // Get.put(localDataSource) in main.dart

    // Repositories
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepositoryImpl(Get.find<LocalDataSource>()),
      fenix: true,
    );
    Get.lazyPut<TaskRepository>(
      () => TaskRepositoryImpl(Get.find<LocalDataSource>()),
      fenix: true,
    );
    Get.lazyPut<TaskTemplateRepository>(
      () => TaskTemplateRepositoryImpl(Get.find<LocalDataSource>()),
      fenix: true,
    );
    Get.lazyPut<CategoryTaskRepository>(
      () => CategoryTaskRepositoryImpl(Get.find<LocalDataSource>()),
      fenix: true,
    );
    Get.lazyPut<TaskTagRepository>(
      () => TaskTagRepositoryImpl(Get.find<LocalDataSource>()),
      fenix: true,
    );

    // ==================== Domain Layer ====================

    // Category UseCases
    Get.lazyPut(() => GetAllCategoriesUseCase(Get.find<CategoryRepository>()), fenix: true);
    Get.lazyPut(() => AddCategoryUseCase(Get.find<CategoryRepository>()), fenix: true);
    Get.lazyPut(() => UpdateCategoryUseCase(Get.find<CategoryRepository>()), fenix: true);
    Get.lazyPut(() => DeleteCategoryUseCase(
          Get.find<CategoryRepository>(),
          Get.find<TaskRepository>(),
        ), fenix: true);
    Get.lazyPut(() => ReorderCategoriesUseCase(Get.find<CategoryRepository>()), fenix: true);

    // Task UseCases (legacy - 마이그레이션 후 제거 예정)
    Get.lazyPut(() => CalculateStartTimeUseCase(), fenix: true);

    // ==================== Presentation Layer ====================

    // Controllers
    Get.lazyPut(() => HomeController(
          getAllCategoriesUseCase: Get.find<GetAllCategoriesUseCase>(),
          updateCategoryUseCase: Get.find<UpdateCategoryUseCase>(),
          calculateStartTimeUseCase: Get.find<CalculateStartTimeUseCase>(),
          templateRepository: Get.find<TaskTemplateRepository>(),
          categoryTaskRepository: Get.find<CategoryTaskRepository>(),
        ));

    Get.lazyPut(
      () => CategoryController(
        getAllCategoriesUseCase: Get.find<GetAllCategoriesUseCase>(),
        addCategoryUseCase: Get.find<AddCategoryUseCase>(),
        updateCategoryUseCase: Get.find<UpdateCategoryUseCase>(),
        deleteCategoryUseCase: Get.find<DeleteCategoryUseCase>(),
        reorderCategoriesUseCase: Get.find<ReorderCategoriesUseCase>(),
      ),
      fenix: true,
    );

    Get.lazyPut(
      () => TaskLibraryController(
        Get.find<TaskTemplateRepository>(),
        Get.find<CategoryTaskRepository>(),
      ),
      fenix: true,
    );
  }
}

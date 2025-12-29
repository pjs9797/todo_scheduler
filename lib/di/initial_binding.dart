import 'package:get/get.dart';
import '../data/data.dart';
import '../domain/domain.dart';
import '../presentation/home/controller/home_controller.dart';

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

    // ==================== Domain Layer ====================

    // Category UseCases
    Get.lazyPut(() => GetAllCategoriesUseCase(Get.find<CategoryRepository>()));
    Get.lazyPut(() => AddCategoryUseCase(Get.find<CategoryRepository>()));
    Get.lazyPut(() => UpdateCategoryUseCase(Get.find<CategoryRepository>()));
    Get.lazyPut(() => DeleteCategoryUseCase(
          Get.find<CategoryRepository>(),
          Get.find<TaskRepository>(),
        ));
    Get.lazyPut(() => ReorderCategoriesUseCase(Get.find<CategoryRepository>()));

    // Task UseCases
    Get.lazyPut(() => GetTasksByFilterUseCase(Get.find<TaskRepository>()));
    Get.lazyPut(() => AddTaskUseCase(Get.find<TaskRepository>()));
    Get.lazyPut(() => UpdateTaskUseCase(Get.find<TaskRepository>()));
    Get.lazyPut(() => DeleteTaskUseCase(Get.find<TaskRepository>()));
    Get.lazyPut(() => ReorderTasksUseCase(Get.find<TaskRepository>()));
    Get.lazyPut(() => CalculateStartTimeUseCase());

    // ==================== Presentation Layer ====================

    // Controllers
    Get.lazyPut(() => HomeController(
          getAllCategoriesUseCase: Get.find<GetAllCategoriesUseCase>(),
          getTasksByFilterUseCase: Get.find<GetTasksByFilterUseCase>(),
          deleteTaskUseCase: Get.find<DeleteTaskUseCase>(),
          calculateStartTimeUseCase: Get.find<CalculateStartTimeUseCase>(),
        ));
  }
}

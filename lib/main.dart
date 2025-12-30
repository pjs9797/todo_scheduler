import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/core.dart';
import 'data/data.dart';
import 'di/bindings.dart';
import 'presentation/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 상태바 스타일 설정 (어두운 아이콘)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  // Hive 초기화
  await Hive.initFlutter();

  // LocalDataSource 초기화 (Bindings보다 먼저 등록 필요)
  final localDataSource = LocalDataSource();
  await localDataSource.init();
  Get.put(localDataSource);

  // 마이그레이션 실행 (기존 Task → TaskTemplate)
  final migrationService = MigrationService(localDataSource);
  if (migrationService.needsMigration()) {
    final result = await migrationService.migrate();
    debugPrint('[Migration] ${result.message}');
  }

  runApp(const TodoSchedulerApp());
}

class TodoSchedulerApp extends StatelessWidget {
  const TodoSchedulerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: InitialBinding(),
      home: const HomeScreen(),
    );
  }
}

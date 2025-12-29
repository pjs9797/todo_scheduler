import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/core.dart';
import 'data/data.dart';
import 'di/bindings.dart';
import 'presentation/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // LocalDataSource 초기화 (Bindings보다 먼저 등록 필요)
  final localDataSource = LocalDataSource();
  await localDataSource.init();
  Get.put(localDataSource);

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

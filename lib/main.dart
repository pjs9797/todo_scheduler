import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/core.dart';
import 'data/data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // LocalDataSource 초기화
  final localDataSource = LocalDataSource();
  await localDataSource.init();

  // GetX에 등록 (6단계에서 Bindings로 이동 예정)
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
      home: const PlaceholderHomePage(),
    );
  }
}

/// 임시 홈 페이지 (7단계에서 실제 화면으로 교체 예정)
class PlaceholderHomePage extends StatelessWidget {
  const PlaceholderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage_outlined,
              size: 64,
              color: AppColors.slate400,
            ),
            const SizedBox(height: 16),
            const Text(
              '4단계 완료!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data 레이어 (Hive DB + Repository) 구현 완료',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.slate500,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.snackbar(
            '테스트',
            'GetX 스낵바가 정상 동작합니다!',
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 16,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

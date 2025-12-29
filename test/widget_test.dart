import 'package:flutter_test/flutter_test.dart';
import 'package:todo_scheduler/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoSchedulerApp());

    // 앱 타이틀 확인
    expect(find.text('오늘의 작업'), findsOneWidget);
  });
}

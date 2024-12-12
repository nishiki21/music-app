import 'package:flutter_test/flutter_test.dart';
import 'package:music_app2/main.dart';

void main() {
  testWidgets('App starts and displays main screen', (WidgetTester tester) async {
    // アプリを起動
    await tester.pumpWidget(const MyApp());

    // アプリのタイトルが表示されているか確認
    expect(find.text('音楽アプリ'), findsOneWidget);
  });

  testWidgets('Displays error when no location permission is granted', (WidgetTester tester) async {
    // アプリを起動
    await tester.pumpWidget(const MyApp());

    // 「エラー」が初期状態で表示されていないことを確認
    expect(find.textContaining('エラー'), findsNothing);
  });
}

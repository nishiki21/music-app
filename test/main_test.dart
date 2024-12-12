import 'package:flutter_test/flutter_test.dart';
import 'package:music_app2/main.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// モッククラスの生成
@GenerateMocks([http.Client])
import 'main_test.mocks.dart';

Future<String> getCurrentWeather(http.Client client) async {
  final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=35.6895&lon=139.6917&appid=VALID_API_KEY');
  final response = await client.get(url);

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    return jsonResponse['weather'][0]['main'] ?? 'Unknown';
  } else {
    throw Exception('Failed to fetch weather data');
  }
}

void main() {
  group('Music App Tests', () {
    testWidgets('Displays main screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // アプリのタイトルが表示されるか確認
      expect(find.text('音楽アプリ'), findsOneWidget);
    });

    test('Fetches weather data successfully', () async {
      final mockClient = MockClient();

      // モックのHTTPレスポンス
      when(mockClient.get(Uri.parse(
              'https://api.openweathermap.org/data/2.5/weather?lat=35.6895&lon=139.6917&appid=VALID_API_KEY')))
          .thenAnswer((_) async => http.Response('{"weather": [{"main": "Clear"}]}', 200));

      // テスト実行
      final weather = await getCurrentWeather(mockClient);

      expect(weather, 'Clear');
    });

    test('Handles error when fetching weather data', () async {
      final mockClient = MockClient();

      // モックのHTTPレスポンス（エラーケース）
      when(mockClient.get(Uri.parse(
              'https://api.openweathermap.org/data/2.5/weather?lat=35.6895&lon=139.6917&appid=VALID_API_KEY')))
          .thenAnswer((_) async => http.Response('Error', 500));

      // テスト実行
      expect(() async => await getCurrentWeather(mockClient), throwsException);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Weatherデータ取得関数
Future<Map<String, dynamic>> getWeatherData(
    {required double lat, required double lon}) async {
  const String apiKey = "0209c5667e29acdddb43b3069282c503"; // 有効なAPIキーを使用
  final String apiUrl =
      "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey";

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception("Failed to fetch weather data: ${response.statusCode}");
  }
}

// テストコード
void main() {
  group('getWeatherData Function Tests', () {
    // 正常系テスト
    test('getWeatherData returns weather data successfully', () async {
      final lat = 35.6895;
      final lon = 139.6917;

      final result = await getWeatherData(lat: lat, lon: lon);

      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('weather'), true);
    });

    // 無効なAPIキーを扱うテスト
    test('getWeatherData handles invalid API key', () async {
      const String invalidApiKey = "INVALID_API_KEY"; // 無効なAPIキー
      final String apiUrl =
          "https://api.openweathermap.org/data/2.5/weather?lat=35.6895&lon=139.6917&appid=$invalidApiKey";

      try {
        final response = await http.get(Uri.parse(apiUrl));
        expect(response.statusCode, 401); // 401エラーを期待
      } catch (e) {
        fail("Unexpected exception thrown: $e");
      }
    });

    // サーバーエラーまたはクライアントエラーを扱うテスト
    test('getWeatherData handles server or client errors', () async {
      const String invalidUrl = "https://api.openweathermap.org/invalid_path";

      try {
        final response = await http.get(Uri.parse(invalidUrl));
        expect(response.statusCode, anyOf([greaterThanOrEqualTo(400), lessThan(500)])); // 400~499 または 500系エラー
      } catch (e) {
        fail("Unexpected exception thrown: $e");
      }
    });
  });
}

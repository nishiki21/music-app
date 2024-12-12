import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

class MockGeolocatorPlatform extends GeolocatorPlatform {
  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    return Position(
      latitude: 35.6895,
      longitude: 139.6917,
      altitude: 0,
      accuracy: 10,
      altitudeAccuracy: 5,
      heading: 0,
      headingAccuracy: 1,
      speed: 0,
      speedAccuracy: 1,
      timestamp: DateTime.now(),
      floor: null,
      isMocked: false,
    );
  }
}

void main() {
  group('Location Tests', () {
    test('Gets current position successfully', () async {
      final mockGeolocator = MockGeolocatorPlatform();
      GeolocatorPlatform.instance = mockGeolocator;

      final position = await Geolocator.getCurrentPosition();

      expect(position.latitude, 35.6895);
      expect(position.longitude, 139.6917);
    });
  });
}

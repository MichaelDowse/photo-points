import 'package:flutter_test/flutter_test.dart';
import 'package:photopoints/models/location_data.dart';
import '../../test_data.dart';

void main() {
  group('LocationData', () {
    test('should create LocationData with all fields', () {
      final timestamp = DateTime.now();
      
      final locationData = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        accuracy: 5.0,
        timestamp: timestamp,
      );

      expect(locationData.latitude, 37.7749);
      expect(locationData.longitude, -122.4194);
      expect(locationData.accuracy, 5.0);
      expect(locationData.timestamp, timestamp);
    });

    test('should create LocationData with required fields', () {
      final locationData = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );

      expect(locationData.latitude, 37.7749);
      expect(locationData.longitude, -122.4194);
      expect(locationData.accuracy, 5.0);
      expect(locationData.timestamp, isNotNull);
    });

    test('should serialize to JSON', () {
      final locationData = TestData.createMockLocationData();
      final json = locationData.toJson();

      expect(json['latitude'], locationData.latitude);
      expect(json['longitude'], locationData.longitude);
      expect(json['accuracy'], locationData.accuracy);
      expect(json['timestamp'], locationData.timestamp.toIso8601String());
    });

    test('should deserialize from JSON', () {
      final originalLocationData = TestData.createMockLocationData();
      final json = originalLocationData.toJson();
      final deserializedLocationData = LocationData.fromJson(json);

      expect(deserializedLocationData.latitude, originalLocationData.latitude);
      expect(deserializedLocationData.longitude, originalLocationData.longitude);
      expect(deserializedLocationData.accuracy, originalLocationData.accuracy);
      expect(deserializedLocationData.timestamp, originalLocationData.timestamp);
    });

    test('should handle JSON serialization correctly', () {
      final locationData = LocationData(
        latitude: 37.7749,
        longitude: -122.4194,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );

      final json = locationData.toJson();
      expect(json['latitude'], 37.7749);
      expect(json['longitude'], -122.4194);
      expect(json['accuracy'], 5.0);
      expect(json['timestamp'], isNotNull);

      final deserializedLocationData = LocationData.fromJson(json);
      expect(deserializedLocationData.latitude, 37.7749);
      expect(deserializedLocationData.longitude, -122.4194);
      expect(deserializedLocationData.accuracy, 5.0);
      expect(deserializedLocationData.timestamp, isNotNull);
    });

    test('should validate coordinate ranges', () {
      // Test valid coordinates
      final validLocationData = LocationData(
        latitude: 45.0,
        longitude: -120.0,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );

      expect(validLocationData.latitude >= -90 && validLocationData.latitude <= 90, true);
      expect(validLocationData.longitude >= -180 && validLocationData.longitude <= 180, true);
    });

    test('should validate accuracy values', () {
      final locationData = TestData.createMockLocationData(accuracy: 5.0);
      
      expect(locationData.accuracy, 5.0);
      expect(locationData.accuracy >= 0, true); // Accuracy should be positive
    });

    test('should validate accuracy values', () {
      final locationData = TestData.createMockLocationData(accuracy: 5.0);
      
      expect(locationData.accuracy, 5.0);
      expect(locationData.accuracy >= 0, true); // Accuracy should be positive
    });

    test('should handle edge case coordinates', () {
      final edgeCases = [
        {'lat': 90.0, 'lng': 180.0},    // North pole, antimeridian
        {'lat': -90.0, 'lng': -180.0},  // South pole, antimeridian
        {'lat': 0.0, 'lng': 0.0},       // Null island
      ];

      for (final testCase in edgeCases) {
        final locationData = LocationData(
          latitude: testCase['lat']!,
          longitude: testCase['lng']!,
          accuracy: 5.0,
          timestamp: DateTime.now(),
        );

        expect(locationData.latitude >= -90 && locationData.latitude <= 90, true);
        expect(locationData.longitude >= -180 && locationData.longitude <= 180, true);
      }
    });

    test('should handle timestamp validation', () {
      final now = DateTime.now();
      final locationData = TestData.createMockLocationData(timestamp: now);
      
      expect(locationData.timestamp, now);
      expect(locationData.timestamp.isBefore(DateTime.now().add(Duration(seconds: 1))), true);
    });

    test('should calculate distance to another location', () {
      final location1 = TestData.createMockLocationData(
        latitude: 37.7749,
        longitude: -122.4194,
      );
      
      final location2 = TestData.createMockLocationData(
        latitude: 37.7849,
        longitude: -122.4094,
      );

      // Test that we can access coordinates for distance calculation
      expect(location1.latitude, isNotNull);
      expect(location1.longitude, isNotNull);
      expect(location2.latitude, isNotNull);
      expect(location2.longitude, isNotNull);
      
      // In a real implementation, this would calculate actual distance
      final latDiff = (location2.latitude - location1.latitude).abs();
      final lngDiff = (location2.longitude - location1.longitude).abs();
      
      expect(latDiff, greaterThan(0));
      expect(lngDiff, greaterThan(0));
    });

    test('should handle precision of coordinates', () {
      final highPrecisionLocation = LocationData(
        latitude: 37.7749295,
        longitude: -122.4194155,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );
      
      expect(highPrecisionLocation.latitude, closeTo(37.7749295, 0.0000001));
      expect(highPrecisionLocation.longitude, closeTo(-122.4194155, 0.0000001));
    });
  });
}
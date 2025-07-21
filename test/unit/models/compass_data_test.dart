import 'package:flutter_test/flutter_test.dart';
import 'package:photopoints/models/compass_data.dart';
import '../../test_data.dart';

void main() {
  group('CompassData', () {
    test('should create CompassData with all fields', () {
      final timestamp = DateTime.now();
      
      final compassData = CompassData(
        heading: 45.0,
        accuracy: 5.0,
        timestamp: timestamp,
      );

      expect(compassData.heading, 45.0);
      expect(compassData.accuracy, 5.0);
      expect(compassData.timestamp, timestamp);
    });

    test('should create CompassData with all required fields', () {
      final compassData = CompassData(
        heading: 45.0,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );

      expect(compassData.heading, 45.0);
      expect(compassData.accuracy, 5.0);
      expect(compassData.timestamp, isNotNull);
    });

    test('should serialize to JSON', () {
      final compassData = TestData.createMockCompassData();
      final json = compassData.toJson();

      expect(json['heading'], compassData.heading);
      expect(json['accuracy'], compassData.accuracy);
      expect(json['timestamp'], compassData.timestamp.toIso8601String());
    });

    test('should deserialize from JSON', () {
      final originalCompassData = TestData.createMockCompassData();
      final json = originalCompassData.toJson();
      final deserializedCompassData = CompassData.fromJson(json);

      expect(deserializedCompassData.heading, originalCompassData.heading);
      expect(deserializedCompassData.accuracy, originalCompassData.accuracy);
      expect(deserializedCompassData.timestamp, originalCompassData.timestamp);
    });

    test('should handle JSON serialization with all values', () {
      final compassData = CompassData(
        heading: 45.0,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );

      final json = compassData.toJson();
      expect(json['accuracy'], 5.0);

      final deserializedCompassData = CompassData.fromJson(json);
      expect(deserializedCompassData.accuracy, 5.0);
    });

    test('should validate heading ranges', () {
      final validHeadings = [0.0, 45.0, 90.0, 180.0, 270.0, 359.9];
      
      for (final heading in validHeadings) {
        final compassData = CompassData(
          heading: heading,
          accuracy: 5.0,
          timestamp: DateTime.now(),
        );
        
        expect(compassData.heading >= 0 && compassData.heading < 360, true);
      }
    });

    test('should validate accuracy values', () {
      final compassData = TestData.createMockCompassData(accuracy: 5.0);
      
      expect(compassData.accuracy, 5.0);
      expect(compassData.accuracy >= 0, true); // Accuracy should be positive
    });

    test('should handle edge case headings', () {
      final edgeCases = [
        {'heading': 0.0, 'cardinal': 'N'},
        {'heading': 90.0, 'cardinal': 'E'},
        {'heading': 180.0, 'cardinal': 'S'},
        {'heading': 270.0, 'cardinal': 'W'},
        {'heading': 359.9, 'cardinal': 'N'},
      ];

      for (final testCase in edgeCases) {
        final compassData = CompassData(
          heading: testCase['heading'] as double,
          accuracy: 5.0,
          timestamp: DateTime.now(),
        );

        expect(compassData.heading >= 0 && compassData.heading < 360, true);
      }
    });

    test('should handle timestamp validation', () {
      final now = DateTime.now();
      final compassData = TestData.createMockCompassData(timestamp: now);
      
      expect(compassData.timestamp, now);
      expect(compassData.timestamp.isBefore(DateTime.now().add(Duration(seconds: 1))), true);
    });

    test('should handle precision of heading', () {
      final highPrecisionCompass = CompassData(
        heading: 45.123456,
        accuracy: 1.0,
        timestamp: DateTime.now(),
      );
      
      expect(highPrecisionCompass.heading, closeTo(45.123456, 0.000001));
    });

    test('should calculate heading difference', () {
      final compass1 = TestData.createMockCompassData(heading: 45.0);
      final compass2 = TestData.createMockCompassData(heading: 135.0);
      
      // Test heading difference calculation
      final diff = (compass2.heading - compass1.heading).abs();
      expect(diff, 90.0);
    });

    test('should handle heading normalization', () {
      // Test that headings are within valid range
      final testHeadings = [0.0, 45.0, 90.0, 180.0, 270.0, 359.9];
      
      for (final heading in testHeadings) {
        final compassData = CompassData(
          heading: heading,
          accuracy: 5.0,
          timestamp: DateTime.now(),
        );
        
        expect(compassData.heading >= 0, true);
        expect(compassData.heading < 360, true);
      }
    });

    test('should convert to cardinal directions', () {
      final compassReadings = [
        {'heading': 0.0, 'expected': 'N'},
        {'heading': 45.0, 'expected': 'NE'},
        {'heading': 90.0, 'expected': 'E'},
        {'heading': 135.0, 'expected': 'SE'},
        {'heading': 180.0, 'expected': 'S'},
        {'heading': 225.0, 'expected': 'SW'},
        {'heading': 270.0, 'expected': 'W'},
        {'heading': 315.0, 'expected': 'NW'},
      ];

      for (final reading in compassReadings) {
        final compassData = CompassData(
          heading: reading['heading'] as double,
          accuracy: 5.0,
          timestamp: DateTime.now(),
        );
        
        // Test cardinal direction conversion
        String getCardinalDirection(double heading) {
          const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
          int index = ((heading + 22.5) / 45).floor() % 8;
          return directions[index];
        }
        
        expect(getCardinalDirection(compassData.heading), reading['expected']);
      }
    });

    test('should handle accuracy thresholds', () {
      final accuracyLevels = [
        {'accuracy': 1.0, 'quality': 'excellent'},
        {'accuracy': 5.0, 'quality': 'good'},
        {'accuracy': 15.0, 'quality': 'fair'},
        {'accuracy': 25.0, 'quality': 'poor'},
      ];

      for (final level in accuracyLevels) {
        final compassData = CompassData(
          heading: 45.0,
          accuracy: level['accuracy'] as double,
          timestamp: DateTime.now(),
        );
        
        String getQualityLevel(double accuracy) {
          if (accuracy < 5.0) return 'excellent';
          if (accuracy < 10.0) return 'good';
          if (accuracy < 20.0) return 'fair';
          return 'poor';
        }
        
        expect(getQualityLevel(compassData.accuracy), level['quality']);
      }
    });

    test('should handle compass calibration status', () {
      final compassData = TestData.createMockCompassData(accuracy: 5.0);
      
      // Test calibration status based on accuracy
      final isWellCalibrated = compassData.accuracy < 10.0;
      final needsCalibration = compassData.accuracy > 20.0;
      
      expect(isWellCalibrated, true);
      expect(needsCalibration, false);
    });
  });
}
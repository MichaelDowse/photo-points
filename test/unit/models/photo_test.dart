import 'package:flutter_test/flutter_test.dart';
import 'package:photopoints/models/photo.dart';
import '../../test_data.dart';

void main() {
  group('Photo', () {
    test('should create Photo with all fields', () {
      final takenAt = DateTime.now();
      
      final photo = Photo(
        id: 'test-photo-id',
        photoPointId: 'test-photo-point-id',
        filePath: '/test/path/photo.jpg',
        latitude: 37.7749,
        longitude: -122.4194,
        compassDirection: 45.0,
        takenAt: takenAt,
        isInitial: true,
        orientation: PhotoOrientation.portrait,
      );

      expect(photo.id, 'test-photo-id');
      expect(photo.photoPointId, 'test-photo-point-id');
      expect(photo.filePath, '/test/path/photo.jpg');
      expect(photo.latitude, 37.7749);
      expect(photo.longitude, -122.4194);
      expect(photo.compassDirection, 45.0);
      expect(photo.takenAt, takenAt);
      expect(photo.isInitial, true);
    });

    test('should create Photo with all required fields', () {
      final photo = Photo(
        id: 'test-photo-id',
        photoPointId: 'test-photo-point-id',
        filePath: '/test/path/photo.jpg',
        latitude: 37.7749,
        longitude: -122.4194,
        compassDirection: 45.0,
        takenAt: DateTime.now(),
        isInitial: false,
        orientation: PhotoOrientation.landscape,
      );

      expect(photo.id, 'test-photo-id');
      expect(photo.photoPointId, 'test-photo-point-id');
      expect(photo.filePath, '/test/path/photo.jpg');
      expect(photo.latitude, 37.7749);
      expect(photo.longitude, -122.4194);
      expect(photo.compassDirection, 45.0);
      expect(photo.isInitial, false);
    });

    test('should serialize to JSON', () {
      final photo = TestData.createMockPhoto();
      final json = photo.toJson();

      expect(json['id'], photo.id);
      expect(json['photoPointId'], photo.photoPointId);
      expect(json['filePath'], photo.filePath);
      expect(json['latitude'], photo.latitude);
      expect(json['longitude'], photo.longitude);
      expect(json['compassDirection'], photo.compassDirection);
      expect(json['takenAt'], photo.takenAt.toIso8601String());
      expect(json['isInitial'], photo.isInitial);
    });

    test('should deserialize from JSON', () {
      final originalPhoto = TestData.createMockPhoto();
      final json = originalPhoto.toJson();
      final deserializedPhoto = Photo.fromJson(json);

      expect(deserializedPhoto.id, originalPhoto.id);
      expect(deserializedPhoto.photoPointId, originalPhoto.photoPointId);
      expect(deserializedPhoto.filePath, originalPhoto.filePath);
      expect(deserializedPhoto.latitude, originalPhoto.latitude);
      expect(deserializedPhoto.longitude, originalPhoto.longitude);
      expect(deserializedPhoto.compassDirection, originalPhoto.compassDirection);
      expect(deserializedPhoto.takenAt, originalPhoto.takenAt);
      expect(deserializedPhoto.isInitial, originalPhoto.isInitial);
    });

    test('should handle JSON serialization with all values', () {
      final photo = Photo(
        id: 'test-photo-id',
        photoPointId: 'test-photo-point-id',
        filePath: '/test/path/photo.jpg',
        latitude: 37.7749,
        longitude: -122.4194,
        compassDirection: 45.0,
        takenAt: DateTime.now(),
        isInitial: false,
        orientation: PhotoOrientation.landscape,
      );

      final json = photo.toJson();
      expect(json['latitude'], 37.7749);
      expect(json['longitude'], -122.4194);
      expect(json['compassDirection'], 45.0);

      final deserializedPhoto = Photo.fromJson(json);
      expect(deserializedPhoto.latitude, 37.7749);
      expect(deserializedPhoto.longitude, -122.4194);
      expect(deserializedPhoto.compassDirection, 45.0);
    });

    test('should create copy with modified fields', () {
      final originalPhoto = TestData.createMockPhoto();
      final modifiedPhoto = originalPhoto.copyWith(
        filePath: '/modified/path/photo.jpg',
        latitude: 40.7128,
        longitude: -74.0060,
        compassDirection: 90.0,
        isInitial: false,
      );

      expect(modifiedPhoto.id, originalPhoto.id);
      expect(modifiedPhoto.photoPointId, originalPhoto.photoPointId);
      expect(modifiedPhoto.filePath, '/modified/path/photo.jpg');
      expect(modifiedPhoto.latitude, 40.7128);
      expect(modifiedPhoto.longitude, -74.0060);
      expect(modifiedPhoto.compassDirection, 90.0);
      expect(modifiedPhoto.takenAt, originalPhoto.takenAt);
      expect(modifiedPhoto.isInitial, false);
    });

    test('should create copy with no modifications', () {
      final originalPhoto = TestData.createMockPhoto();
      final copyPhoto = originalPhoto.copyWith();

      expect(copyPhoto.id, originalPhoto.id);
      expect(copyPhoto.photoPointId, originalPhoto.photoPointId);
      expect(copyPhoto.filePath, originalPhoto.filePath);
      expect(copyPhoto.latitude, originalPhoto.latitude);
      expect(copyPhoto.longitude, originalPhoto.longitude);
      expect(copyPhoto.compassDirection, originalPhoto.compassDirection);
      expect(copyPhoto.takenAt, originalPhoto.takenAt);
      expect(copyPhoto.isInitial, originalPhoto.isInitial);
    });

    test('should validate file path format', () {
      final photo = TestData.createMockPhoto(filePath: '/test/path/photo.jpg');
      
      expect(photo.filePath, contains('.jpg'));
      expect(photo.filePath, startsWith('/'));
    });

    test('should validate coordinate ranges', () {
      final photo = Photo(
        id: 'test-photo-id',
        photoPointId: 'test-photo-point-id',
        filePath: '/test/path/photo.jpg',
        latitude: 45.0,
        longitude: -120.0,
        compassDirection: 180.0,
        takenAt: DateTime.now(),
        isInitial: true,
        orientation: PhotoOrientation.portrait,
      );

      expect(photo.latitude >= -90 && photo.latitude <= 90, true);
      expect(photo.longitude >= -180 && photo.longitude <= 180, true);
      expect(photo.compassDirection >= 0 && photo.compassDirection < 360, true);
    });

    test('should handle different file extensions', () {
      final extensions = ['.jpg', '.jpeg', '.png', '.heic'];
      
      for (final ext in extensions) {
        final photo = TestData.createMockPhoto(filePath: '/test/path/photo$ext');
        expect(photo.filePath, endsWith(ext));
      }
    });

    test('should validate photo point relationship', () {
      final photoPointId = 'test-photo-point-id';
      final photo = TestData.createMockPhoto(photoPointId: photoPointId);
      
      expect(photo.photoPointId, photoPointId);
      expect(photo.photoPointId.isNotEmpty, true);
    });

    test('should handle initial photo flag', () {
      final initialPhoto = TestData.createMockPhoto(isInitial: true);
      final followUpPhoto = TestData.createMockPhoto(isInitial: false);
      
      expect(initialPhoto.isInitial, true);
      expect(followUpPhoto.isInitial, false);
    });

    test('should handle photo timestamp', () {
      final now = DateTime.now();
      final photo = TestData.createMockPhoto(takenAt: now);
      
      expect(photo.takenAt, now);
      expect(photo.takenAt.isBefore(DateTime.now().add(Duration(seconds: 1))), true);
    });

    test('should validate photo metadata consistency', () {
      final photo = TestData.createMockPhoto(
        latitude: 37.7749,
        longitude: -122.4194,
        compassDirection: 45.0,
      );
      
      // If photo has location, it should have both lat and lng
      // Compass direction should be within valid range
      expect(photo.compassDirection >= 0 && photo.compassDirection < 360, true);
    });
  });
}
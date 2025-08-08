import 'package:flutter_test/flutter_test.dart';
import 'package:photopoints/models/photo_point.dart';
import '../../test_data.dart';

void main() {
  group('PhotoPoint', () {
    test('should create PhotoPoint with all fields', () {
      final createdAt = DateTime.now();
      final photos = [TestData.createMockPhoto()];

      final photoPoint = PhotoPoint(
        id: 'test-id',
        name: 'Test Point',
        notes: 'Test notes',
        latitude: 37.7749,
        longitude: -122.4194,
        compassDirection: 45.0,
        createdAt: createdAt,
        photos: photos,
      );

      expect(photoPoint.id, 'test-id');
      expect(photoPoint.name, 'Test Point');
      expect(photoPoint.notes, 'Test notes');
      expect(photoPoint.latitude, 37.7749);
      expect(photoPoint.longitude, -122.4194);
      expect(photoPoint.compassDirection, 45.0);
      expect(photoPoint.createdAt, createdAt);
      expect(photoPoint.photos.length, 1);
    });

    test('should create PhotoPoint with nullable fields', () {
      final photoPoint = PhotoPoint(
        id: 'test-id',
        name: 'Test Point',
        notes: null,
        latitude: null,
        longitude: null,
        compassDirection: null,
        createdAt: DateTime.now(),
        photos: [],
      );

      expect(photoPoint.id, 'test-id');
      expect(photoPoint.name, 'Test Point');
      expect(photoPoint.notes, isNull);
      expect(photoPoint.latitude, isNull);
      expect(photoPoint.longitude, isNull);
      expect(photoPoint.compassDirection, isNull);
      expect(photoPoint.photos.isEmpty, true);
    });

    test('should serialize to JSON', () {
      final photoPoint = TestData.createMockPhotoPoint();
      final json = photoPoint.toJson();

      expect(json['id'], photoPoint.id);
      expect(json['name'], photoPoint.name);
      expect(json['notes'], photoPoint.notes);
      expect(json['latitude'], photoPoint.latitude);
      expect(json['longitude'], photoPoint.longitude);
      expect(json['compassDirection'], photoPoint.compassDirection);
      expect(json['createdAt'], photoPoint.createdAt.toIso8601String());
      expect(json['photos'], isList);
    });

    test('should deserialize from JSON', () {
      final originalPhotoPoint = TestData.createMockPhotoPoint();
      final json = originalPhotoPoint.toJson();
      final deserializedPhotoPoint = PhotoPoint.fromJson(json);

      expect(deserializedPhotoPoint.id, originalPhotoPoint.id);
      expect(deserializedPhotoPoint.name, originalPhotoPoint.name);
      expect(deserializedPhotoPoint.notes, originalPhotoPoint.notes);
      expect(deserializedPhotoPoint.latitude, originalPhotoPoint.latitude);
      expect(deserializedPhotoPoint.longitude, originalPhotoPoint.longitude);
      expect(
        deserializedPhotoPoint.compassDirection,
        originalPhotoPoint.compassDirection,
      );
      expect(deserializedPhotoPoint.createdAt, originalPhotoPoint.createdAt);
      expect(
        deserializedPhotoPoint.photos.length,
        originalPhotoPoint.photos.length,
      );
    });

    test('should handle JSON serialization with null values', () {
      final photoPoint = PhotoPoint(
        id: 'test-id',
        name: 'Test Point',
        notes: null,
        latitude: null,
        longitude: null,
        compassDirection: null,
        createdAt: DateTime.now(),
        photos: [],
      );

      final json = photoPoint.toJson();
      expect(json['notes'], isNull);
      expect(json['latitude'], isNull);
      expect(json['longitude'], isNull);
      expect(json['compassDirection'], isNull);

      final deserializedPhotoPoint = PhotoPoint.fromJson(json);
      expect(deserializedPhotoPoint.notes, isNull);
      expect(deserializedPhotoPoint.latitude, isNull);
      expect(deserializedPhotoPoint.longitude, isNull);
      expect(deserializedPhotoPoint.compassDirection, isNull);
    });

    test('should create copy with modified fields', () {
      final originalPhotoPoint = TestData.createMockPhotoPoint();
      final modifiedPhotoPoint = originalPhotoPoint.copyWith(
        name: 'Modified Name',
        notes: 'Modified notes',
        latitude: 40.7128,
        longitude: -74.0060,
      );

      expect(modifiedPhotoPoint.id, originalPhotoPoint.id);
      expect(modifiedPhotoPoint.name, 'Modified Name');
      expect(modifiedPhotoPoint.notes, 'Modified notes');
      expect(modifiedPhotoPoint.latitude, 40.7128);
      expect(modifiedPhotoPoint.longitude, -74.0060);
      expect(
        modifiedPhotoPoint.compassDirection,
        originalPhotoPoint.compassDirection,
      );
      expect(modifiedPhotoPoint.createdAt, originalPhotoPoint.createdAt);
      expect(modifiedPhotoPoint.photos, originalPhotoPoint.photos);
    });

    test('should create copy with no modifications', () {
      final originalPhotoPoint = TestData.createMockPhotoPoint();
      final copyPhotoPoint = originalPhotoPoint.copyWith();

      expect(copyPhotoPoint.id, originalPhotoPoint.id);
      expect(copyPhotoPoint.name, originalPhotoPoint.name);
      expect(copyPhotoPoint.notes, originalPhotoPoint.notes);
      expect(copyPhotoPoint.latitude, originalPhotoPoint.latitude);
      expect(copyPhotoPoint.longitude, originalPhotoPoint.longitude);
      expect(
        copyPhotoPoint.compassDirection,
        originalPhotoPoint.compassDirection,
      );
      expect(copyPhotoPoint.createdAt, originalPhotoPoint.createdAt);
      expect(copyPhotoPoint.photos, originalPhotoPoint.photos);
    });

    test('should validate coordinate ranges', () {
      // Test valid coordinates
      final validPhotoPoint = PhotoPoint(
        id: 'test-id',
        name: 'Valid Point',
        latitude: 45.0,
        longitude: -120.0,
        compassDirection: 180.0,
        createdAt: DateTime.now(),
        photos: [],
      );

      expect(
        validPhotoPoint.latitude! >= -90 && validPhotoPoint.latitude! <= 90,
        true,
      );
      expect(
        validPhotoPoint.longitude! >= -180 && validPhotoPoint.longitude! <= 180,
        true,
      );
      expect(
        validPhotoPoint.compassDirection! >= 0 &&
            validPhotoPoint.compassDirection! < 360,
        true,
      );
    });

    test('should handle photos list operations', () {
      final photo1 = TestData.createMockPhoto(id: 'photo1');
      final photo2 = TestData.createMockPhoto(id: 'photo2');

      final photoPoint = TestData.createMockPhotoPoint(photos: [photo1]);

      expect(photoPoint.photos.length, 1);
      expect(photoPoint.photos.first.id, 'photo1');

      final updatedPhotoPoint = photoPoint.copyWith(photos: [photo1, photo2]);
      expect(updatedPhotoPoint.photos.length, 2);
    });

    test('should handle empty photos list', () {
      final photoPoint = TestData.createMockPhotoPoint(photos: []);

      expect(photoPoint.photos.isEmpty, true);
      expect(photoPoint.photos.length, 0);
    });
  });
}

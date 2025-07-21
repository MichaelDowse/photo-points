import 'package:photopoints/models/photo_point.dart';
import 'package:photopoints/models/photo.dart';
import 'package:photopoints/models/location_data.dart';
import 'package:photopoints/models/compass_data.dart';

class TestData {
  static PhotoPoint createMockPhotoPoint({
    String? id,
    String? name,
    String? notes,
    double? latitude = 37.7749,
    double? longitude = -122.4194,
    double? compassDirection = 45.0,
    DateTime? createdAt,
    List<Photo>? photos,
  }) {
    return PhotoPoint(
      id: id ?? 'test-photo-point-1',
      name: name ?? 'Test Photo Point',
      notes: notes ?? 'Test notes',
      latitude: latitude,
      longitude: longitude,
      compassDirection: compassDirection,
      createdAt: createdAt ?? DateTime.now(),
      photos: photos ?? [],
    );
  }

  static Photo createMockPhoto({
    String? id,
    String? photoPointId,
    String? filePath,
    double? latitude,
    double? longitude,
    double? compassDirection,
    DateTime? takenAt,
    bool? isInitial,
    PhotoOrientation? orientation,
  }) {
    return Photo(
      id: id ?? 'test-photo-1',
      photoPointId: photoPointId ?? 'test-photo-point-1',
      filePath: filePath ?? '/test/path/photo.jpg',
      latitude: latitude ?? 37.7749,
      longitude: longitude ?? -122.4194,
      compassDirection: compassDirection ?? 45.0,
      takenAt: takenAt ?? DateTime.now(),
      isInitial: isInitial ?? true,
      orientation: orientation ?? PhotoOrientation.portrait,
    );
  }

  static LocationData createMockLocationData({
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return LocationData(
      latitude: latitude ?? 37.7749,
      longitude: longitude ?? -122.4194,
      accuracy: accuracy ?? 5.0,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  static CompassData createMockCompassData({
    double? heading,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return CompassData(
      heading: heading ?? 45.0,
      accuracy: accuracy ?? 5.0,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  static List<PhotoPoint> createMockPhotoPointList({int count = 3}) {
    return List.generate(count, (index) {
      return createMockPhotoPoint(
        id: 'test-photo-point-${index + 1}',
        name: 'Test Photo Point ${index + 1}',
        latitude: 37.7749 + (index * 0.001),
        longitude: -122.4194 + (index * 0.001),
        compassDirection: (index + 1) * 45.0,
        photos: [
          createMockPhoto(
            id: 'test-photo-${index + 1}',
            photoPointId: 'test-photo-point-${index + 1}',
            filePath: '/test/path/photo${index + 1}.jpg',
          ),
        ],
      );
    });
  }
}
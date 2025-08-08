import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:photopoints/services/database_service.dart';
import 'package:photopoints/models/photo_point.dart';
import 'package:photopoints/models/photo.dart';

class MockDatabase extends Mock implements Database {}

class MockDatabaseService extends Mock implements DatabaseService {
  final Map<String, PhotoPoint> _photoPoints = {};
  final Map<String, Photo> _photos = {};

  @override
  Future<List<PhotoPoint>> getAllPhotoPoints() async {
    return _photoPoints.values.toList();
  }

  @override
  Future<PhotoPoint?> getPhotoPoint(String id) async {
    return _photoPoints[id];
  }

  @override
  Future<String> insertPhotoPoint(PhotoPoint photoPoint) async {
    _photoPoints[photoPoint.id] = photoPoint;
    return photoPoint.id;
  }

  @override
  Future<int> updatePhotoPoint(PhotoPoint photoPoint) async {
    _photoPoints[photoPoint.id] = photoPoint;
    return 1;
  }

  @override
  Future<int> deletePhotoPoint(String id) async {
    _photoPoints.remove(id);
    _photos.removeWhere((key, photo) => photo.photoPointId == id);
    return 1;
  }

  @override
  Future<String> insertPhoto(Photo photo) async {
    _photos[photo.id] = photo;
    return photo.id;
  }

  @override
  Future<int> deletePhoto(String id) async {
    _photos.remove(id);
    return 1;
  }

  @override
  Future<List<Photo>> getPhotosForPhotoPoint(String photoPointId) async {
    return _photos.values
        .where((photo) => photo.photoPointId == photoPointId)
        .toList();
  }

  // Helper methods for testing
  void clear() {
    _photoPoints.clear();
    _photos.clear();
  }

  void addMockPhotoPoint(PhotoPoint photoPoint) {
    _photoPoints[photoPoint.id] = photoPoint;
  }

  void addMockPhoto(Photo photo) {
    _photos[photo.id] = photo;
  }
}

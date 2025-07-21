import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:photopoints/services/database_service.dart';
import '../../test_data.dart';
import 'dart:io';

void main() {
  late DatabaseService databaseService;
  
  setUpAll(() {
    // Initialize Flutter bindings
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock path provider for testing
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return Directory.systemTemp.path;
        }
        return null;
      },
    );
    
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    databaseService = DatabaseService();
  });

  tearDownAll(() async {
    // Clean up database after all tests
    await databaseService.close();
  });

  group('DatabaseService', () {
    test('should create and initialize database', () async {
      final db = await databaseService.database;
      expect(db.isOpen, true);
    });

    test('should insert and retrieve photo point', () async {
      final photoPoint = TestData.createMockPhotoPoint();
      
      await databaseService.insertPhotoPoint(photoPoint);
      final retrieved = await databaseService.getPhotoPoint(photoPoint.id);
      
      expect(retrieved, isNotNull);
      expect(retrieved!.id, photoPoint.id);
      expect(retrieved.name, photoPoint.name);
      expect(retrieved.notes, photoPoint.notes);
      expect(retrieved.latitude, photoPoint.latitude);
      expect(retrieved.longitude, photoPoint.longitude);
      expect(retrieved.compassDirection, photoPoint.compassDirection);
    });

    test('should insert and retrieve photo', () async {
      final photoPoint = TestData.createMockPhotoPoint();
      final photo = TestData.createMockPhoto(photoPointId: photoPoint.id);
      
      await databaseService.insertPhotoPoint(photoPoint);
      await databaseService.insertPhoto(photo);
      
      final photos = await databaseService.getPhotosForPhotoPoint(photoPoint.id);
      
      expect(photos.length, 1);
      expect(photos.first.id, photo.id);
      expect(photos.first.photoPointId, photo.photoPointId);
      expect(photos.first.filePath, photo.filePath);
    });

    test('should update photo point', () async {
      final photoPoint = TestData.createMockPhotoPoint();
      await databaseService.insertPhotoPoint(photoPoint);
      
      final updatedPhotoPoint = photoPoint.copyWith(
        name: 'Updated Name',
        notes: 'Updated notes',
      );
      
      await databaseService.updatePhotoPoint(updatedPhotoPoint);
      final retrieved = await databaseService.getPhotoPoint(photoPoint.id);
      
      expect(retrieved!.name, 'Updated Name');
      expect(retrieved.notes, 'Updated notes');
    });

    test('should delete photo point', () async {
      final photoPoint = TestData.createMockPhotoPoint();
      await databaseService.insertPhotoPoint(photoPoint);
      
      await databaseService.deletePhotoPoint(photoPoint.id);
      final retrieved = await databaseService.getPhotoPoint(photoPoint.id);
      
      expect(retrieved, isNull);
    });

    test('should delete photo', () async {
      final photoPoint = TestData.createMockPhotoPoint();
      final photo = TestData.createMockPhoto(photoPointId: photoPoint.id);
      
      await databaseService.insertPhotoPoint(photoPoint);
      await databaseService.insertPhoto(photo);
      
      await databaseService.deletePhoto(photo.id);
      final photos = await databaseService.getPhotosForPhotoPoint(photoPoint.id);
      
      expect(photos.isEmpty, true);
    });

    test('should get all photo points', () async {
      final photoPoints = TestData.createMockPhotoPointList(count: 3);
      
      for (final photoPoint in photoPoints) {
        await databaseService.insertPhotoPoint(photoPoint);
      }
      
      final retrieved = await databaseService.getAllPhotoPoints();
      
      expect(retrieved.length, 3);
      expect(retrieved.map((p) => p.id).toSet(), 
             photoPoints.map((p) => p.id).toSet());
    });

    test('should handle photo point with null location data', () async {
      final photoPoint = TestData.createMockPhotoPoint(
        latitude: null,
        longitude: null,
        compassDirection: null,
      );
      
      await databaseService.insertPhotoPoint(photoPoint);
      final retrieved = await databaseService.getPhotoPoint(photoPoint.id);
      
      expect(retrieved, isNotNull);
      expect(retrieved!.latitude, isNull);
      expect(retrieved.longitude, isNull);
      expect(retrieved.compassDirection, isNull);
    });

    test('should cascade delete photos when photo point is deleted', () async {
      final photoPoint = TestData.createMockPhotoPoint();
      final photo1 = TestData.createMockPhoto(id: 'photo1', photoPointId: photoPoint.id);
      final photo2 = TestData.createMockPhoto(id: 'photo2', photoPointId: photoPoint.id);
      
      await databaseService.insertPhotoPoint(photoPoint);
      await databaseService.insertPhoto(photo1);
      await databaseService.insertPhoto(photo2);
      
      await databaseService.deletePhotoPoint(photoPoint.id);
      final photos = await databaseService.getPhotosForPhotoPoint(photoPoint.id);
      
      expect(photos.isEmpty, true);
    });
  });
}
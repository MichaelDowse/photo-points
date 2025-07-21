import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:photopoints/services/database_service.dart';
import 'package:photopoints/providers/app_state_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'test_data.dart';
import 'dart:io';

void main() {
  late DatabaseService databaseService;
  late AppStateProvider appStateProvider;

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
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    databaseService = DatabaseService();
    appStateProvider = AppStateProvider();
    
    // Clean up any existing data before each test
    final db = await databaseService.database;
    await db.execute('DELETE FROM photos');
    await db.execute('DELETE FROM photo_points');
  });

  tearDownAll(() async {
    // Clean up database after all tests
    try {
      await databaseService.close();
    } catch (e) {
      // Database might not be initialized in some tests
    }
  });

  group('Photo Point Workflow Integration Tests', () {
    test('Complete photo point creation workflow', () async {
      // Create a photo point
      final photoPoint = TestData.createMockPhotoPoint(
        name: 'Integration Test Point',
        notes: 'Created during integration test',
      );

      // Add photo point through app state provider
      await appStateProvider.addPhotoPoint(photoPoint);

      // Verify photo point was added
      await appStateProvider.loadPhotoPoints();
      expect(appStateProvider.photoPoints.length, 1);
      expect(appStateProvider.photoPoints.first.name, 'Integration Test Point');
      expect(appStateProvider.error, isNull);
    });

    test('Photo point with photos workflow', () async {
      // Create photo point with multiple photos
      final photo1 = TestData.createMockPhoto(
        id: 'photo1',
        filePath: '/test/path/photo1.jpg',
        isInitial: true,
      );
      final photo2 = TestData.createMockPhoto(
        id: 'photo2',
        filePath: '/test/path/photo2.jpg',
        isInitial: false,
      );

      final photoPoint = TestData.createMockPhotoPoint(
        name: 'Photo Point with Images',
        photos: [photo1, photo2],
      );

      // Add through app state provider
      await appStateProvider.addPhotoPoint(photoPoint);

      // Verify photo point and photos were added
      await appStateProvider.loadPhotoPoints();
      expect(appStateProvider.photoPoints.length, 1);
      
      final addedPhotoPoint = appStateProvider.photoPoints.first;
      expect(addedPhotoPoint.photos.length, 2);
      expect(addedPhotoPoint.photos.first.isInitial, true);
      expect(addedPhotoPoint.photos.last.isInitial, false);
    });

    test('Photo point update workflow', () async {
      // Create and add initial photo point
      final photoPoint = TestData.createMockPhotoPoint(
        name: 'Original Name',
        notes: 'Original notes',
      );

      await appStateProvider.addPhotoPoint(photoPoint);

      // Update the photo point
      final updatedPhotoPoint = photoPoint.copyWith(
        name: 'Updated Name',
        notes: 'Updated notes',
      );

      await appStateProvider.updatePhotoPoint(updatedPhotoPoint);

      // Verify update
      await appStateProvider.loadPhotoPoints();
      expect(appStateProvider.photoPoints.length, 1);
      expect(appStateProvider.photoPoints.first.name, 'Updated Name');
      expect(appStateProvider.photoPoints.first.notes, 'Updated notes');
    });

    test('Photo point deletion workflow', () async {
      // Create and add photo point
      final photoPoint = TestData.createMockPhotoPoint();
      await appStateProvider.addPhotoPoint(photoPoint);

      // Verify it was added
      await appStateProvider.loadPhotoPoints();
      expect(appStateProvider.photoPoints.length, 1);

      // Delete the photo point
      await appStateProvider.deletePhotoPoint(photoPoint.id);

      // Verify it was deleted
      await appStateProvider.loadPhotoPoints();
      expect(appStateProvider.photoPoints.length, 0);
    });

    test('Multiple photo points workflow', () async {
      // Create multiple photo points
      final photoPoints = TestData.createMockPhotoPointList(count: 5);

      // Add all photo points
      for (final photoPoint in photoPoints) {
        await appStateProvider.addPhotoPoint(photoPoint);
      }

      // Verify all were added
      await appStateProvider.loadPhotoPoints();
      expect(appStateProvider.photoPoints.length, 5);

      // Verify correct order and content
      final addedPhotoPoints = appStateProvider.photoPoints;
      for (int i = 0; i < photoPoints.length; i++) {
        expect(addedPhotoPoints.any((p) => p.id == photoPoints[i].id), true);
      }
    });

    test('Photo point with location data workflow', () async {
      // Create photo point with location data
      final photoPoint = TestData.createMockPhotoPoint(
        name: 'Located Photo Point',
        latitude: 37.7749,
        longitude: -122.4194,
        compassDirection: 45.0,
      );

      await appStateProvider.addPhotoPoint(photoPoint);

      // Verify location data was preserved
      await appStateProvider.loadPhotoPoints();
      final addedPhotoPoint = appStateProvider.photoPoints.first;
      expect(addedPhotoPoint.latitude, 37.7749);
      expect(addedPhotoPoint.longitude, -122.4194);
      expect(addedPhotoPoint.compassDirection, 45.0);
    });

    test('Photo point without location data workflow', () async {
      // Create photo point without location data
      final photoPoint = TestData.createMockPhotoPoint(
        name: 'No Location Photo Point',
        latitude: null,
        longitude: null,
        compassDirection: null,
      );

      await appStateProvider.addPhotoPoint(photoPoint);

      // Verify null values were preserved
      await appStateProvider.loadPhotoPoints();
      final addedPhotoPoint = appStateProvider.photoPoints.first;
      expect(addedPhotoPoint.latitude, isNull);
      expect(addedPhotoPoint.longitude, isNull);
      expect(addedPhotoPoint.compassDirection, isNull);
    });

    test('Error handling workflow', () async {
      // Test error handling by creating invalid photo point
      // This would depend on actual validation in the app
      expect(appStateProvider.error, isNull);
      
      // Try to load photo points when database is not available
      // This would test error handling
      await appStateProvider.loadPhotoPoints();
      
      // App should handle errors gracefully
      expect(appStateProvider.isLoading, false);
    });

    test('Loading state workflow', () async {
      // Test loading states
      expect(appStateProvider.isLoading, false);
      
      // Create a photo point
      final photoPoint = TestData.createMockPhotoPoint();
      
      // Add photo point (this should trigger loading state)
      final addFuture = appStateProvider.addPhotoPoint(photoPoint);
      
      // Note: In a real test, we might check loading state here
      // but it's very fast in tests
      
      await addFuture;
      expect(appStateProvider.isLoading, false);
    });

    test('Photo management workflow', () async {
      // Create photo point
      final photoPoint = TestData.createMockPhotoPoint();
      await appStateProvider.addPhotoPoint(photoPoint);

      // Add a photo to the photo point
      final photo = TestData.createMockPhoto(
        photoPointId: photoPoint.id,
        filePath: '/test/path/new_photo.jpg',
        isInitial: false,
      );

      await appStateProvider.addPhotoToPoint(photoPoint.id, photo);

      // Verify photo was added
      await appStateProvider.loadPhotoPoints();
      final updatedPhotoPoint = appStateProvider.photoPoints.first;
      expect(updatedPhotoPoint.photos.length, 1); // Original photos + new photo
    });

    test('Data persistence workflow', () async {
      // Create photo point
      final photoPoint = TestData.createMockPhotoPoint(
        name: 'Persistent Photo Point',
      );

      await appStateProvider.addPhotoPoint(photoPoint);

      // Create new app state provider (simulating app restart)
      final newAppStateProvider = AppStateProvider();

      // Load photo points
      await newAppStateProvider.loadPhotoPoints();

      // Verify data persisted
      expect(newAppStateProvider.photoPoints.length, 1);
      expect(newAppStateProvider.photoPoints.first.name, 'Persistent Photo Point');
    });
  });
}
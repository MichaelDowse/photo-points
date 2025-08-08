import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/photo_point.dart';
import '../models/photo.dart';
import 'web_storage_service.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // For web, we'll use SharedPreferences instead of SQLite
      // Return a dummy database object that won't be used
      throw UnsupportedError('SQLite not supported on web');
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'photopoints.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration from version 1 to 2: Make location and compass fields nullable
      await db.execute('''
        CREATE TABLE photo_points_new (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          notes TEXT,
          latitude REAL,
          longitude REAL,
          compass_direction REAL,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        INSERT INTO photo_points_new (id, name, notes, latitude, longitude, compass_direction, created_at)
        SELECT id, name, notes, latitude, longitude, compass_direction, created_at FROM photo_points
      ''');

      await db.execute('DROP TABLE photo_points');
      await db.execute('ALTER TABLE photo_points_new RENAME TO photo_points');
    }

    if (oldVersion < 3) {
      // Migration from version 2 to 3: Add orientation column to photos table
      await db.execute('''
        ALTER TABLE photos ADD COLUMN orientation TEXT DEFAULT 'portrait'
      ''');
    }

    if (oldVersion < 4) {
      // Migration from version 3 to 4: Add asset_id column for photo library storage
      await db.execute('''
        ALTER TABLE photos ADD COLUMN asset_id TEXT
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE photo_points (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        notes TEXT,
        latitude REAL,
        longitude REAL,
        compass_direction REAL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE photos (
        id TEXT PRIMARY KEY,
        photo_point_id TEXT NOT NULL,
        file_path TEXT,
        asset_id TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        compass_direction REAL NOT NULL,
        taken_at TEXT NOT NULL,
        is_initial INTEGER NOT NULL,
        orientation TEXT NOT NULL DEFAULT 'portrait',
        FOREIGN KEY (photo_point_id) REFERENCES photo_points (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<String> insertPhotoPoint(PhotoPoint photoPoint) async {
    if (kIsWeb) {
      await WebStorageService.addPhotoPoint(photoPoint);
      return photoPoint.id;
    }

    final db = await database;
    await db.insert('photo_points', {
      'id': photoPoint.id,
      'name': photoPoint.name,
      'notes': photoPoint.notes,
      'latitude': photoPoint.latitude,
      'longitude': photoPoint.longitude,
      'compass_direction': photoPoint.compassDirection,
      'created_at': photoPoint.createdAt.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return photoPoint.id;
  }

  Future<String> insertPhoto(Photo photo) async {
    if (kIsWeb) {
      await WebStorageService.addPhoto(photo);
      return photo.id;
    }

    final db = await database;
    await db.insert('photos', {
      'id': photo.id,
      'photo_point_id': photo.photoPointId,
      'file_path': photo.filePath,
      'asset_id': photo.assetId,
      'latitude': photo.latitude,
      'longitude': photo.longitude,
      'compass_direction': photo.compassDirection,
      'taken_at': photo.takenAt.toIso8601String(),
      'is_initial': photo.isInitial ? 1 : 0,
      'orientation': photo.orientation.name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return photo.id;
  }

  Future<List<PhotoPoint>> getAllPhotoPoints() async {
    if (kIsWeb) {
      return await WebStorageService.loadPhotoPoints();
    }

    final db = await database;
    final List<Map<String, dynamic>> photoPointMaps = await db.query(
      'photo_points',
    );

    List<PhotoPoint> photoPoints = [];
    for (Map<String, dynamic> photoPointMap in photoPointMaps) {
      List<Photo> photos = await getPhotosForPhotoPoint(photoPointMap['id']);
      photoPoints.add(
        PhotoPoint(
          id: photoPointMap['id'],
          name: photoPointMap['name'],
          notes: photoPointMap['notes'],
          latitude: photoPointMap['latitude'],
          longitude: photoPointMap['longitude'],
          compassDirection: photoPointMap['compass_direction'],
          createdAt: DateTime.parse(photoPointMap['created_at']),
          photos: photos,
        ),
      );
    }
    return photoPoints;
  }

  Future<PhotoPoint?> getPhotoPoint(String id) async {
    if (kIsWeb) {
      final photoPoints = await WebStorageService.loadPhotoPoints();
      return photoPoints.firstWhere(
        (pp) => pp.id == id,
        orElse: () => throw Exception('Photo point not found'),
      );
    }

    final db = await database;
    final List<Map<String, dynamic>> photoPointMaps = await db.query(
      'photo_points',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (photoPointMaps.isNotEmpty) {
      Map<String, dynamic> photoPointMap = photoPointMaps.first;
      List<Photo> photos = await getPhotosForPhotoPoint(id);
      return PhotoPoint(
        id: photoPointMap['id'],
        name: photoPointMap['name'],
        notes: photoPointMap['notes'],
        latitude: photoPointMap['latitude'],
        longitude: photoPointMap['longitude'],
        compassDirection: photoPointMap['compass_direction'],
        createdAt: DateTime.parse(photoPointMap['created_at']),
        photos: photos,
      );
    }
    return null;
  }

  Future<List<Photo>> getPhotosForPhotoPoint(String photoPointId) async {
    if (kIsWeb) {
      final photoPoints = await WebStorageService.loadPhotoPoints();
      final photoPoint = photoPoints.firstWhere(
        (pp) => pp.id == photoPointId,
        orElse: () => throw Exception('Photo point not found'),
      );
      return photoPoint.photos;
    }

    final db = await database;
    final List<Map<String, dynamic>> photoMaps = await db.query(
      'photos',
      where: 'photo_point_id = ?',
      whereArgs: [photoPointId],
      orderBy: 'taken_at ASC',
    );

    return List.generate(photoMaps.length, (i) {
      final orientationString =
          photoMaps[i]['orientation'] as String? ?? 'portrait';
      final orientation = PhotoOrientation.values.firstWhere(
        (o) => o.name == orientationString,
        orElse: () => PhotoOrientation.portrait,
      );

      return Photo(
        id: photoMaps[i]['id'],
        photoPointId: photoMaps[i]['photo_point_id'],
        filePath: photoMaps[i]['file_path'],
        assetId: photoMaps[i]['asset_id'],
        latitude: photoMaps[i]['latitude'],
        longitude: photoMaps[i]['longitude'],
        compassDirection: photoMaps[i]['compass_direction'],
        takenAt: DateTime.parse(photoMaps[i]['taken_at']),
        isInitial: photoMaps[i]['is_initial'] == 1,
        orientation: orientation,
      );
    });
  }

  Future<int> updatePhotoPoint(PhotoPoint photoPoint) async {
    if (kIsWeb) {
      await WebStorageService.updatePhotoPoint(photoPoint);
      return 1;
    }

    final db = await database;
    return await db.update(
      'photo_points',
      {
        'name': photoPoint.name,
        'notes': photoPoint.notes,
        'latitude': photoPoint.latitude,
        'longitude': photoPoint.longitude,
        'compass_direction': photoPoint.compassDirection,
      },
      where: 'id = ?',
      whereArgs: [photoPoint.id],
    );
  }

  Future<int> updatePhotoPointLocationIfMissing(
    String photoPointId,
    double latitude,
    double longitude,
    double compassDirection,
  ) async {
    if (kIsWeb) {
      final photoPoints = await WebStorageService.loadPhotoPoints();
      final index = photoPoints.indexWhere((pp) => pp.id == photoPointId);
      if (index >= 0) {
        final photoPoint = photoPoints[index];
        if (photoPoint.latitude == null ||
            photoPoint.longitude == null ||
            photoPoint.compassDirection == null) {
          final updatedPhotoPoint = photoPoint.copyWith(
            latitude: latitude,
            longitude: longitude,
            compassDirection: compassDirection,
          );
          photoPoints[index] = updatedPhotoPoint;
          await WebStorageService.savePhotoPoints(photoPoints);
          return 1;
        }
      }
      return 0;
    }

    final db = await database;

    // Only update if latitude or longitude is null
    return await db.update(
      'photo_points',
      {
        'latitude': latitude,
        'longitude': longitude,
        'compass_direction': compassDirection,
      },
      where:
          'id = ? AND (latitude IS NULL OR longitude IS NULL OR compass_direction IS NULL)',
      whereArgs: [photoPointId],
    );
  }

  Future<int> deletePhotoPoint(String id) async {
    if (kIsWeb) {
      await WebStorageService.deletePhotoPoint(id);
      return 1;
    }

    final db = await database;

    // First delete all photos associated with this photo point
    await db.delete('photos', where: 'photo_point_id = ?', whereArgs: [id]);

    // Then delete the photo point itself
    return await db.delete('photo_points', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePhoto(String id) async {
    if (kIsWeb) {
      await WebStorageService.deletePhoto(id);
      return 1;
    }

    final db = await database;
    return await db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

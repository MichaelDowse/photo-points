import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/photo_point.dart';
import '../models/photo.dart';

class WebStorageService {
  static const String _photoPointsKey = 'photo_points';

  static Future<void> savePhotoPoints(List<PhotoPoint> photoPoints) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = photoPoints.map((pp) => pp.toJson()).toList();
      await prefs.setString(_photoPointsKey, jsonEncode(jsonList));
    }
  }

  static Future<List<PhotoPoint>> loadPhotoPoints() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_photoPointsKey);
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        return jsonList.map((json) => PhotoPoint.fromJson(json)).toList();
      }
    }
    return [];
  }

  static Future<void> deletePhotoPoint(String id) async {
    if (kIsWeb) {
      final photoPoints = await loadPhotoPoints();
      photoPoints.removeWhere((pp) => pp.id == id);
      await savePhotoPoints(photoPoints);
    }
  }

  static Future<void> addPhotoPoint(PhotoPoint photoPoint) async {
    if (kIsWeb) {
      final photoPoints = await loadPhotoPoints();
      photoPoints.add(photoPoint);
      await savePhotoPoints(photoPoints);
    }
  }

  static Future<void> updatePhotoPoint(PhotoPoint photoPoint) async {
    if (kIsWeb) {
      final photoPoints = await loadPhotoPoints();
      final index = photoPoints.indexWhere((pp) => pp.id == photoPoint.id);
      if (index >= 0) {
        photoPoints[index] = photoPoint;
        await savePhotoPoints(photoPoints);
      }
    }
  }

  static Future<void> addPhoto(Photo photo) async {
    if (kIsWeb) {
      final photoPoints = await loadPhotoPoints();
      final photoPointIndex = photoPoints.indexWhere(
        (pp) => pp.id == photo.photoPointId,
      );
      if (photoPointIndex >= 0) {
        photoPoints[photoPointIndex].photos.add(photo);
        await savePhotoPoints(photoPoints);
      }
    }
  }

  static Future<void> deletePhoto(String photoId) async {
    if (kIsWeb) {
      final photoPoints = await loadPhotoPoints();
      for (var photoPoint in photoPoints) {
        photoPoint.photos.removeWhere((photo) => photo.id == photoId);
      }
      await savePhotoPoints(photoPoints);
    }
  }
}

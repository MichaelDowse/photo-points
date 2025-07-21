import 'package:flutter/foundation.dart';
import '../models/photo_point.dart';
import '../models/photo.dart';
import '../services/database_service.dart';
import '../services/photo_service.dart';
import '../services/permission_service.dart';

class AppStateProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final PhotoService _photoService = PhotoService();
  final PermissionService _permissionService = PermissionService();

  List<PhotoPoint> _photoPoints = [];
  bool _isLoading = false;
  String? _error;
  Map<String, bool> _permissions = {
    'camera': false,
    'location': false,
    'storage': false,
    'photos': false,
  };

  List<PhotoPoint> get photoPoints => _photoPoints;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, bool> get permissions => _permissions;

  Future<void> loadPhotoPoints() async {
    _setLoading(true);
    _clearError();
    
    try {
      _photoPoints = await _databaseService.getAllPhotoPoints();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load photo points: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addPhotoPoint(PhotoPoint photoPoint) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _databaseService.insertPhotoPoint(photoPoint);
      
      // Add photos to database (only for native platforms)
      // On web, photos are already included in the PhotoPoint
      if (!kIsWeb) {
        for (Photo photo in photoPoint.photos) {
          await _databaseService.insertPhoto(photo);
        }
      }
      
      await loadPhotoPoints();
    } catch (e) {
      _setError('Failed to add photo point: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePhotoPoint(PhotoPoint photoPoint) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _databaseService.updatePhotoPoint(photoPoint);
      await loadPhotoPoints();
    } catch (e) {
      _setError('Failed to update photo point: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePhotoPoint(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Delete photos from filesystem
      await _photoService.deletePhotoPointPhotos(id);
      
      // Delete from database
      await _databaseService.deletePhotoPoint(id);
      
      await loadPhotoPoints();
    } catch (e) {
      _setError('Failed to delete photo point: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addPhotoToPoint(String photoPointId, Photo photo) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _databaseService.insertPhoto(photo);
      
      // Check if this photo can provide missing location/compass data for the photo point
      final photoPoint = await _databaseService.getPhotoPoint(photoPointId);
      if (photoPoint != null && 
          (!photoPoint.hasLocation || !photoPoint.hasCompassDirection)) {
        // Update photo point with location/compass data from this photo
        await _databaseService.updatePhotoPointLocationIfMissing(
          photoPointId,
          photo.latitude,
          photo.longitude,
          photo.compassDirection,
        );
      }
      
      await loadPhotoPoints();
    } catch (e) {
      _setError('Failed to add photo: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePhoto(String photoId, String filePath) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Delete photo file
      await _photoService.deletePhoto(filePath);
      
      // Delete from database
      await _databaseService.deletePhoto(photoId);
      
      await loadPhotoPoints();
    } catch (e) {
      _setError('Failed to delete photo: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkPermissions() async {
    try {
      _permissions = await _permissionService.checkAllPermissions();
      notifyListeners();
    } catch (e) {
      // Initialize with default values if permission check fails
      _permissions = {
        'camera': false,
        'location': false,
        'storage': false,
        'photos': false,
      };
      _setError('Failed to check permissions: $e');
    }
  }

  Future<void> requestPermissions() async {
    try {
      _permissions = await _permissionService.requestAllPermissions();
      notifyListeners();
    } catch (e) {
      // Initialize with default values if permission request fails
      _permissions = {
        'camera': false,
        'location': false,
        'storage': false,
        'photos': false,
      };
      _setError('Failed to request permissions: $e');
    }
  }

  PhotoPoint? getPhotoPointById(String id) {
    try {
      return _photoPoints.firstWhere((point) => point.id == id);
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _databaseService.close();
    super.dispose();
  }
}
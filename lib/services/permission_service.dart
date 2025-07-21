import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  Future<bool> requestCameraPermission() async {
    await Permission.camera.request();
    await Future.delayed(const Duration(milliseconds: 200));
    return checkCameraPermission();
  }

  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    await Permission.location.request();
    await Future.delayed(const Duration(milliseconds: 200));
    return checkLocationPermission();
  }

  Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    await Permission.storage.request();
    await Future.delayed(const Duration(milliseconds: 200));
    return checkStoragePermission();
  }

  Future<bool> checkStoragePermission() async {
    final status = await Permission.storage.status;
    return status.isGranted;
  }

  Future<bool> requestPhotosPermission() async {
    await Permission.photos.request();
    await Future.delayed(const Duration(milliseconds: 200));
    return checkPhotosPermission();
  }

  Future<bool> checkPhotosPermission() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  Future<Map<String, bool>> requestAllPermissions() async {
    debugPrint('🔍 Requesting all permissions...');
    
    // Check if any permissions are permanently denied first
    final currentStatuses = await _getCurrentPermissionStatuses();
    final permanentlyDenied = <Permission>[];
    
    for (final entry in currentStatuses.entries) {
      if (entry.value.isPermanentlyDenied) {
        permanentlyDenied.add(entry.key);
      }
    }
    
    if (permanentlyDenied.isNotEmpty) {
      debugPrint('⚠️ Some permissions are permanently denied: ${permanentlyDenied.map((p) => p.toString()).join(', ')}');
      // For permanently denied permissions, we can't request them again
      // The user needs to go to settings
      return _buildPermissionMap(currentStatuses);
    }
    
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.location,
      Permission.storage,
      Permission.photos,
    ].request();

    debugPrint('📱 Camera status: ${statuses[Permission.camera]}');
    debugPrint('📍 Location status: ${statuses[Permission.location]}');
    debugPrint('💾 Storage status: ${statuses[Permission.storage]}');
    debugPrint('🖼️ Photos status: ${statuses[Permission.photos]}');

    // Wait a moment for iOS to process the permission changes
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Check actual current status instead of relying on request response
    final actualStatuses = await checkAllPermissions();
    
    return actualStatuses;
  }
  
  Future<Map<Permission, PermissionStatus>> _getCurrentPermissionStatuses() async {
    return {
      Permission.camera: await Permission.camera.status,
      Permission.location: await Permission.location.status,
      Permission.storage: await Permission.storage.status,
      Permission.photos: await Permission.photos.status,
    };
  }
  
  Map<String, bool> _buildPermissionMap(Map<Permission, PermissionStatus> statuses) {
    return {
      'camera': statuses[Permission.camera]?.isGranted ?? false,
      'location': statuses[Permission.location]?.isGranted ?? false,
      'storage': statuses[Permission.storage]?.isGranted ?? false,
      'photos': statuses[Permission.photos]?.isGranted ?? false,
    };
  }

  Future<Map<String, bool>> checkAllPermissions() async {
    debugPrint('🔍 Checking all permissions...');
    
    final cameraStatus = await Permission.camera.status;
    final locationStatus = await Permission.location.status;
    final storageStatus = await Permission.storage.status;
    final photosStatus = await Permission.photos.status;
    
    debugPrint('📱 Camera status: $cameraStatus');
    debugPrint('📍 Location status: $locationStatus');
    debugPrint('💾 Storage status: $storageStatus');
    debugPrint('🖼️ Photos status: $photosStatus');
    
    return {
      'camera': cameraStatus.isGranted,
      'location': locationStatus.isGranted,
      'storage': storageStatus.isGranted,
      'photos': photosStatus.isGranted,
    };
  }

  Future<bool> areAllPermissionsGranted() async {
    final permissions = await checkAllPermissions();
    return permissions.values.every((granted) => granted);
  }

  Future<List<String>> getMissingPermissions() async {
    final permissions = await checkAllPermissions();
    return permissions.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  String getPermissionDescription(String permissionName) {
    switch (permissionName) {
      case 'camera':
        return 'Camera access is required to take photos at monitoring points';
      case 'location':
        return 'Location access is required to record GPS coordinates and compass direction';
      case 'storage':
        return 'Storage access is required to save photos locally';
      case 'photos':
        return 'Photos access is required to save and manage photo files';
      default:
        return 'This permission is required for the app to function properly';
    }
  }


  Future<bool> shouldShowRationale(String permissionName) async {
    Permission permission;
    switch (permissionName) {
      case 'camera':
        permission = Permission.camera;
        break;
      case 'location':
        permission = Permission.location;
        break;
      case 'storage':
        permission = Permission.storage;
        break;
      case 'photos':
        permission = Permission.photos;
        break;
      default:
        return false;
    }
    
    final status = await permission.status;
    return status.isDenied && !status.isPermanentlyDenied;
  }

  Future<bool> isPermanentlyDenied(String permissionName) async {
    Permission permission;
    switch (permissionName) {
      case 'camera':
        permission = Permission.camera;
        break;
      case 'location':
        permission = Permission.location;
        break;
      case 'storage':
        permission = Permission.storage;
        break;
      case 'photos':
        permission = Permission.photos;
        break;
      default:
        return false;
    }
    
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }
}
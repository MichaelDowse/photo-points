import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Returns the appropriate storage/photos permission for the current platform
  /// On Android 13+ (API 33+), uses Permission.photos
  /// On older Android versions and iOS, uses Permission.storage
  List<Permission> get _storagePermissions {
    if (Platform.isAndroid) {
      // For Android 13+ we primarily use photos permission
      // but we'll check both to ensure compatibility
      return [Permission.photos, Permission.storage];
    } else {
      // iOS and other platforms
      return [Permission.photos];
    }
  }

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
    debugPrint('🔍 Requesting storage permissions...');

    // Request all relevant storage permissions for the platform
    for (final permission in _storagePermissions) {
      try {
        await permission.request();
        debugPrint('📱 Requested ${permission.toString()}');
      } catch (e) {
        debugPrint('⚠️ Failed to request ${permission.toString()}: $e');
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    return checkStoragePermission();
  }

  Future<bool> checkStoragePermission() async {
    debugPrint('🔍 Checking storage permissions...');

    // Check if ANY of the storage permissions are granted
    bool anyGranted = false;
    for (final permission in _storagePermissions) {
      try {
        final status = await permission.status;
        debugPrint('📱 ${permission.toString()} status: $status');
        if (status.isGranted) {
          anyGranted = true;
        }
      } catch (e) {
        debugPrint('⚠️ Failed to check ${permission.toString()}: $e');
      }
    }

    debugPrint('💾 Overall storage permission granted: $anyGranted');
    return anyGranted;
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
      debugPrint(
        '⚠️ Some permissions are permanently denied: ${permanentlyDenied.map((p) => p.toString()).join(', ')}',
      );
      // For permanently denied permissions, we can't request them again
      // The user needs to go to settings
      return _buildPermissionMap(currentStatuses);
    }

    // Request core permissions
    final corePermissions = [Permission.camera, Permission.location];

    final Map<Permission, PermissionStatus> statuses = await corePermissions
        .request();

    // Add storage permissions to the map
    for (final permission in _storagePermissions) {
      try {
        await permission.request();
        statuses[permission] = await permission.status;
      } catch (e) {
        debugPrint('⚠️ Failed to request ${permission.toString()}: $e');
      }
    }

    debugPrint('📱 Camera status: ${statuses[Permission.camera]}');
    debugPrint('📍 Location status: ${statuses[Permission.location]}');

    // Print storage permission statuses
    for (final permission in _storagePermissions) {
      debugPrint('💾 ${permission.toString()} status: ${statuses[permission]}');
    }

    // Wait a moment for iOS to process the permission changes
    await Future.delayed(const Duration(milliseconds: 500));

    // Check actual current status instead of relying on request response
    final actualStatuses = await checkAllPermissions();

    return actualStatuses;
  }

  Future<Map<Permission, PermissionStatus>>
  _getCurrentPermissionStatuses() async {
    final statuses = <Permission, PermissionStatus>{
      Permission.camera: await Permission.camera.status,
      Permission.location: await Permission.location.status,
    };

    // Add storage permissions
    for (final permission in _storagePermissions) {
      try {
        statuses[permission] = await permission.status;
      } catch (e) {
        debugPrint('⚠️ Failed to get status for ${permission.toString()}: $e');
      }
    }

    return statuses;
  }

  Map<String, bool> _buildPermissionMap(
    Map<Permission, PermissionStatus> statuses,
  ) {
    // Check if ANY of the storage permissions are granted
    bool storageGranted = false;
    bool photosGranted = false;

    for (final permission in _storagePermissions) {
      final status = statuses[permission];
      if (status?.isGranted == true) {
        if (permission == Permission.storage) {
          storageGranted = true;
        } else if (permission == Permission.photos) {
          photosGranted = true;
        }
      }
    }

    // For the UI, we'll show storage as granted if ANY storage permission is granted
    final effectiveStorageGranted = storageGranted || photosGranted;

    return {
      'camera': statuses[Permission.camera]?.isGranted ?? false,
      'location': statuses[Permission.location]?.isGranted ?? false,
      'storage': effectiveStorageGranted,
      'photos': photosGranted,
    };
  }

  Future<Map<String, bool>> checkAllPermissions() async {
    debugPrint('🔍 Checking all permissions...');

    final cameraStatus = await Permission.camera.status;
    final locationStatus = await Permission.location.status;

    debugPrint('📱 Camera status: $cameraStatus');
    debugPrint('📍 Location status: $locationStatus');

    // Check storage permissions using the helper method
    final storageGranted = await checkStoragePermission();
    final photosGranted = await checkPhotosPermission();

    return {
      'camera': cameraStatus.isGranted,
      'location': locationStatus.isGranted,
      'storage': storageGranted,
      'photos': photosGranted,
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
    switch (permissionName) {
      case 'camera':
        final status = await Permission.camera.status;
        return status.isDenied && !status.isPermanentlyDenied;
      case 'location':
        final status = await Permission.location.status;
        return status.isDenied && !status.isPermanentlyDenied;
      case 'storage':
        // Check if ANY of the storage permissions should show rationale
        for (final permission in _storagePermissions) {
          try {
            final status = await permission.status;
            if (status.isDenied && !status.isPermanentlyDenied) {
              return true;
            }
          } catch (e) {
            debugPrint(
              '⚠️ Failed to check rationale for ${permission.toString()}: $e',
            );
          }
        }
        return false;
      case 'photos':
        final status = await Permission.photos.status;
        return status.isDenied && !status.isPermanentlyDenied;
      default:
        return false;
    }
  }

  Future<bool> isPermanentlyDenied(String permissionName) async {
    switch (permissionName) {
      case 'camera':
        final status = await Permission.camera.status;
        return status.isPermanentlyDenied;
      case 'location':
        final status = await Permission.location.status;
        return status.isPermanentlyDenied;
      case 'storage':
        // Check if ALL storage permissions are permanently denied
        bool allPermanentlyDenied = true;
        for (final permission in _storagePermissions) {
          try {
            final status = await permission.status;
            if (!status.isPermanentlyDenied) {
              allPermanentlyDenied = false;
              break;
            }
          } catch (e) {
            debugPrint(
              '⚠️ Failed to check permanently denied for ${permission.toString()}: $e',
            );
            allPermanentlyDenied = false;
          }
        }
        return allPermanentlyDenied;
      case 'photos':
        final status = await Permission.photos.status;
        return status.isPermanentlyDenied;
      default:
        return false;
    }
  }
}

import 'package:mockito/mockito.dart';
import 'package:photopoints/services/location_service.dart';
import 'package:photopoints/services/compass_service.dart';
import 'package:photopoints/services/photo_service.dart';
import 'package:photopoints/services/permission_service.dart';
import 'package:photopoints/models/location_data.dart';
import 'package:photopoints/models/compass_data.dart';
import 'package:camera/camera.dart';

class MockLocationService extends Mock implements LocationService {
  LocationData? _mockLocationData;
  
  void setMockLocationData(LocationData locationData) {
    _mockLocationData = locationData;
  }
  
  @override
  Future<LocationData?> getCurrentLocation() async {
    return _mockLocationData;
  }
  
  Stream<LocationData> get locationStream => Stream.value(_mockLocationData!);
}

class MockCompassService extends Mock implements CompassService {
  CompassData? _mockCompassData;
  
  void setMockCompassData(CompassData compassData) {
    _mockCompassData = compassData;
  }
  
  Future<CompassData?> getCurrentCompassData() async {
    return _mockCompassData;
  }
  
  Stream<CompassData> get compassStream => Stream.value(_mockCompassData!);
}

class MockPhotoService extends Mock implements PhotoService {
  bool _isCameraInitialized = false;
  List<CameraDescription> _mockCameras = [];
  
  void setMockCameras(List<CameraDescription> cameras) {
    _mockCameras = cameras;
    _isCameraInitialized = true;
  }
  
  @override
  Future<void> initializeCameras() async {
    _isCameraInitialized = true;
  }
  
  @override
  List<CameraDescription> get cameras => _mockCameras;
  
  bool get isCameraInitialized => _isCameraInitialized;
  
  @override
  Future<String?> capturePhoto({
    required String photoPointId,
    required String photoId,
  }) async {
    return 'mock_photo_path.jpg';
  }
}

class MockPermissionService extends Mock implements PermissionService {
  Map<String, bool> _permissions = {};
  
  void setMockPermissions(Map<String, bool> permissions) {
    _permissions = permissions;
  }
  
  @override
  Future<bool> checkLocationPermission() async {
    return _permissions['location'] ?? false;
  }
  
  @override
  Future<bool> checkCameraPermission() async {
    return _permissions['camera'] ?? false;
  }
  
  @override
  Future<bool> requestLocationPermission() async {
    _permissions['location'] = true;
    return true;
  }
  
  @override
  Future<bool> requestCameraPermission() async {
    _permissions['camera'] = true;
    return true;
  }
  
  @override
  Future<Map<String, bool>> checkAllPermissions() async {
    return _permissions;
  }
}
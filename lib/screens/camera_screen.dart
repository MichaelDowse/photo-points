import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../models/location_data.dart';
import '../models/compass_data.dart';
import '../models/photo.dart';
import '../services/location_service.dart';
import '../services/compass_service.dart';
import '../services/photo_service.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/navigation_aids.dart';

class CameraScreen extends StatefulWidget {
  final String photoPointId;
  final bool isInitialPhoto;
  final String? initialPhotoPath;
  final double? targetLatitude;
  final double? targetLongitude;
  final double? targetCompassDirection;
  final PhotoOrientation? targetOrientation;

  const CameraScreen({
    super.key,
    required this.photoPointId,
    required this.isInitialPhoto,
    this.initialPhotoPath,
    this.targetLatitude,
    this.targetLongitude,
    this.targetCompassDirection,
    this.targetOrientation,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final LocationService _locationService = LocationService();
  final CompassService _compassService = CompassService();
  final PhotoService _photoService = PhotoService();
  final Uuid _uuid = const Uuid();

  CameraController? _controller;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _showOverlay = true;
  
  LocationData? _currentLocation;
  CompassData? _currentCompass;
  PhotoOrientation? _currentOrientation;
  
  StreamSubscription<LocationData>? _locationSubscription;
  StreamSubscription<CompassData>? _compassSubscription;
  Timer? _orientationTimer;
  
  String? _error;

  @override
  void initState() {
    super.initState();
    _enableLandscapeMode();
    _initializeCamera();
    _startLocationUpdates();
    _startCompassUpdates();
    _updateCurrentOrientation();
    _startOrientationUpdates();
  }

  @override
  void dispose() {
    _restorePortraitMode();
    _controller?.dispose();
    _locationSubscription?.cancel();
    _compassSubscription?.cancel();
    _orientationTimer?.cancel();
    _compassService.dispose();
    super.dispose();
  }

  Future<void> _enableLandscapeMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _restorePortraitMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> _initializeCamera() async {
    try {
      final controller = await _photoService.initializeCamera();
      if (controller != null) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
      } else {
        setState(() {
          _error = 'Failed to initialize camera';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Camera error: $e';
      });
    }
  }

  void _startLocationUpdates() {
    _locationSubscription = _locationService.getLocationStream().listen(
      (location) {
        if (mounted) {
          setState(() {
            _currentLocation = location;
          });
        }
      },
      onError: (error) {
        debugPrint('Location error: $error');
      },
    );
  }

  void _startCompassUpdates() {
    _compassSubscription = _compassService.getCompassStream().listen(
      (compass) {
        if (mounted) {
          setState(() {
            _currentCompass = compass;
          });
        }
      },
      onError: (error) {
        debugPrint('Compass error: $error');
      },
    );
  }

  void _updateCurrentOrientation() {
    if (mounted) {
      setState(() {
        _currentOrientation = _photoService.getCurrentOrientation();
      });
    }
  }

  void _startOrientationUpdates() {
    _orientationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _updateCurrentOrientation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.isInitialPhoto ? 'Initial Photo' : 'Progress Photo'),
        actions: [
          if (!widget.isInitialPhoto)
            IconButton(
              icon: Icon(
                _showOverlay ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showOverlay = !_showOverlay;
                });
              },
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorWidget();
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.previewSize?.height ?? 1,
              height: _controller!.value.previewSize?.width ?? 1,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
        
        // Photo overlay for subsequent photos
        if (!widget.isInitialPhoto && _showOverlay && widget.initialPhotoPath != null)
          Positioned.fill(
            child: CameraOverlay(
              initialPhotoPath: widget.initialPhotoPath!,
              opacity: 0.5,
            ),
          ),
        
        // Navigation aids for subsequent photos
        if (!widget.isInitialPhoto)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: NavigationAids(
              currentLocation: _currentLocation,
              currentCompass: _currentCompass,
              targetLatitude: widget.targetLatitude,
              targetLongitude: widget.targetLongitude,
              targetCompassDirection: widget.targetCompassDirection,
              targetOrientation: widget.targetOrientation,
              currentOrientation: _currentOrientation,
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _error = null;
              });
              _initializeCamera();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Capture button with semi-transparent background
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _isCapturing ? null : _capturePhoto,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 3,
                        ),
                      ),
                      child: _isCapturing
                          ? const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 28,
                              color: Colors.black,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // Get current location and compass
      final location = await _locationService.getCurrentLocation();
      final compass = await _compassService.getCurrentHeading();

      if (location == null) {
        throw Exception('Unable to get current location');
      }

      if (compass == null) {
        throw Exception('Unable to get compass direction');
      }

      // Get current orientation
      final orientation = _photoService.getCurrentOrientation();

      // Capture the photo
      final photoId = _uuid.v4();
      final photoPath = await _photoService.capturePhoto(
        photoPointId: widget.photoPointId,
        photoId: photoId,
      );

      if (photoPath == null) {
        throw Exception('Failed to capture photo');
      }

      // Return the result
      final result = {
        'photoPath': photoPath,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'compassDirection': compass.normalizedHeading,
        'orientation': orientation,
      };

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }
}
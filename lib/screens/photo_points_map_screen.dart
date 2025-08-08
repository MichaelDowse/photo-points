import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/photo_point.dart';
import '../models/location_data.dart';
import '../services/location_service.dart';
import '../widgets/permissions_dialog.dart';
import 'add_photo_point_screen.dart';

class PhotoPointsMapScreen extends StatefulWidget {
  const PhotoPointsMapScreen({super.key});

  @override
  State<PhotoPointsMapScreen> createState() => _PhotoPointsMapScreenState();
}

class _PhotoPointsMapScreenState extends State<PhotoPointsMapScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  LocationData? _currentLocation;
  bool _isLoadingLocation = false;
  String? _locationError;

  // Default center (will be updated when location is obtained)
  LatLng _mapCenter = const LatLng(
    37.7749,
    -122.4194,
  ); // San Francisco as default

  static const double _defaultZoom = 15.0;
  static const double _maxZoom = 18.0;
  static const double _minZoom = 3.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  Future<void> _initializeMap() async {
    final appState = context.read<AppStateProvider>();

    // Check permissions first
    await appState.checkPermissions();

    // Show permissions dialog if location permission not granted
    if (!(appState.permissions['location'] ?? false)) {
      if (mounted) {
        await _showPermissionsDialog();
      }
    }

    // Load photo points
    await appState.loadPhotoPoints();

    // Get current location
    await _getCurrentLocation();
  }

  Future<void> _showPermissionsDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PermissionsDialog(),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null && mounted) {
        setState(() {
          _currentLocation = location;
          _mapCenter = LatLng(location.latitude, location.longitude);
          _isLoadingLocation = false;
        });

        // Move map to current location
        _mapController.move(_mapCenter, _defaultZoom);
      } else {
        setState(() {
          _locationError = 'Unable to get current location';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationError = 'Location error: ${e.toString()}';
        _isLoadingLocation = false;
      });
    }
  }

  List<PhotoPoint> _getPhotoPointsWithCoordinates() {
    final appState = context.read<AppStateProvider>();
    return appState.photoPoints.where((point) => point.hasLocation).toList();
  }

  List<Marker> _buildMarkers() {
    final photoPointsWithCoordinates = _getPhotoPointsWithCoordinates();

    List<Marker> markers = [];

    // Add current location marker
    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: LatLng(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          ),
          child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
        ),
      );
    }

    // Add photo point markers
    for (final photoPoint in photoPointsWithCoordinates) {
      markers.add(
        Marker(
          point: LatLng(photoPoint.latitude!, photoPoint.longitude!),
          child: GestureDetector(
            onTap: () => _onMarkerTap(photoPoint),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.photo_camera,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  void _onMarkerTap(PhotoPoint photoPoint) {
    Navigator.pushNamed(
      context,
      '/photo_point_detail',
      arguments: photoPoint.id,
    );
  }

  void _onMyLocationPressed() {
    if (_currentLocation != null) {
      _mapController.move(
        LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        _defaultZoom,
      );
    } else {
      _getCurrentLocation();
    }
  }

  void _navigateToAddPhotoPoint() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPhotoPointScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Points Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _onMyLocationPressed,
            tooltip: 'Go to my location',
          ),
        ],
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          if (appState.error != null) {
            return _buildErrorWidget(appState.error!);
          }

          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final photoPointsWithCoordinates = _getPhotoPointsWithCoordinates();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _mapCenter,
                  initialZoom: _defaultZoom,
                  maxZoom: _maxZoom,
                  minZoom: _minZoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.photopoints',
                  ),
                  MarkerLayer(markers: _buildMarkers()),
                ],
              ),

              // Loading indicator for location
              if (_isLoadingLocation)
                const Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Getting current location...'),
                        ],
                      ),
                    ),
                  ),
                ),

              // Location error
              if (_locationError != null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _locationError!,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => _locationError = null),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Empty state when no photo points with coordinates
              if (photoPointsWithCoordinates.isEmpty && !appState.isLoading)
                Center(
                  child: Card(
                    margin: const EdgeInsets.all(32),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Photo Points with Coordinates',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Photo points without GPS coordinates will not appear on the map.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_photo_point_map",
        onPressed: _navigateToAddPhotoPoint,
        tooltip: 'Add Photo Point',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<AppStateProvider>().clearError();
                  _initializeMap();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

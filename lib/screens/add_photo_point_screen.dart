import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../providers/app_state_provider.dart';
import '../models/photo_point.dart';
import '../models/photo.dart';
import '../services/photo_service.dart';
import 'camera_screen.dart';

class AddPhotoPointScreen extends StatefulWidget {
  const AddPhotoPointScreen({super.key});

  @override
  State<AddPhotoPointScreen> createState() => _AddPhotoPointScreenState();
}

class _AddPhotoPointScreenState extends State<AddPhotoPointScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _uuid = const Uuid();
  
  final PhotoService _photoService = PhotoService();
  
  String? _capturedPhotoPath;
  double? _latitude;
  double? _longitude;
  double? _compassDirection;
  PhotoOrientation? _orientation;
  bool _isCapturing = false;
  bool _isSelectingFromLibrary = false;
  bool _isFromLibrary = false;

  bool get _canSave => _capturedPhotoPath != null && 
                      _nameController.text.trim().isNotEmpty &&
                      !_isCapturing && 
                      !_isSelectingFromLibrary;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('New Photo Point'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: _canSave ? _savePhotoPoint : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSave ? Colors.orange : Colors.grey[400],
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: _canSave ? Colors.orange.withValues(alpha: 0.4) : Colors.grey.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            _buildPhotoSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildFormSection(),
            const SizedBox(height: 48), // Extra bottom padding for better scrolling
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_capturedPhotoPath != null)
              _buildPhotoPreview()
            else
              _buildCameraButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: _getImageProvider(_capturedPhotoPath!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _isFromLibrary ? _selectFromLibrary : _retakePhoto,
              icon: Icon(_isFromLibrary ? Icons.photo_library : Icons.camera_alt),
              label: Text(_isFromLibrary ? 'Reselect' : 'Retake'),
            ),
            TextButton.icon(
              onPressed: _removePhoto,
              icon: const Icon(Icons.delete),
              label: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCameraButton() {
    return Center(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add initial photo',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isCapturing || _isSelectingFromLibrary ? null : _capturePhoto,
                  icon: _isCapturing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt),
                  label: Text(_isCapturing ? 'Capturing...' : 'Take Photo'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isCapturing || _isSelectingFromLibrary ? null : _selectFromLibrary,
                  icon: _isSelectingFromLibrary
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.photo_library),
                  label: Text(_isSelectingFromLibrary ? 'Selecting...' : 'From Library'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location & Direction',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (_latitude != null && _longitude != null)
              Column(
                children: [
                  _buildLocationInfo(
                    Icons.location_on,
                    'GPS Coordinates',
                    '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                  ),
                  if (_compassDirection != null) ...[
                    const SizedBox(height: 12),
                    _buildLocationInfo(
                      Icons.explore,
                      'Compass Direction',
                      _formatCompassDirection(_compassDirection!),
                    ),
                  ],
                  if (_compassDirection == null) ...[
                    const SizedBox(height: 12),
                    _buildLocationInfo(
                      Icons.explore_off,
                      'Compass Direction',
                      'Not available (library photo)',
                    ),
                  ],
                ],
              )
            else
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isFromLibrary 
                          ? 'Location will be extracted from photo metadata if available'
                          : 'Location will be recorded when you take the photo',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Photo Point Name',
                hintText: 'Enter a name for this photo point',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any notes about this location',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    setState(() {
      _isCapturing = true;
    });

    try {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            photoPointId: _uuid.v4(),
            isInitialPhoto: true,
          ),
        ),
      );

      if (result != null) {
        setState(() {
          _capturedPhotoPath = result['photoPath'];
          _latitude = result['latitude'];
          _longitude = result['longitude'];
          _compassDirection = result['compassDirection'];
          _orientation = result['orientation'] as PhotoOrientation?;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing photo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  void _retakePhoto() {
    _capturePhoto();
  }

  void _removePhoto() {
    setState(() {
      _capturedPhotoPath = null;
      _latitude = null;
      _longitude = null;
      _compassDirection = null;
      _orientation = null;
      _isFromLibrary = false;
    });
  }

  Future<void> _selectFromLibrary() async {
    setState(() {
      _isSelectingFromLibrary = true;
    });

    try {
      final selectedImage = await _photoService.pickImageFromLibrary();
      if (selectedImage != null) {
        // Extract GPS coordinates from EXIF data
        final gpsData = await _photoService.extractGpsFromImage(selectedImage.path);
        
        setState(() {
          _capturedPhotoPath = selectedImage.path;
          _latitude = gpsData['latitude'];
          _longitude = gpsData['longitude'];
          _compassDirection = null; // Always null for library photos
          _orientation = PhotoOrientation.portrait; // Default for library photos
          _isFromLibrary = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting photo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isSelectingFromLibrary = false;
      });
    }
  }

  Future<void> _savePhotoPoint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_capturedPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo first')),
      );
      return;
    }

    try {
      final photoPointId = _uuid.v4();
      final photoId = _uuid.v4();
      
      String? finalPhotoPath;
      DateTime photoTakenAt;
      
      if (_isFromLibrary) {
        // Copy library photo to app storage
        finalPhotoPath = await _photoService.copyLibraryPhotoToStorage(
          sourcePath: _capturedPhotoPath!,
          photoPointId: photoPointId,
          photoId: photoId,
        );
        
        // Try to extract original date from EXIF, fallback to now
        final originalDate = await _photoService.extractDateTimeFromImage(_capturedPhotoPath!);
        photoTakenAt = originalDate ?? DateTime.now();
      } else {
        // Photo is already in the right location from camera
        finalPhotoPath = _capturedPhotoPath!;
        photoTakenAt = DateTime.now();
      }
      
      if (finalPhotoPath == null) {
        throw Exception('Failed to process photo');
      }
      
      final photo = Photo(
        id: photoId,
        photoPointId: photoPointId,
        filePath: finalPhotoPath,
        latitude: _latitude ?? 0.0, // Use 0.0 as fallback, will be updated later
        longitude: _longitude ?? 0.0,
        compassDirection: _compassDirection ?? 0.0,
        takenAt: photoTakenAt,
        isInitial: true,
        orientation: _orientation ?? PhotoOrientation.portrait,
      );

      final photoPoint = PhotoPoint(
        id: photoPointId,
        name: _nameController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        compassDirection: _compassDirection,
        createdAt: DateTime.now(),
        photos: [photo],
      );

      if (mounted) {
        await context.read<AppStateProvider>().addPhotoPoint(photoPoint);
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving photo point: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatCompassDirection(double direction) {
    final normalizedDirection = direction % 360;
    final cardinalDirection = _getCardinalDirection(normalizedDirection);
    return '$cardinalDirection ${normalizedDirection.toStringAsFixed(1)}°';
  }

  ImageProvider _getImageProvider(String filePath) {
    if (kIsWeb) {
      return NetworkImage(filePath);
    } else {
      return FileImage(File(filePath));
    }
  }

  String _getCardinalDirection(double direction) {
    if (direction >= 348.75 || direction < 11.25) {
      return 'N';
    } else if (direction >= 11.25 && direction < 33.75) {
      return 'NNE';
    } else if (direction >= 33.75 && direction < 56.25) {
      return 'NE';
    } else if (direction >= 56.25 && direction < 78.75) {
      return 'ENE';
    } else if (direction >= 78.75 && direction < 101.25) {
      return 'E';
    } else if (direction >= 101.25 && direction < 123.75) {
      return 'ESE';
    } else if (direction >= 123.75 && direction < 146.25) {
      return 'SE';
    } else if (direction >= 146.25 && direction < 168.75) {
      return 'SSE';
    } else if (direction >= 168.75 && direction < 191.25) {
      return 'S';
    } else if (direction >= 191.25 && direction < 213.75) {
      return 'SSW';
    } else if (direction >= 213.75 && direction < 236.25) {
      return 'SW';
    } else if (direction >= 236.25 && direction < 258.75) {
      return 'WSW';
    } else if (direction >= 258.75 && direction < 281.25) {
      return 'W';
    } else if (direction >= 281.25 && direction < 303.75) {
      return 'WNW';
    } else if (direction >= 303.75 && direction < 326.25) {
      return 'NW';
    } else {
      return 'NNW';
    }
  }
}
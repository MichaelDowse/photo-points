import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../providers/app_state_provider.dart';
import '../models/photo_point.dart';
import '../models/photo.dart';
import '../services/photo_service.dart';
import '../widgets/photo_grid.dart';
import '../widgets/confirmation_dialog.dart';
import 'camera_screen.dart';

class ShowPhotoPointScreen extends StatefulWidget {
  final String photoPointId;

  const ShowPhotoPointScreen({
    super.key,
    required this.photoPointId,
  });

  @override
  State<ShowPhotoPointScreen> createState() => _ShowPhotoPointScreenState();
}

class _ShowPhotoPointScreenState extends State<ShowPhotoPointScreen> {
  final PhotoService _photoService = PhotoService();
  final Uuid _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final photoPoint = appState.getPhotoPointById(widget.photoPointId);
        
        if (photoPoint == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Photo Point Not Found')),
            body: const Center(
              child: Text('Photo point not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(photoPoint.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuSelection(value, photoPoint),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('Share Photo Point'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'share_with_watermark',
                    child: Row(
                      children: [
                        Icon(Icons.water_drop, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('Share with Watermark'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Photo Point', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDetailsCard(photoPoint),
              const SizedBox(height: 16),
              _buildPhotosSection(photoPoint),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: "add_photo",
            onPressed: () => _addNewPhoto(photoPoint),
            tooltip: 'Add Photo',
            child: const Icon(Icons.add_a_photo),
          ),
        );
      },
    );
  }

  Widget _buildDetailsCard(PhotoPoint photoPoint) {
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
            _buildDetailRow(
              Icons.location_on,
              'GPS Coordinates',
              photoPoint.initialPhoto?.latitude.toStringAsFixed(6) ?? 'N/A',
              photoPoint.initialPhoto?.longitude.toStringAsFixed(6) ?? 'N/A',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.explore,
              'Compass Direction',
              photoPoint.compassDisplayText ?? 'Not available',
              null,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.calendar_today,
              'Created',
              _formatDate(photoPoint.createdAt),
              null,
            ),
            if (photoPoint.notes != null && photoPoint.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                photoPoint.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value1,
    String? value2,
  ) {
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
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value2 != null ? '$value1, $value2' : value1,
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

  Widget _buildPhotosSection(PhotoPoint photoPoint) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Photos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                Text(
                  '${photoPoint.photos.length} photo${photoPoint.photos.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (photoPoint.photos.isEmpty)
              _buildEmptyPhotosState()
            else
              PhotoGrid(
                photos: photoPoint.photos,
                onPhotoTap: _showPhotoDetails,
                onPhotoDelete: _deletePhoto,
                onPhotoShare: _sharePhoto,
                onPhotoShareWithWatermark: _sharePhotoWithWatermark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPhotosState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No photos taken yet',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the camera button to add your first photo',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value, PhotoPoint photoPoint) {
    switch (value) {
      case 'share':
        _sharePhotoPoint(photoPoint);
        break;
      case 'share_with_watermark':
        _sharePhotoPointWithWatermark(photoPoint);
        break;
      case 'delete':
        _deletePhotoPoint(photoPoint);
        break;
    }
  }

  Future<void> _sharePhotoPoint(PhotoPoint photoPoint) async {
    try {
      await _photoService.sharePhotoPoint(photoPoint);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing photo point: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _sharePhotoPointWithWatermark(PhotoPoint photoPoint) async {
    try {
      await _photoService.sharePhotoPoint(photoPoint, withWatermark: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing photo point with watermark: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deletePhotoPoint(PhotoPoint photoPoint) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Photo Point',
        content: 'Are you sure you want to delete "${photoPoint.name}"? This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        isDestructive: true,
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<AppStateProvider>().deletePhotoPoint(photoPoint.id);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting photo point: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _addNewPhoto(PhotoPoint photoPoint) async {
    try {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            photoPointId: photoPoint.id,
            isInitialPhoto: false,
            initialPhotoPath: photoPoint.initialPhoto?.filePath,
            targetLatitude: photoPoint.latitude,
            targetLongitude: photoPoint.longitude,
            targetCompassDirection: photoPoint.compassDirection,
            targetOrientation: photoPoint.initialPhoto?.orientation,
          ),
        ),
      );

      if (result != null) {
        final photo = Photo(
          id: _uuid.v4(),
          photoPointId: photoPoint.id,
          filePath: result['photoPath'],
          latitude: result['latitude'],
          longitude: result['longitude'],
          compassDirection: result['compassDirection'],
          takenAt: DateTime.now(),
          isInitial: false,
          orientation: result['orientation'] as PhotoOrientation? ?? PhotoOrientation.portrait,
        );

        if (mounted) {
          await context.read<AppStateProvider>().addPhotoToPoint(photoPoint.id, photo);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding photo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showPhotoDetails(Photo photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text('Photo Details'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildFullSizeImage(photo.filePath),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Taken: ${_formatDateTime(photo.takenAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'GPS: ${photo.latitude.toStringAsFixed(6)}, ${photo.longitude.toStringAsFixed(6)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Direction: ${_formatCompassDirection(photo.compassDirection)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (photo.isInitial)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Initial Photo',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePhoto(Photo photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Photo',
        content: 'Are you sure you want to delete this photo? This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        isDestructive: true,
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<AppStateProvider>().deletePhoto(photo.id, photo.filePath);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting photo: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _sharePhoto(Photo photo) async {
    try {
      final photoPoint = context.read<AppStateProvider>().getPhotoPointById(widget.photoPointId);
      await _photoService.sharePhoto(photo.filePath, 
          photoData: photo, 
          photoPointName: photoPoint?.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing photo: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _sharePhotoWithWatermark(Photo photo) async {
    try {
      final photoPoint = context.read<AppStateProvider>().getPhotoPointById(widget.photoPointId);
      await _photoService.sharePhoto(photo.filePath, 
          withWatermark: true, 
          photoData: photo, 
          photoPointName: photoPoint?.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing photo with watermark: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCompassDirection(double direction) {
    final normalizedDirection = direction % 360;
    final cardinalDirection = _getCardinalDirection(normalizedDirection);
    return '$cardinalDirection ${normalizedDirection.toStringAsFixed(1)}°';
  }

  Widget _buildFullSizeImage(String filePath) {
    if (kIsWeb) {
      return Image.network(
        filePath,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Theme.of(context).colorScheme.surface,
            child: const Center(
              child: Icon(Icons.broken_image, size: 64),
            ),
          );
        },
      );
    } else {
      return File(filePath).existsSync()
          ? Image.file(
              File(filePath),
              fit: BoxFit.cover,
              width: double.infinity,
            )
          : Container(
              height: 200,
              color: Theme.of(context).colorScheme.surface,
              child: const Center(
                child: Icon(Icons.broken_image, size: 64),
              ),
            );
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
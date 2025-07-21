import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/photo.dart';

class PhotoGrid extends StatelessWidget {
  final List<Photo> photos;
  final Function(Photo) onPhotoTap;
  final Function(Photo) onPhotoDelete;
  final Function(Photo) onPhotoShare;
  final Function(Photo)? onPhotoShareWithWatermark;

  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onPhotoTap,
    required this.onPhotoDelete,
    required this.onPhotoShare,
    this.onPhotoShareWithWatermark,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return _buildPhotoItem(context, photo);
      },
    );
  }

  Widget _buildPhotoItem(BuildContext context, Photo photo) {
    return GestureDetector(
      onTap: () => onPhotoTap(photo),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<bool>(
                future: _checkImageExists(photo.filePath),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return _buildImage(photo.filePath);
                  } else {
                    return _buildErrorPlaceholder(context);
                  }
                },
              ),
            ),
          ),
          
          // Initial photo badge
          if (photo.isInitial)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Initial',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // Date badge
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDate(photo.takenAt),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          
          // Action menu
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              onSelected: (value) => _handleMenuSelection(value, photo),
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Share'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'share_with_watermark',
                  child: Row(
                    children: [
                      Icon(Icons.water_drop, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Share with Watermark'),
                    ],
                  ),
                ),
                if (!photo.isInitial)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Image not found',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value, Photo photo) {
    switch (value) {
      case 'share':
        onPhotoShare(photo);
        break;
      case 'share_with_watermark':
        onPhotoShareWithWatermark?.call(photo);
        break;
      case 'delete':
        onPhotoDelete(photo);
        break;
    }
  }

  Widget _buildImage(String filePath) {
    if (kIsWeb) {
      return Image.network(
        filePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder(context);
        },
      );
    } else {
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder(context);
        },
      );
    }
  }

  Future<bool> _checkImageExists(String filePath) async {
    try {
      if (kIsWeb) {
        return filePath.isNotEmpty;
      } else {
        final file = File(filePath);
        return await file.exists();
      }
    } catch (e) {
      return false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
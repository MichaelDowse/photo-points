import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
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
    // Use a staggered grid to accommodate different aspect ratios
    return _buildStaggeredGrid(context);
  }

  Widget _buildStaggeredGrid(BuildContext context) {
    // For now, we'll use a custom layout that arranges photos in rows
    // with appropriate aspect ratios
    return SingleChildScrollView(
      child: Column(children: _buildPhotoRows(context)),
    );
  }

  List<Widget> _buildPhotoRows(BuildContext context) {
    final List<Widget> rows = [];

    for (int i = 0; i < photos.length; i += 2) {
      final List<Widget> rowChildren = [];

      // First photo in row
      final photo1 = photos[i];
      final isPortrait1 = photo1.orientation == PhotoOrientation.portrait;
      final flex1 = isPortrait1 ? 3 : 4; // Portrait takes less space

      rowChildren.add(
        Expanded(
          flex: flex1,
          child: AspectRatio(
            aspectRatio: isPortrait1
                ? 0.75
                : 1.33, // 3:4 for portrait, 4:3 for landscape
            child: _buildPhotoItem(context, photo1),
          ),
        ),
      );

      // Add spacing
      if (i + 1 < photos.length) {
        rowChildren.add(const SizedBox(width: 8));
      }

      // Second photo in row (if exists)
      if (i + 1 < photos.length) {
        final photo2 = photos[i + 1];
        final isPortrait2 = photo2.orientation == PhotoOrientation.portrait;
        final flex2 = isPortrait2 ? 3 : 4;

        rowChildren.add(
          Expanded(
            flex: flex2,
            child: AspectRatio(
              aspectRatio: isPortrait2 ? 0.75 : 1.33,
              child: _buildPhotoItem(context, photo2),
            ),
          ),
        );
      } else {
        // If odd number of photos, add spacer
        rowChildren.add(const Expanded(flex: 4, child: SizedBox()));
      }

      rows.add(Row(children: rowChildren));

      // Add spacing between rows
      if (i + 2 < photos.length) {
        rows.add(const SizedBox(height: 8));
      }
    }

    return rows;
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
                future: _checkPhotoExists(photo),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return _buildImage(photo);
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDate(photo.takenAt),
                style: const TextStyle(color: Colors.white, fontSize: 10),
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
                      Icon(
                        Icons.share,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('Share'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'share_with_watermark',
                  child: Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Image not found',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
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

  Widget _buildImage(Photo photo) {
    if (kIsWeb) {
      // On web, use network image with file path
      if (photo.filePath != null) {
        return Image.network(
          photo.filePath!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder(context);
          },
        );
      } else {
        return const Center(child: Text('No image'));
      }
    } else {
      // On native platforms, try asset ID first, then file path
      if (photo.assetId != null) {
        return FutureBuilder<AssetEntity?>(
          future: AssetEntity.fromId(photo.assetId!),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image(
                image: AssetEntityImageProvider(
                  snapshot.data!,
                  isOriginal: false,
                ),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Failed to load'));
                },
              );
            } else if (photo.filePath != null) {
              // Fallback to file path
              return Image.file(
                File(photo.filePath!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorPlaceholder(context);
                },
              );
            } else {
              return const Center(child: Text('Failed to load'));
            }
          },
        );
      } else if (photo.filePath != null) {
        return Image.file(
          File(photo.filePath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder(context);
          },
        );
      } else {
        return const Center(child: Text('No image'));
      }
    }
  }

  Future<bool> _checkPhotoExists(Photo photo) async {
    try {
      if (kIsWeb) {
        return photo.filePath?.isNotEmpty ?? false;
      } else {
        // Try asset ID first
        if (photo.assetId != null) {
          try {
            final asset = await AssetEntity.fromId(photo.assetId!);
            return asset != null;
          } catch (e) {
            // Fall through to file path check
          }
        }

        // Fallback to file path
        if (photo.filePath != null) {
          final file = File(photo.filePath!);
          return await file.exists();
        }

        return false;
      }
    } catch (e) {
      return false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

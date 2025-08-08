import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/photo_point.dart';

class PhotoPointCard extends StatelessWidget {
  final PhotoPoint photoPoint;
  final VoidCallback onTap;

  const PhotoPointCard({
    super.key,
    required this.photoPoint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          photoPoint.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created: ${_formatDate(photoPoint.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (photoPoint.initialPhoto?.filePath != null)
                    _buildThumbnail(
                      context,
                      photoPoint.initialPhoto!.filePath!,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                photoPoint.hasLocation ? Icons.location_on : Icons.location_off,
                photoPoint.hasLocation
                    ? '${photoPoint.latitude!.toStringAsFixed(6)}, ${photoPoint.longitude!.toStringAsFixed(6)}'
                    : 'Location not available',
                null,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                photoPoint.hasCompassDirection
                    ? Icons.explore
                    : Icons.explore_off,
                photoPoint.compassDisplayText ?? 'Direction not available',
                null,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.photo_camera,
                '${photoPoint.photos.length} photo${photoPoint.photos.length == 1 ? '' : 's'}',
                null,
              ),
              if (photoPoint.notes != null && photoPoint.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  photoPoint.notes!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, String filePath) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FutureBuilder<bool>(
          future: _checkImageExists(filePath),
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return _buildThumbnailImage(context, filePath);
            } else {
              return _buildThumbnailPlaceholder(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Icon(
        Icons.photo,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String text1,
    String? text2,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text2 != null ? '$text1, $text2' : text1,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildThumbnailImage(BuildContext context, String filePath) {
    if (kIsWeb) {
      return Image.network(
        filePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildThumbnailPlaceholder(context);
        },
      );
    } else {
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildThumbnailPlaceholder(context);
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
}

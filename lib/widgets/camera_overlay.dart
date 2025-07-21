import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class CameraOverlay extends StatelessWidget {
  final String initialPhotoPath;
  final double opacity;

  const CameraOverlay({
    super.key,
    required this.initialPhotoPath,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkImageExists(initialPhotoPath),
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return const SizedBox.shrink();
        }

        return Opacity(
          opacity: opacity,
          child: FittedBox(
            fit: BoxFit.cover,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _getImageProvider(initialPhotoPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ImageProvider _getImageProvider(String filePath) {
    if (kIsWeb) {
      return NetworkImage(filePath);
    } else {
      return FileImage(File(filePath));
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
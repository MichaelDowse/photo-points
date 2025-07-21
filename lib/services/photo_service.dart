import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../models/photo.dart';
import '../models/photo_point.dart';

class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  List<CameraDescription> cameras = [];
  CameraController? _controller;
  final ImagePicker _picker = ImagePicker();
  
  Future<void> initializeCameras() async {
    try {
      cameras = await availableCameras();
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
    }
  }

  Future<CameraController?> initializeCamera({
    CameraDescription? camera,
    ResolutionPreset resolutionPreset = ResolutionPreset.max,
  }) async {
    try {
      if (cameras.isEmpty) {
        await initializeCameras();
      }
      
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      final selectedCamera = camera ?? cameras.first;
      
      _controller = CameraController(
        selectedCamera,
        resolutionPreset,
        enableAudio: false,
      );

      await _controller!.initialize();
      return _controller;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      return null;
    }
  }

  Future<String?> capturePhoto({
    required String photoPointId,
    required String photoId,
  }) async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        throw Exception('Camera is not initialized');
      }

      final XFile imageFile = await _controller!.takePicture();
      
      if (kIsWeb) {
        // On web, return the blob URL as is
        return imageFile.path;
      } else {
        // On native platforms, copy to app directory
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String photoDir = join(appDir.path, 'photos', photoPointId);
        
        // Create directory if it doesn't exist
        await Directory(photoDir).create(recursive: true);
        
        final String filePath = join(photoDir, '$photoId.jpg');
        
        // Move the file to our designated location
        await File(imageFile.path).copy(filePath);
        await File(imageFile.path).delete();
        
        return filePath;
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      return null;
    }
  }

  Future<File?> getPhotoFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting photo file: $e');
      return null;
    }
  }

  Future<Uint8List?> getPhotoBytes(String filePath) async {
    try {
      if (kIsWeb) {
        // On web, use XFile to read bytes from blob URL
        final xFile = XFile(filePath);
        return await xFile.readAsBytes();
      } else {
        final file = await getPhotoFile(filePath);
        if (file != null) {
          return await file.readAsBytes();
        }
        return null;
      }
    } catch (e) {
      debugPrint('Error getting photo bytes: $e');
      return null;
    }
  }

  Future<img.Image?> getPhotoImage(String filePath) async {
    try {
      final bytes = await getPhotoBytes(filePath);
      if (bytes != null) {
        return img.decodeImage(bytes);
      }
      return null;
    } catch (e) {
      debugPrint('Error decoding photo image: $e');
      return null;
    }
  }

  Future<String?> resizePhoto(String filePath, {int maxWidth = 1024, int maxHeight = 1024}) async {
    try {
      final image = await getPhotoImage(filePath);
      if (image == null) return null;

      final resized = img.copyResize(
        image,
        width: maxWidth,
        height: maxHeight,
        maintainAspect: true,
      );

      final resizedBytes = img.encodeJpg(resized, quality: 85);
      await File(filePath).writeAsBytes(resizedBytes);
      
      return filePath;
    } catch (e) {
      debugPrint('Error resizing photo: $e');
      return null;
    }
  }

  Future<bool> deletePhoto(String filePath) async {
    try {
      if (kIsWeb) {
        // On web, we can't delete blob URLs, so just return true
        debugPrint('Delete not supported on web platform');
        return true;
      }
      
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      return false;
    }
  }

  Future<bool> deletePhotoPointPhotos(String photoPointId) async {
    try {
      if (kIsWeb) {
        // On web, we can't delete blob URLs, so just return true
        debugPrint('Delete not supported on web platform');
        return true;
      }
      
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String photoDir = join(appDir.path, 'photos', photoPointId);
      final Directory dir = Directory(photoDir);
      
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting photo point photos: $e');
      return false;
    }
  }

  Future<void> sharePhoto(String filePath, {bool withWatermark = false, Photo? photoData, String? photoPointName}) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        String? shareFilePath = filePath;
        String? tempFilePath;
        
        if (withWatermark && photoData != null) {
          final watermarkedPath = await _createWatermarkedPhoto(filePath, photoData);
          if (watermarkedPath != null) {
            shareFilePath = watermarkedPath;
            tempFilePath = watermarkedPath;
          }
        }
        
        if (photoData != null && photoPointName != null) {
          final customFilename = generateShareFilename(photoPointName, photoData.takenAt);
          await Share.shareXFiles([XFile(shareFilePath, name: '$customFilename.jpg')]);
        } else {
          await Share.shareXFiles([XFile(shareFilePath)]);
        }
        
        if (tempFilePath != null) {
          await File(tempFilePath).delete();
        }
      }
    } catch (e) {
      debugPrint('Error sharing photo: $e');
    }
  }

  Future<void> sharePhotoPoint(PhotoPoint photoPoint, {bool withWatermark = false}) async {
    try {
      if (photoPoint.photos.isEmpty) return;

      List<XFile> files = [];
      List<String> tempFiles = [];
      
      for (int i = 0; i < photoPoint.photos.length; i++) {
        final Photo photo = photoPoint.photos[i];
        final file = File(photo.filePath);
        if (await file.exists()) {
          String? shareFilePath = photo.filePath;
          
          if (withWatermark) {
            final watermarkedPath = await _createWatermarkedPhoto(photo.filePath, photo);
            if (watermarkedPath != null) {
              shareFilePath = watermarkedPath;
              tempFiles.add(watermarkedPath);
            }
          }
          
          final customFilename = generateShareFilename(photoPoint.name, photo.takenAt);
          final suffix = photoPoint.photos.length > 1 ? '_${i + 1}' : '';
          files.add(XFile(shareFilePath, name: '$customFilename$suffix.jpg'));
        }
      }

      if (files.isNotEmpty) {
        await Share.shareXFiles(files, text: 'Photo Point: ${photoPoint.name}');
        
        for (String tempFile in tempFiles) {
          await File(tempFile).delete();
        }
      }
    } catch (e) {
      debugPrint('Error sharing photo point: $e');
    }
  }

  Future<img.Image?> createOverlayImage(String baseImagePath, {double opacity = 0.5}) async {
    try {
      final baseImage = await getPhotoImage(baseImagePath);
      if (baseImage == null) return null;

      // Create a copy of the image with adjusted opacity
      final overlayImage = img.Image.from(baseImage);
      
      // Apply opacity to each pixel
      for (int y = 0; y < overlayImage.height; y++) {
        for (int x = 0; x < overlayImage.width; x++) {
          final pixel = overlayImage.getPixel(x, y);
          final newPixel = img.ColorRgba8(
            pixel.r.round(),
            pixel.g.round(),
            pixel.b.round(),
            (pixel.a * opacity).round(),
          );
          overlayImage.setPixel(x, y, newPixel);
        }
      }

      return overlayImage;
    } catch (e) {
      debugPrint('Error creating overlay image: $e');
      return null;
    }
  }

  Future<bool> photoExists(String filePath) async {
    try {
      if (kIsWeb) {
        // On web, assume blob URLs exist if they're not empty
        return filePath.isNotEmpty;
      }
      
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  Future<int> getPhotoFileSize(String filePath) async {
    try {
      if (kIsWeb) {
        // On web, we can't get file size from blob URLs, return 0
        return 0;
      }
      
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<XFile?> pickImageFromLibrary() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image;
    } catch (e) {
      debugPrint('Error picking image from library: $e');
      return null;
    }
  }

  Future<Map<String, double?>> extractGpsFromImage(String imagePath) async {
    try {
      if (kIsWeb) {
        // On web, EXIF extraction is not reliable, return null coordinates
        debugPrint('GPS extraction not supported on web platform');
        return {'latitude': null, 'longitude': null};
      }
      
      final bytes = await File(imagePath).readAsBytes();
      final data = await readExifFromBytes(bytes);
      
      if (data.isEmpty) {
        return {'latitude': null, 'longitude': null};
      }
      
      final gpsLat = data['GPS GPSLatitude'];
      final gpsLatRef = data['GPS GPSLatitudeRef'];
      final gpsLng = data['GPS GPSLongitude'];
      final gpsLngRef = data['GPS GPSLongitudeRef'];
      
      if (gpsLat == null || gpsLng == null) {
        return {'latitude': null, 'longitude': null};
      }
      
      double? latitude = _convertGpsCoordinate(gpsLat, gpsLatRef);
      double? longitude = _convertGpsCoordinate(gpsLng, gpsLngRef);
      
      return {'latitude': latitude, 'longitude': longitude};
    } catch (e) {
      debugPrint('Error extracting GPS data: $e');
      return {'latitude': null, 'longitude': null};
    }
  }

  double? _convertGpsCoordinate(dynamic coordinate, dynamic reference) {
    try {
      if (coordinate is IfdRatios && coordinate.ratios.length >= 3) {
        final degrees = coordinate.ratios[0].toDouble();
        final minutes = coordinate.ratios[1].toDouble();
        final seconds = coordinate.ratios[2].toDouble();
        
        double result = degrees + (minutes / 60.0) + (seconds / 3600.0);
        
        if (reference != null && (reference.printable == 'S' || reference.printable == 'W')) {
          result = -result;
        }
        
        return result;
      }
    } catch (e) {
      debugPrint('Error converting GPS coordinate: $e');
    }
    return null;
  }

  Future<DateTime?> extractDateTimeFromImage(String imagePath) async {
    try {
      if (kIsWeb) {
        // On web, EXIF extraction is not reliable, return current time
        debugPrint('Date extraction not supported on web platform, using current time');
        return DateTime.now();
      }
      
      final bytes = await File(imagePath).readAsBytes();
      final data = await readExifFromBytes(bytes);
      
      if (data.isEmpty) {
        return null;
      }
      
      final dateTime = data['EXIF DateTimeOriginal'] ?? data['Image DateTime'];
      if (dateTime != null) {
        // Parse EXIF date format: "YYYY:MM:DD HH:MM:SS"
        final dateStr = dateTime.printable.replaceFirst(':', '-').replaceFirst(':', '-');
        return DateTime.tryParse(dateStr);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error extracting date from image: $e');
      return null;
    }
  }

  Future<String?> copyLibraryPhotoToStorage({
    required String sourcePath,
    required String photoPointId,
    required String photoId,
  }) async {
    try {
      if (kIsWeb) {
        // On web, return the source path as is (blob URL)
        return sourcePath;
      }
      
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String photoDir = join(appDir.path, 'photos', photoPointId);
      
      // Create directory if it doesn't exist
      await Directory(photoDir).create(recursive: true);
      
      final String destinationPath = join(photoDir, '$photoId.jpg');
      
      // Copy and resize the image
      final bytes = await File(sourcePath).readAsBytes();
      var image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Resize if too large
      if (image.width > 1920 || image.height > 1920) {
        image = img.copyResize(
          image,
          width: 1920,
          height: 1920,
          maintainAspect: true,
        );
      }
      
      final compressedBytes = img.encodeJpg(image, quality: 85);
      await File(destinationPath).writeAsBytes(compressedBytes);
      
      return destinationPath;
    } catch (e) {
      debugPrint('Error copying library photo: $e');
      return null;
    }
  }

  Future<String?> _createWatermarkedPhoto(String originalPath, Photo photo) async {
    try {
      final image = await getPhotoImage(originalPath);
      if (image == null) return null;

      final watermarkedImage = await _addWatermark(image, photo);
      if (watermarkedImage == null) return null;

      if (kIsWeb) {
        // On web, we can't create temp files, so return null to skip watermarking
        debugPrint('Watermarking not supported on web platform');
        return null;
      }

      final Directory tempDir = await getTemporaryDirectory();
      final String watermarkedPath = join(tempDir.path, 'watermarked_${photo.id}.jpg');
      
      final jpgBytes = img.encodeJpg(watermarkedImage, quality: 85);
      await File(watermarkedPath).writeAsBytes(jpgBytes);
      
      return watermarkedPath;
    } catch (e) {
      debugPrint('Error creating watermarked photo: $e');
      return null;
    }
  }

  Future<img.Image?> _addWatermark(img.Image image, Photo photo) async {
    try {
      final watermarkedImage = img.Image.from(image);
      final imageWidth = watermarkedImage.width;
      final imageHeight = watermarkedImage.height;
      
      final fontSize = (imageWidth * 0.04).round().clamp(20, 40);
      final margin = (imageWidth * 0.03).round().clamp(15, 30);
      final textPadding = (fontSize * 0.3).round().clamp(3, 8);
      
      final watermarkText = _formatWatermarkText(photo);
      final lines = watermarkText.split('\n');
      
      final lineHeight = fontSize + 8;
      final totalTextHeight = lines.length * lineHeight;
      
      // Position text in bottom-left corner with margin from edges
      final startY = imageHeight - totalTextHeight - margin;
      
      int currentY = startY;
      for (String line in lines) {
        // Calculate text width for this line (approximate)
        final textWidth = line.length * (fontSize * 0.6).round();
        final backgroundWidth = textWidth + (textPadding * 2);
        final backgroundHeight = lineHeight;
        
        // Draw semitransparent background behind this line of text only
        for (int y = currentY - textPadding; y < currentY + backgroundHeight - textPadding; y++) {
          for (int x = margin - textPadding; x < margin + backgroundWidth - textPadding; x++) {
            if (x >= 0 && x < imageWidth && y >= 0 && y < imageHeight) {
              final originalPixel = watermarkedImage.getPixel(x, y);
              final originalRed = originalPixel.r.round();
              final originalGreen = originalPixel.g.round();
              final originalBlue = originalPixel.b.round();
              
              // Blend with semitransparent black (60% opacity)
              final alpha = 0.6;
              final blendedRed = ((1 - alpha) * originalRed).round();
              final blendedGreen = ((1 - alpha) * originalGreen).round();
              final blendedBlue = ((1 - alpha) * originalBlue).round();
              
              final blendedColor = img.ColorRgba8(blendedRed, blendedGreen, blendedBlue, 255);
              watermarkedImage.setPixel(x, y, blendedColor);
            }
          }
        }
        
        // Draw white text on top
        _drawSimpleText(
          watermarkedImage,
          line,
          margin,
          currentY,
          fontSize,
          img.ColorRgba8(255, 255, 255, 255),
        );
        currentY += lineHeight;
      }
      
      return watermarkedImage;
    } catch (e) {
      debugPrint('Error adding watermark: $e');
      return null;
    }
  }

  void _drawSimpleText(img.Image image, String text, int x, int y, int fontSize, img.Color color) {
    final font = img.arial14;
    
    try {
      img.drawString(
        image,
        text,
        font: font,
        x: x,
        y: y,
        color: color,
      );
    } catch (e) {
      debugPrint('Error drawing text: $e');
    }
  }

  String _formatWatermarkText(Photo photo) {
    final date = _formatDateTime(photo.takenAt);
    final coords = '${photo.latitude.toStringAsFixed(6)}, ${photo.longitude.toStringAsFixed(6)}';
    final direction = _formatCompassDirection(photo.compassDirection);
    
    return '$date\n$coords\n$direction';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatCompassDirection(double direction) {
    final normalizedDirection = direction % 360;
    final cardinalDirection = _getCardinalDirection(normalizedDirection);
    return '$cardinalDirection ${normalizedDirection.toStringAsFixed(1)}°';
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


  PhotoOrientation getCurrentOrientation() {
    // Try to get orientation from media query if available, otherwise use portrait as default
    try {
      final orientation = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
      if (orientation.width > orientation.height) {
        return PhotoOrientation.landscape;
      } else {
        return PhotoOrientation.portrait;
      }
    } catch (e) {
      debugPrint('Could not determine orientation, defaulting to portrait: $e');
      return PhotoOrientation.portrait;
    }
  }

  String generateShareFilename(String photoPointName, DateTime photoDate) {
    var sanitizedName = photoPointName
        .trim()
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    
    // Remove leading/trailing underscores and ensure we don't have an empty name
    sanitizedName = sanitizedName.replaceAll(RegExp(r'^_+|_+$'), '');
    
    if (sanitizedName.isEmpty) {
      sanitizedName = 'photo';
    }
    
    final dateStr = '${photoDate.year}'
        '${photoDate.month.toString().padLeft(2, '0')}'
        '${photoDate.day.toString().padLeft(2, '0')}';
    
    return '${sanitizedName}_$dateStr';
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
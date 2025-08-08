import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/compass_data.dart';
import 'dart:async';

class CompassService {
  static final CompassService _instance = CompassService._internal();
  factory CompassService() => _instance;
  CompassService._internal();

  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamController<CompassData>? _compassController;

  Future<bool> requestCompassPermission() async {
    // On iOS, we need location permission for compass
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> checkCompassPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<bool> isCompassAvailable() async {
    try {
      return FlutterCompass.events != null;
    } catch (e) {
      debugPrint('Error checking compass availability: $e');
      return false;
    }
  }

  Future<CompassData?> getCurrentHeading() async {
    try {
      // Check if compass is available
      bool available = await isCompassAvailable();
      if (!available) {
        throw Exception('Compass is not available on this device');
      }

      // Check permissions
      bool hasPermission = await checkCompassPermission();
      if (!hasPermission) {
        hasPermission = await requestCompassPermission();
        if (!hasPermission) {
          throw Exception('Compass permissions are denied');
        }
      }

      // Start the stream if not already running to ensure we use the same source
      getCompassStream();

      // Wait for the next compass reading from the SAME stream that navigation uses
      final compassData = await _compassController!.stream.first;
      return compassData;
    } catch (e) {
      debugPrint('Error getting compass heading: $e');
      return null;
    }
  }

  Stream<CompassData> getCompassStream() {
    _compassController ??= StreamController<CompassData>.broadcast();

    _compassSubscription ??= FlutterCompass.events?.listen((
      CompassEvent event,
    ) {
      if (event.heading != null) {
        final compassData = CompassData(
          heading: event.heading!,
          accuracy: event.accuracy ?? 0.0,
          timestamp: DateTime.now(),
        );
        _compassController?.add(compassData);
      }
    });

    return _compassController!.stream;
  }

  void stopCompassStream() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    _compassController?.close();
    _compassController = null;
  }

  double calculateHeadingDifference(
    double currentHeading,
    double targetHeading,
  ) {
    double diff = (targetHeading - currentHeading).abs();
    return diff > 180 ? 360 - diff : diff;
  }

  String getDirectionInstruction(double currentHeading, double targetHeading) {
    double normalizedCurrent = currentHeading % 360;
    double normalizedTarget = targetHeading % 360;

    if (normalizedCurrent < 0) normalizedCurrent += 360;
    if (normalizedTarget < 0) normalizedTarget += 360;

    double diff = normalizedTarget - normalizedCurrent;

    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }

    if (diff.abs() <= 1) {
      return 'Aligned';
    } else if (diff > 0) {
      return 'Turn right ${diff.toStringAsFixed(1)}°';
    } else {
      return 'Turn left ${(-diff).toStringAsFixed(1)}°';
    }
  }

  bool isAligned(
    double currentHeading,
    double targetHeading, {
    double tolerance = 1.0,
  }) {
    return calculateHeadingDifference(currentHeading, targetHeading) <=
        tolerance;
  }

  String getCompassAccuracyText(double accuracy) {
    if (accuracy <= 5) {
      return 'Very High';
    } else if (accuracy <= 15) {
      return 'High';
    } else if (accuracy <= 30) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  bool isCompassAccurate(double accuracy) {
    return accuracy <= 15.0; // Within 15 degrees is considered accurate
  }

  void dispose() {
    stopCompassStream();
  }
}

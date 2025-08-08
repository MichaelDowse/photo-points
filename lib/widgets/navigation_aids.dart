import 'package:flutter/material.dart';
import '../models/location_data.dart';
import '../models/compass_data.dart';
import '../models/photo.dart';
import '../services/location_service.dart';
import '../services/compass_service.dart';

class NavigationAids extends StatelessWidget {
  final LocationData? currentLocation;
  final CompassData? currentCompass;
  final double? targetLatitude;
  final double? targetLongitude;
  final double? targetCompassDirection;
  final PhotoOrientation? targetOrientation;
  final PhotoOrientation? currentOrientation;

  const NavigationAids({
    super.key,
    this.currentLocation,
    this.currentCompass,
    this.targetLatitude,
    this.targetLongitude,
    this.targetCompassDirection,
    this.targetOrientation,
    this.currentOrientation,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Location aid
            if (currentLocation != null &&
                targetLatitude != null &&
                targetLongitude != null)
              Expanded(child: _buildLocationAid(context))
            else if (targetLatitude == null || targetLongitude == null)
              Expanded(child: _buildMissingLocationAid(context)),

            const SizedBox(width: 8),

            // Compass aid
            if (currentCompass != null && targetCompassDirection != null)
              Expanded(child: _buildCompassAid(context))
            else if (targetCompassDirection == null)
              Expanded(child: _buildMissingCompassAid(context)),

            const SizedBox(width: 8),

            // Orientation aid
            if (targetOrientation != null && currentOrientation != null)
              Expanded(child: _buildOrientationAid(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAid(BuildContext context) {
    final targetLocation = LocationData(
      latitude: targetLatitude!,
      longitude: targetLongitude!,
      accuracy: 0,
      timestamp: DateTime.now(),
    );

    final isOnSite = LocationService().isOnSite(
      currentLocation!,
      targetLocation,
    );
    final instruction = isOnSite ? 'On target' : 'Move to target';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOnSite ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnSite ? Icons.location_on : Icons.location_searching,
            color: isOnSite ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            instruction,
            style: TextStyle(
              color: isOnSite ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompassAid(BuildContext context) {
    final isAligned = CompassService().isAligned(
      currentCompass!.normalizedHeading,
      targetCompassDirection!,
    );

    final instruction = CompassService().getDirectionInstruction(
      currentCompass!.normalizedHeading,
      targetCompassDirection!,
    );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAligned ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAligned ? Icons.explore : Icons.explore_off,
            color: isAligned ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            instruction,
            style: TextStyle(
              color: isAligned ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMissingLocationAid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off, color: Colors.grey, size: 20),
          const SizedBox(height: 4),
          Text(
            'Not available',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMissingCompassAid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_off, color: Colors.grey, size: 20),
          const SizedBox(height: 4),
          Text(
            'Not available',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrientationAid(BuildContext context) {
    final isCorrectOrientation = currentOrientation == targetOrientation;
    final instruction = isCorrectOrientation
        ? 'Orientation matched'
        : 'Turn device to ${targetOrientation!.displayName.toLowerCase()}';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrectOrientation ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrectOrientation ? Icons.phone_android : Icons.screen_rotation,
            color: isCorrectOrientation ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            instruction,
            style: TextStyle(
              color: isCorrectOrientation ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PhotoPointDetailsForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController notesController;

  const PhotoPointDetailsForm({
    super.key,
    required this.nameController,
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Photo Point Name',
                hintText: 'Enter a name for this photo point',
              ),
              validator: PhotoPointValidators.validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: notesController,
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
}

class LocationForm extends StatelessWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController compassDirectionController;

  const LocationForm({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    required this.compassDirectionController,
  });

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      hintText: 'e.g., 37.422131',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: PhotoPointValidators.validateLatitude,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      hintText: 'e.g., -122.084801',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: PhotoPointValidators.validateLongitude,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: compassDirectionController,
              decoration: const InputDecoration(
                labelText: 'Compass Direction (degrees)',
                hintText: 'e.g., 180.0',
                suffixText: '°',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: PhotoPointValidators.validateCompassDirection,
            ),
          ],
        ),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SaveButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final canSave = onPressed != null && !isLoading;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: canSave ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSave ? Colors.orange : Colors.grey[400],
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: canSave
              ? Colors.orange.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
      ),
    );
  }
}

class PhotoPointValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a name';
    }
    return null;
  }

  static String? validateLatitude(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final latitude = double.tryParse(value.trim());
      if (latitude == null) {
        return 'Invalid latitude';
      }
      if (latitude < -90 || latitude > 90) {
        return 'Must be -90 to 90';
      }
    }
    return null;
  }

  static String? validateLongitude(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final longitude = double.tryParse(value.trim());
      if (longitude == null) {
        return 'Invalid longitude';
      }
      if (longitude < -180 || longitude > 180) {
        return 'Must be -180 to 180';
      }
    }
    return null;
  }

  static String? validateCompassDirection(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final direction = double.tryParse(value.trim());
      if (direction == null) {
        return 'Invalid direction';
      }
      if (direction < 0 || direction >= 360) {
        return 'Must be 0-359.9';
      }
    }
    return null;
  }
}

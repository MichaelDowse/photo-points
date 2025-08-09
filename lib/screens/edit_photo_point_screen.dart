import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/photo_point.dart';
import '../widgets/photo_point_form_widgets.dart';

class EditPhotoPointScreen extends StatefulWidget {
  final PhotoPoint photoPoint;

  const EditPhotoPointScreen({super.key, required this.photoPoint});

  @override
  State<EditPhotoPointScreen> createState() => _EditPhotoPointScreenState();
}

class _EditPhotoPointScreenState extends State<EditPhotoPointScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _compassDirectionController;

  bool _isSaving = false;

  bool get _canSave => _nameController.text.trim().isNotEmpty && !_isSaving;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.photoPoint.name);
    _notesController = TextEditingController(
      text: widget.photoPoint.notes ?? '',
    );
    _latitudeController = TextEditingController(
      text: widget.photoPoint.latitude?.toStringAsFixed(6) ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.photoPoint.longitude?.toStringAsFixed(6) ?? '',
    );
    _compassDirectionController = TextEditingController(
      text: widget.photoPoint.compassDirection?.toStringAsFixed(1) ?? '',
    );

    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _compassDirectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Edit Photo Point'),
        actions: [
          SaveButton(
            onPressed: _canSave ? _savePhotoPoint : null,
            isLoading: _isSaving,
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
            PhotoPointDetailsForm(
              nameController: _nameController,
              notesController: _notesController,
            ),
            const SizedBox(height: 24),
            LocationForm(
              latitudeController: _latitudeController,
              longitudeController: _longitudeController,
              compassDirectionController: _compassDirectionController,
            ),
            const SizedBox(
              height: 48,
            ), // Extra bottom padding for better scrolling
          ],
        ),
      ),
    );
  }

  Future<void> _savePhotoPoint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final latitudeText = _latitudeController.text.trim();
      final longitudeText = _longitudeController.text.trim();
      final compassDirectionText = _compassDirectionController.text.trim();

      final updatedPhotoPoint = widget.photoPoint.copyWith(
        name: _nameController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        latitude: latitudeText.isEmpty ? null : double.parse(latitudeText),
        longitude: longitudeText.isEmpty ? null : double.parse(longitudeText),
        compassDirection: compassDirectionText.isEmpty
            ? null
            : double.parse(compassDirectionText),
      );

      if (mounted) {
        await context.read<AppStateProvider>().updatePhotoPoint(
          updatedPhotoPoint,
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating photo point: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

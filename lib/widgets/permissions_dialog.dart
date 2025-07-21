import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/app_state_provider.dart';
import '../services/permission_service.dart';

class PermissionsDialog extends StatefulWidget {
  const PermissionsDialog({super.key});

  @override
  State<PermissionsDialog> createState() => _PermissionsDialogState();
}

class _PermissionsDialogState extends State<PermissionsDialog> {
  final PermissionService _permissionService = PermissionService();
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Permissions Required'),
      content: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          final permissions = appState.permissions;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PhotoPoints needs the following permissions to function properly:',
              ),
              const SizedBox(height: 16),
              ...permissions.entries.map((entry) {
                return _buildPermissionItem(
                  context,
                  entry.key,
                  entry.value,
                  _permissionService.getPermissionDescription(entry.key),
                );
              }).toList(),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: _isRequesting ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: _isRequesting ? null : _requestPermissions,
          child: _isRequesting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Grant Permissions'),
        ),
      ],
    );
  }

  Widget _buildPermissionItem(
    BuildContext context,
    String permissionName,
    bool isGranted,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isGranted ? Icons.check_circle : Icons.cancel,
            color: isGranted 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPermissionTitle(permissionName),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPermissionTitle(String permissionName) {
    switch (permissionName) {
      case 'camera':
        return 'Camera';
      case 'location':
        return 'Location';
      case 'storage':
        return 'Storage';
      case 'photos':
        return 'Photos';
      default:
        return permissionName.toUpperCase();
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      final appState = context.read<AppStateProvider>();
      await appState.requestPermissions();
      
      // Check if all permissions are granted
      if (appState.permissions.values.every((granted) => granted)) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        // Show message about denied permissions
        if (mounted) {
          _showPermissionDeniedMessage();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting permissions: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  void _showPermissionDeniedMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Some permissions were denied or need to be reset. Please go to Settings > PhotoPoints and enable Camera, Location, and Photos permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../models/photo_point.dart';
import '../widgets/photo_point_card.dart';
import '../widgets/permissions_dialog.dart';
import 'add_photo_point_screen.dart';

class PhotoPointsListScreen extends StatefulWidget {
  const PhotoPointsListScreen({super.key});

  @override
  State<PhotoPointsListScreen> createState() => _PhotoPointsListScreenState();
}

class _PhotoPointsListScreenState extends State<PhotoPointsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final appState = context.read<AppStateProvider>();
    
    // Check permissions first
    await appState.checkPermissions();
    
    // Show permissions dialog if not all granted
    if (!appState.permissions.values.every((granted) => granted)) {
      if (mounted) {
        await _showPermissionsDialog();
      }
    }
    
    // Load photo points
    await appState.loadPhotoPoints();
  }

  Future<void> _showPermissionsDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PermissionsDialog(),
    );
  }

  Future<void> _refreshPhotoPoints() async {
    final appState = context.read<AppStateProvider>();
    await appState.loadPhotoPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Points'),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          if (appState.error != null) {
            return _buildErrorWidget(appState.error!);
          }

          if (appState.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (appState.photoPoints.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refreshPhotoPoints,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appState.photoPoints.length,
              itemBuilder: (context, index) {
                final photoPoint = appState.photoPoints[index];
                return PhotoPointCard(
                  photoPoint: photoPoint,
                  onTap: () => _navigateToPhotoPoint(photoPoint),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_photo_point_list",
        onPressed: _navigateToAddPhotoPoint,
        tooltip: 'Add Photo Point',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Photo Points Yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first photo point to start monitoring reforestation progress.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToAddPhotoPoint,
            icon: const Icon(Icons.add),
            label: const Text('Add Photo Point'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 100,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AppStateProvider>().clearError();
              _refreshPhotoPoints();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddPhotoPoint() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPhotoPointScreen(),
      ),
    );
  }

  void _navigateToPhotoPoint(PhotoPoint photoPoint) {
    Navigator.pushNamed(
      context,
      '/photo_point_detail',
      arguments: photoPoint.id,
    );
  }
}
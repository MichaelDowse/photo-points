import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'screens/main_tab_screen.dart';
import 'screens/photo_points_list_screen.dart';
import 'screens/show_photo_point_screen.dart';
import 'services/photo_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set default orientation to portrait for most screens
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize camera
  final photoService = PhotoService();
  await photoService.initializeCameras();
  
  runApp(const PhotoPointsApp());
}

class PhotoPointsApp extends StatelessWidget {
  const PhotoPointsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppStateProvider(),
      child: MaterialApp(
        title: 'PhotoPoints',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainTabScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/photo_points': (context) => const PhotoPointsListScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/photo_point_detail':
              final photoPointId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => ShowPhotoPointScreen(photoPointId: photoPointId),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
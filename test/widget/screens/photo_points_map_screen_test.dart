import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:photopoints/screens/photo_points_map_screen.dart';
import 'package:photopoints/providers/app_state_provider.dart';
import '../../test_data.dart';
import '../../mocks/mock_app_state_provider.dart';

void main() {
  group('PhotoPointsMapScreen Widget Tests', () {
    late MockAppStateProvider mockAppStateProvider;

    setUp(() {
      mockAppStateProvider = MockAppStateProvider();
    });

    Widget createTestWidget({required Widget child}) {
      return MaterialApp(
        home: ChangeNotifierProvider<AppStateProvider>.value(
          value: mockAppStateProvider,
          child: child,
        ),
        routes: {
          '/photo_point_detail': (context) => Scaffold(
            body: Text(
              'Photo Point Detail: ${ModalRoute.of(context)!.settings.arguments}',
            ),
          ),
        },
      );
    }

    testWidgets('renders correctly with all required components', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Photo Points Map'), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows loading indicator when loading', (
      WidgetTester tester,
    ) async {
      mockAppStateProvider.setLoading(true);

      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(FlutterMap), findsNothing);
    });

    testWidgets('shows error state when error occurs', (
      WidgetTester tester,
    ) async {
      mockAppStateProvider.setError('Test error occurred');

      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Test error occurred'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows empty state when no photo points have coordinates', (
      WidgetTester tester,
    ) async {
      final photoPointsWithoutCoordinates = [
        TestData.createMockPhotoPoint(
          id: 'test-1',
          latitude: null,
          longitude: null,
        ),
        TestData.createMockPhotoPoint(
          id: 'test-2',
          latitude: null,
          longitude: null,
        ),
      ];

      mockAppStateProvider.setPhotoPoints(photoPointsWithoutCoordinates);

      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      expect(find.text('No Photo Points with Coordinates'), findsOneWidget);
      expect(
        find.text(
          'Photo points without GPS coordinates will not appear on the map.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.location_off), findsOneWidget);
    });

    testWidgets('shows map when photo points have coordinates', (
      WidgetTester tester,
    ) async {
      final photoPointsWithCoordinates = TestData.createMockPhotoPointList(
        count: 2,
      );
      mockAppStateProvider.setPhotoPoints(photoPointsWithCoordinates);

      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text('No Photo Points with Coordinates'), findsNothing);
    });

    testWidgets(
      'shows map with mixed photo points (some with coordinates, some without)',
      (WidgetTester tester) async {
        final mixedPhotoPoints = [
          TestData.createMockPhotoPoint(
            id: 'test-1',
            latitude: 37.7749,
            longitude: -122.4194,
          ),
          TestData.createMockPhotoPoint(
            id: 'test-2',
            latitude: null,
            longitude: null,
          ),
          TestData.createMockPhotoPoint(
            id: 'test-3',
            latitude: 38.0000,
            longitude: -122.0000,
          ),
        ];

        mockAppStateProvider.setPhotoPoints(mixedPhotoPoints);

        await tester.pumpWidget(
          createTestWidget(child: const PhotoPointsMapScreen()),
        );
        await tester.pump();

        expect(find.byType(FlutterMap), findsOneWidget);
        expect(find.text('No Photo Points with Coordinates'), findsNothing);
      },
    );

    testWidgets('tapping retry button clears error and reinitializes', (
      WidgetTester tester,
    ) async {
      mockAppStateProvider.setError('Test error');

      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      expect(find.text('Error'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(mockAppStateProvider.error, isNull);
    });

    testWidgets('floating action button has correct tooltip and icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );
      expect(fab.tooltip, 'Add Photo Point');
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('my location button has correct tooltip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      final iconButtonFinder = find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(IconButton),
      );
      expect(iconButtonFinder, findsOneWidget);

      final myLocationButton = tester.widget<IconButton>(iconButtonFinder);
      expect(myLocationButton.tooltip, 'Go to my location');
    });

    testWidgets('shows all required map components when rendering map', (
      WidgetTester tester,
    ) async {
      final photoPointsWithCoordinates = TestData.createMockPhotoPointList(
        count: 1,
      );
      mockAppStateProvider.setPhotoPoints(photoPointsWithCoordinates);

      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      expect(find.byType(FlutterMap), findsOneWidget);

      // Check for Stack that contains the FlutterMap (the main map stack)
      final stackFinder = find.ancestor(
        of: find.byType(FlutterMap),
        matching: find.byType(Stack),
      );
      expect(stackFinder, findsOneWidget);
    });

    testWidgets('app bar title is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      expect(find.text('Photo Points Map'), findsOneWidget);
    });

    testWidgets('handles consumer properly for app state changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      expect(find.byType(Consumer<AppStateProvider>), findsOneWidget);
    });
  });
}

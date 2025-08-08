import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:photopoints/screens/photo_points_map_screen.dart';
import 'package:photopoints/providers/app_state_provider.dart';
import '../../test_data.dart';
import '../../mocks/mock_app_state_provider.dart';

void main() {
  group('PhotoPointsMapScreen', () {
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

    testWidgets('should render with FlutterMap widget', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      // Give time for initialization but avoid network requests
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text('Photo Points Map'), findsOneWidget);
    }, skip: true);

    testWidgets('should show loading indicator when app state is loading', (
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

    testWidgets('should show error widget when app state has error', (
      WidgetTester tester,
    ) async {
      mockAppStateProvider.setError('Test error message');

      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byType(FlutterMap), findsNothing);
    });

    testWidgets(
      'should show empty state when no photo points have coordinates',
      (WidgetTester tester) async {
        // Create photo points without coordinates
        final photoPointsWithoutCoordinates = [
          TestData.createMockPhotoPoint(
            id: 'test-1',
            name: 'Test Point 1',
            latitude: null,
            longitude: null,
          ),
          TestData.createMockPhotoPoint(
            id: 'test-2',
            name: 'Test Point 2',
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
      },
    );

    testWidgets('should show map when photo points have coordinates', (
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
    }, skip: true);

    testWidgets('should have floating action button for adding photo points', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    }, skip: true);

    testWidgets('should have my location button in app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const PhotoPointsMapScreen()),
      );
      await tester.pump();

      expect(find.byIcon(Icons.my_location), findsOneWidget);
    }, skip: true);

    testWidgets(
      'should show mixed content when some photo points have coordinates',
      (WidgetTester tester) async {
        final mixedPhotoPoints = [
          TestData.createMockPhotoPoint(
            id: 'test-1',
            name: 'Point with coords',
            latitude: 37.7749,
            longitude: -122.4194,
          ),
          TestData.createMockPhotoPoint(
            id: 'test-2',
            name: 'Point without coords',
            latitude: null,
            longitude: null,
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
      skip: true,
    );

    group('Photo Point Filtering', () {
      test('should filter photo points that have coordinates', () {
        final photoPoints = [
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

        final filteredPoints = photoPoints
            .where((point) => point.hasLocation)
            .toList();

        expect(filteredPoints.length, 2);
        expect(filteredPoints[0].id, 'test-1');
        expect(filteredPoints[1].id, 'test-3');
      });

      test(
        'should return empty list when no photo points have coordinates',
        () {
          final photoPoints = [
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

          final filteredPoints = photoPoints
              .where((point) => point.hasLocation)
              .toList();

          expect(filteredPoints.length, 0);
        },
      );

      test('should return all photo points when all have coordinates', () {
        final photoPoints = TestData.createMockPhotoPointList(count: 3);

        final filteredPoints = photoPoints
            .where((point) => point.hasLocation)
            .toList();

        expect(filteredPoints.length, 3);
      });
    });
  });
}

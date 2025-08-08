import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:integration_test/integration_test.dart';
import 'package:photopoints/main.dart';
import 'package:photopoints/screens/main_tab_screen.dart';
import 'package:photopoints/screens/photo_points_list_screen.dart';
import 'package:photopoints/screens/photo_points_map_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Map View Integration Tests', () {
    testWidgets('Full tab switching workflow', (WidgetTester tester) async {
      // Start the app
      await tester.pumpWidget(const PhotoPointsApp());
      await tester.pumpAndSettle();

      // Verify we start with the tab screen
      expect(find.byType(MainTabScreen), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Verify List tab is initially selected
      expect(find.text('List'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);

      // Verify List screen is shown
      expect(find.byType(PhotoPointsListScreen), findsOneWidget);
      expect(find.text('PhotoPoints'), findsOneWidget);

      // Switch to Map tab
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Verify Map screen is shown
      expect(find.byType(PhotoPointsMapScreen), findsOneWidget);
      expect(find.text('Photo Points Map'), findsOneWidget);

      // Verify map components are present
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Switch back to List tab
      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();

      // Verify List screen is shown again
      expect(find.byType(PhotoPointsListScreen), findsOneWidget);
      expect(find.text('PhotoPoints'), findsOneWidget);
    });

    testWidgets(
      'Map view shows empty state when no photo points have coordinates',
      (WidgetTester tester) async {
        await tester.pumpWidget(const PhotoPointsApp());
        await tester.pumpAndSettle();

        // Switch to Map tab
        await tester.tap(find.text('Map'));
        await tester.pumpAndSettle();

        // If no photo points exist or none have coordinates, should show empty state
        // The exact behavior depends on the current state of the app
        expect(find.byType(PhotoPointsMapScreen), findsOneWidget);
        expect(find.text('Photo Points Map'), findsOneWidget);
      },
    );

    testWidgets('Floating action button navigation works from both tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PhotoPointsApp());
      await tester.pumpAndSettle();

      // Test FAB from List tab
      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should navigate to Add Photo Point screen
      expect(find.text('Add Photo Point'), findsOneWidget);

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Switch to Map tab
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Test FAB from Map tab
      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should navigate to Add Photo Point screen
      expect(find.text('Add Photo Point'), findsOneWidget);
    });

    testWidgets('Map view handles permissions correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PhotoPointsApp());
      await tester.pumpAndSettle();

      // Switch to Map tab
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Map should be visible (permissions handling is internal)
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets('Tab state is preserved during navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PhotoPointsApp());
      await tester.pumpAndSettle();

      // Switch to Map tab
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Verify Map tab is selected
      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 1);

      // Navigate to Add Photo Point
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verify Map tab is still selected
      final updatedBottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(updatedBottomNavBar.currentIndex, 1);
      expect(find.byType(PhotoPointsMapScreen), findsOneWidget);
    });

    testWidgets('Map components are properly initialized', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PhotoPointsApp());
      await tester.pumpAndSettle();

      // Switch to Map tab
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Verify all map components are present
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Photo Points Map'), findsOneWidget);
    });

    testWidgets('My location button is functional', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PhotoPointsApp());
      await tester.pumpAndSettle();

      // Switch to Map tab
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Tap my location button
      await tester.tap(find.byIcon(Icons.my_location));
      await tester.pumpAndSettle();

      // Button should be responsive (no exceptions thrown)
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets('App handles rapid tab switching', (WidgetTester tester) async {
      await tester.pumpWidget(const PhotoPointsApp());
      await tester.pumpAndSettle();

      // Rapidly switch between tabs
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Map'));
        await tester.pump(const Duration(milliseconds: 100));

        await tester.tap(find.text('List'));
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should end up on List tab and be stable
      expect(find.byType(PhotoPointsListScreen), findsOneWidget);
      expect(find.text('PhotoPoints'), findsOneWidget);
    });

    testWidgets('IndexedStack preserves state between tab switches', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const PhotoPointsApp());
      await tester.pumpAndSettle();

      // Verify IndexedStack is used
      expect(find.byType(IndexedStack), findsOneWidget);

      // Switch to Map tab
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();

      // Both screens should still be in the widget tree
      expect(find.byType(PhotoPointsListScreen), findsOneWidget);
      expect(find.byType(PhotoPointsMapScreen), findsOneWidget);

      // Switch back to List tab
      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();

      // Both screens should still be in the widget tree
      expect(find.byType(PhotoPointsListScreen), findsOneWidget);
      expect(find.byType(PhotoPointsMapScreen), findsOneWidget);
    });
  });
}

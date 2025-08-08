import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:photopoints/screens/main_tab_screen.dart';
import 'package:photopoints/screens/photo_points_list_screen.dart';
import 'package:photopoints/screens/photo_points_map_screen.dart';
import 'package:photopoints/providers/app_state_provider.dart';
import '../../test_data.dart';
import '../../mocks/mock_app_state_provider.dart';

void main() {
  group('MainTabScreen Widget Tests', () {
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

    testWidgets('renders correctly with bottom navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));
      await tester.pump();

      // MainTabScreen should have its own Scaffold with BottomNavigationBar
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('shows correct tab labels and icons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));
      await tester.pump();

      expect(find.text('List'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
    });

    testWidgets('starts with List tab selected', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));
      await tester.pump();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 0);
    });

    testWidgets('switches to Map tab when Map tab is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));
      await tester.pump();

      await tester.tap(find.text('Map'));
      await tester.pump();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 1);
    });

    testWidgets('switches between tabs correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));
      await tester.pump();

      // Start with List tab
      var bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 0);

      // Switch to Map tab
      await tester.tap(find.text('Map'));
      await tester.pump();

      bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 1);

      // Switch back to List tab
      await tester.tap(find.text('List'));
      await tester.pump();

      bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 0);
    });

    testWidgets('maintains state between tab switches using IndexedStack', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));
      await tester.pumpAndSettle();

      // Verify both screen types are in the IndexedStack children
      final indexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(indexedStack.children.length, 2);
      expect(indexedStack.children[0], isA<PhotoPointsListScreen>());
      expect(indexedStack.children[1], isA<PhotoPointsMapScreen>());

      // Switch to Map tab
      await tester.tap(find.text('Map'));
      await tester.pump();

      // Both screens should still be present in IndexedStack
      final updatedIndexedStack = tester.widget<IndexedStack>(
        find.byType(IndexedStack),
      );
      expect(updatedIndexedStack.children.length, 2);
      expect(updatedIndexedStack.children[0], isA<PhotoPointsListScreen>());
      expect(updatedIndexedStack.children[1], isA<PhotoPointsMapScreen>());
    });

    testWidgets('shows correct screen content based on selected tab', (
      WidgetTester tester,
    ) async {
      // Set up some test data
      final photoPoints = TestData.createMockPhotoPointList(count: 2);
      mockAppStateProvider.setPhotoPoints(photoPoints);

      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));
      await tester.pump();

      // List tab should be visible initially
      expect(find.text('Photo Points'), findsOneWidget);

      // Switch to Map tab
      await tester.tap(find.text('Map'));
      await tester.pump();

      // Map tab should be visible
      expect(find.text('Photo Points Map'), findsOneWidget);
    });

    testWidgets('bottom navigation bar uses fixed type', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));
      await tester.pump();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.type, BottomNavigationBarType.fixed);
    });

    testWidgets('handles tab selection correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));
      await tester.pump();

      // Test tapping on the Map icon
      await tester.tap(find.byIcon(Icons.map));
      await tester.pump();

      final bottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bottomNavBar.currentIndex, 1);

      // Test tapping on the List icon
      await tester.tap(find.byIcon(Icons.list));
      await tester.pump();

      final updatedBottomNavBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(updatedBottomNavBar.currentIndex, 0);
    });
  });
}

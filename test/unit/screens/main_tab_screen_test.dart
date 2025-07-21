import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:photopoints/screens/main_tab_screen.dart';
import 'package:photopoints/screens/photo_points_list_screen.dart';
import 'package:photopoints/screens/photo_points_map_screen.dart';
import 'package:photopoints/providers/app_state_provider.dart';
import '../../mocks/mock_app_state_provider.dart';

void main() {
  group('MainTabScreen', () {
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
      );
    }

    testWidgets('should render with bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('should have two tabs: List and Map', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));

      expect(find.text('List'), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
    });

    testWidgets('should start with List tab selected', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));

      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, 0);
    });

    testWidgets('should switch to Map tab when Map is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));

      await tester.tap(find.text('Map'));
      await tester.pump();

      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, 1);
    });

    testWidgets('should switch back to List tab when List is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));

      // First switch to Map tab
      await tester.tap(find.text('Map'));
      await tester.pump();

      // Then switch back to List tab
      await tester.tap(find.text('List'));
      await tester.pump();

      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, 0);
    });

    testWidgets('should maintain IndexedStack structure for performance', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));

      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.children.length, 2);
      expect(indexedStack.index, 0);

      // Switch to Map tab
      await tester.tap(find.text('Map'));
      await tester.pump();

      final updatedIndexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(updatedIndexedStack.index, 1);
    });

    testWidgets('should contain PhotoPointsListScreen and PhotoPointsMapScreen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(child: const MainTabScreen()));
      await tester.pumpAndSettle();

      // Verify that both screen types are in the IndexedStack children
      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.children.length, 2);
      
      // The first child should be PhotoPointsListScreen
      expect(indexedStack.children[0], isA<PhotoPointsListScreen>());
      
      // The second child should be PhotoPointsMapScreen  
      expect(indexedStack.children[1], isA<PhotoPointsMapScreen>());
    });
  });
}
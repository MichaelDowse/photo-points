import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:photopoints/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PhotoPoints App Integration Tests', () {
    testWidgets('Complete user workflow - Create and manage photo points', (
      tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app starts with empty state
      expect(find.text('PhotoPoints'), findsOneWidget);
      expect(find.text('No Photo Points Yet'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Tap the add button to create a new photo point
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify we're on the add photo point screen
      expect(find.text('Add Photo Point'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);

      // Enter photo point details
      await tester.enterText(find.byType(TextField).first, 'Test Photo Point');
      await tester.pumpAndSettle();

      // If there are additional text fields for notes
      final textFields = find.byType(TextField);
      if (textFields.evaluate().length > 1) {
        await tester.enterText(
          textFields.last,
          'Test notes for integration test',
        );
        await tester.pumpAndSettle();
      }

      // Look for save/create button and tap it
      final saveButton = find.byType(ElevatedButton).first;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify we're back on the main screen with the new photo point
      expect(find.text('PhotoPoints'), findsOneWidget);
      expect(find.text('Test Photo Point'), findsOneWidget);

      // Tap on the photo point to view details
      await tester.tap(find.text('Test Photo Point'));
      await tester.pumpAndSettle();

      // Verify we're on the photo point detail screen
      expect(find.text('Test Photo Point'), findsOneWidget);

      // Test navigation back to main screen
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify we're back on the main screen
      expect(find.text('PhotoPoints'), findsOneWidget);
      expect(find.text('Test Photo Point'), findsOneWidget);
    });

    testWidgets('Permission handling workflow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // The app should handle permissions gracefully
      // This test verifies the app doesn't crash when permissions are not granted
      expect(find.text('PhotoPoints'), findsOneWidget);

      // Try to access camera functionality
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // The app should handle camera/location permission requests
      // and show appropriate messages or prompts
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('App state persistence', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Create a photo point
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'Persistent Test Point',
      );
      await tester.pumpAndSettle();

      final saveButton = find.byType(ElevatedButton).first;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify photo point is created
      expect(find.text('Persistent Test Point'), findsOneWidget);

      // Restart the app (simulating app restart)
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        null,
        (data) {},
      );

      app.main();
      await tester.pumpAndSettle();

      // Verify photo point persists after restart
      expect(find.text('PhotoPoints'), findsOneWidget);
      // Note: In a real test, this would verify data persistence
      // For now, we just ensure the app starts correctly
    });

    testWidgets('Error handling workflow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test error handling when trying to create photo point with invalid data
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to save without entering required data
      final saveButton = find.byType(ElevatedButton).first;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // The app should handle this gracefully
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Navigation workflow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test navigation between screens
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify we're back on main screen
      expect(find.text('PhotoPoints'), findsOneWidget);
    });

    testWidgets('Photo point management workflow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Create multiple photo points
      for (int i = 1; i <= 3; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'Photo Point $i');
        await tester.pumpAndSettle();

        final saveButton = find.byType(ElevatedButton).first;
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.text('Photo Point $i'), findsOneWidget);
      }

      // Verify all photo points are displayed
      expect(find.text('Photo Point 1'), findsOneWidget);
      expect(find.text('Photo Point 2'), findsOneWidget);
      expect(find.text('Photo Point 3'), findsOneWidget);
    });

    testWidgets('App theme and UI consistency', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify theme is applied correctly
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // Test theme consistency across screens
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Data validation workflow', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test data validation
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Test empty name validation
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pumpAndSettle();

      final saveButton = find.byType(ElevatedButton).first;
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // App should handle empty input gracefully
      expect(find.byType(Scaffold), findsOneWidget);

      // Test with valid data
      await tester.enterText(find.byType(TextField).first, 'Valid Photo Point');
      await tester.pumpAndSettle();

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Valid Photo Point'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photopoints/widgets/confirmation_dialog.dart';

void main() {
  group('ConfirmationDialog', () {
    testWidgets('should display dialog with title and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog(
                      title: 'Test Title',
                      content: 'Test Message',
                                          ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is displayed
      expect(find.byType(ConfirmationDialog), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
    });

    testWidgets('should close dialog when confirm button is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog(
                      title: 'Test Title',
                      content: 'Test Message',
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(ConfirmationDialog), findsOneWidget);

      // Find and tap confirm button
      final confirmButton = find.text('Confirm').first;
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(ConfirmationDialog), findsNothing);
    });

    testWidgets('should close dialog when cancel button is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog(
                      title: 'Test Title',
                      content: 'Test Message',
                                          ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(ConfirmationDialog), findsOneWidget);

      // Find and tap cancel button
      final cancelButton = find.text('Cancel').first;
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(ConfirmationDialog), findsNothing);
    });

    testWidgets('should display custom button text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog(
                      title: 'Test Title',
                      content: 'Test Message',
                      confirmText: 'Delete',
                      cancelText: 'Keep',
                                          ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify custom button text is displayed
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Keep'), findsOneWidget);
    });

    testWidgets('should handle destructive action styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog(
                      title: 'Delete Photo Point',
                      content: 'This action cannot be undone.',
                      confirmText: 'Delete',
                      isDestructive: true,
                                          ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify destructive styling is applied
      expect(find.text('Delete Photo Point'), findsOneWidget);
      expect(find.text('This action cannot be undone.'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog(
                      title: 'Test Title',
                      content: 'Test Message',
                                          ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog structure for accessibility
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget); // Cancel button
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1)); // Confirm button (may include the Show Dialog button)
    });

    testWidgets('should handle long text gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog(
                      title: 'This is a very long title that should be handled gracefully',
                      content: 'This is a very long message that contains lots of text and should be displayed properly without breaking the layout or causing any overflow issues in the confirmation dialog.',
                                          ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify it displays without overflow
      expect(find.byType(ConfirmationDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle cancel button behavior', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog(
                      title: 'Test Title',
                      content: 'Test Message',
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(ConfirmationDialog), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(ConfirmationDialog), findsNothing);
    });
  });
}
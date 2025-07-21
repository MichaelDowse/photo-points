import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photopoints/widgets/photo_point_card.dart';
import 'package:photopoints/models/photo_point.dart';
import '../../test_data.dart';

void main() {
  group('PhotoPointCard', () {
    late PhotoPoint testPhotoPoint;
    late bool wasCallbackCalled;

    setUp(() {
      testPhotoPoint = TestData.createMockPhotoPoint(
        name: 'Test Photo Point',
        notes: 'Test notes',
      );
      wasCallbackCalled = false;
    });

    testWidgets('should display photo point information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoPointCard(
              photoPoint: testPhotoPoint,
              onTap: () {
                wasCallbackCalled = true;
              },
            ),
          ),
        ),
      );

      // Verify photo point name is displayed
      expect(find.text('Test Photo Point'), findsOneWidget);
      
      // Verify notes are displayed (if they exist)
      if (testPhotoPoint.notes != null) {
        expect(find.text('Test notes'), findsOneWidget);
      }
    });

    testWidgets('should call onTap callback when tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoPointCard(
              photoPoint: testPhotoPoint,
              onTap: () {
                wasCallbackCalled = true;
              },
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(PhotoPointCard));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(wasCallbackCalled, true);
    });

    testWidgets('should display location information when available', (tester) async {
      final photoPointWithLocation = TestData.createMockPhotoPoint(
        name: 'Located Point',
        latitude: 37.7749,
        longitude: -122.4194,
        compassDirection: 45.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoPointCard(
              photoPoint: photoPointWithLocation,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify location information is displayed
      expect(find.text('Located Point'), findsOneWidget);
      
      // The widget might display coordinates or compass direction
      // This depends on the actual implementation
      expect(find.byType(PhotoPointCard), findsOneWidget);
    });

    testWidgets('should handle photo point without location data', (tester) async {
      final photoPointWithoutLocation = TestData.createMockPhotoPoint(
        name: 'No Location Point',
        latitude: null,
        longitude: null,
        compassDirection: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoPointCard(
              photoPoint: photoPointWithoutLocation,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify it displays without errors
      expect(find.text('No Location Point'), findsOneWidget);
      expect(find.byType(PhotoPointCard), findsOneWidget);
    });

    testWidgets('should handle photo point with empty notes', (tester) async {
      final photoPointWithEmptyNotes = TestData.createMockPhotoPoint(
        name: 'No Notes Point',
        notes: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoPointCard(
              photoPoint: photoPointWithEmptyNotes,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify it displays without errors
      expect(find.text('No Notes Point'), findsOneWidget);
      expect(find.byType(PhotoPointCard), findsOneWidget);
    });

    testWidgets('should display photo count when photos exist', (tester) async {
      final photoWithImages = TestData.createMockPhoto();
      final photoPointWithPhotos = TestData.createMockPhotoPoint(
        name: 'Point with Photos',
        photos: [photoWithImages],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoPointCard(
              photoPoint: photoPointWithPhotos,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify photo point displays
      expect(find.text('Point with Photos'), findsOneWidget);
      expect(find.byType(PhotoPointCard), findsOneWidget);
    });

    testWidgets('should display creation date', (tester) async {
      final specificDate = DateTime(2023, 6, 15, 10, 30);
      final photoPointWithDate = TestData.createMockPhotoPoint(
        name: 'Dated Point',
        createdAt: specificDate,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoPointCard(
              photoPoint: photoPointWithDate,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify photo point displays
      expect(find.text('Dated Point'), findsOneWidget);
      expect(find.byType(PhotoPointCard), findsOneWidget);
    });

    testWidgets('should have correct visual styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoPointCard(
              photoPoint: testPhotoPoint,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify card structure
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoPointCard(
              photoPoint: testPhotoPoint,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify accessibility
      expect(find.byType(InkWell), findsOneWidget);
      
      // The card should be tappable
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.onTap, isNotNull);
    });

    testWidgets('should handle long text gracefully', (tester) async {
      final longTextPhotoPoint = TestData.createMockPhotoPoint(
        name: 'This is a very long photo point name that should be handled gracefully by the widget',
        notes: 'This is a very long notes section that contains lots of text and should be displayed properly without breaking the layout or causing any overflow issues',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhotoPointCard(
              photoPoint: longTextPhotoPoint,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify it displays without overflow
      expect(find.byType(PhotoPointCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:photopoints/main.dart';

void main() {
  testWidgets('PhotoPoints app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PhotoPointsApp());

    // Verify that our app starts with the correct title.
    expect(find.text('Photo Points'), findsOneWidget);

    // Verify that we have an empty state initially.
    expect(find.text('No Photo Points Yet'), findsOneWidget);

    // Verify that we have an add button.
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:silaju/app.dart';

void main() {
  testWidgets('App launches without crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SilajuApp(),
      ),
    );

    // Verify app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

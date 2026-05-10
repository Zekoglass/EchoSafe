import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:echosafe/main.dart';

void main() {
  testWidgets('EchoSafe app launches successfully', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const EchoSafeApp());

    // Verify the app loads with EchoSafe branding
    expect(find.text('EchoSafe'), findsOneWidget);

    // Verify bottom navigation items are present
    // (using findsWidgets because some labels appear in both
    // the dashboard cards AND the bottom nav bar)
    expect(find.text('Fake Call'), findsWidgets);
    expect(find.text('Panic'), findsOneWidget);
    expect(find.text('Contacts'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);

    // Verify the panic button card is visible
    expect(find.text('PANIC BUTTON'), findsOneWidget);

    // Verify the main tagline is visible
    expect(find.text('Your personal safety toolkit.'), findsOneWidget);
  });
}
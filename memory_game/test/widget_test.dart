import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/app.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MemoryGameApp());

    // Verify the app loads (splash screen appears)
    expect(find.text('Memory Match'), findsOneWidget);
  });
}

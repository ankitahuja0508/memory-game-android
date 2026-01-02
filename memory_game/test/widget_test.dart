import 'package:flutter_test/flutter_test.dart';
import 'package:memory_game/app.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MemoryGameApp());
    expect(find.byType(MemoryGameApp), findsOneWidget);
  });
}

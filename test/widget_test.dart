import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deskypt/main.dart';

void main() {
  testWidgets('DeskYptApp renders headline text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DeskYptApp(),
      ),
    );

    expect(find.text('DeskYPT'), findsOneWidget);
  });
}

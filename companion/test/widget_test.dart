import 'package:flutter_test/flutter_test.dart';
import 'package:companion/main.dart';
import 'package:companion/core/constants.dart';

void main() {
  testWidgets('DeskYptCompanionApp renders app name', (WidgetTester tester) async {
    await tester.pumpWidget(const DeskYptCompanionApp());
    expect(find.text(CompanionConstants.appName), findsOneWidget);
  });
}

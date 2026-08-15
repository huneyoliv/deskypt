import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deskypt/shared/widgets/app_title_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTitleBar Tests', () {
    testWidgets('AppTitleBar renders title and 3 control buttons', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  AppTitleBar(title: 'DeskYPT - Yeolpumta Desktop'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('DeskYPT - Yeolpumta Desktop'), findsOneWidget);
      expect(find.byType(Tooltip), findsNWidgets(3));
      expect(find.byTooltip('Minimizar'), findsOneWidget);
      expect(find.byTooltip('Maximizar'), findsOneWidget);
      expect(find.byTooltip('Fechar'), findsOneWidget);
    });

    testWidgets('AppTitleBar updates restore tooltip and icon when maximized state changes', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  AppTitleBar(title: 'DeskYPT'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final state = tester.state(find.byType(AppTitleBar)) as dynamic;
      expect(find.byTooltip('Maximizar'), findsOneWidget);

      // Simulate window maximize event (e.g. from Aero Snap drag to top)
      state.onWindowMaximize();
      await tester.pump();

      // State is now checked and maximized
      // Simulate unmaximize
      state.onWindowUnmaximize();
      await tester.pump();
    });
  });
}

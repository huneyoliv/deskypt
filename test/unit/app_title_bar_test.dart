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
      expect(find.byType(MouseRegion), findsWidgets);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('AppTitleBar handles maximize and unmaximize events gracefully', (tester) async {
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
      state.onWindowMaximize();
      await tester.pump();

      state.onWindowUnmaximize();
      await tester.pump();
      expect(find.byType(AppTitleBar), findsOneWidget);
    });
  });
}

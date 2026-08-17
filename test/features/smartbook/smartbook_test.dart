import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deskypt/features/smartbook/smartbook_screen.dart';
import 'package:deskypt/core/services/smartbook_window_service.dart';

void main() {
  group('SmartBook Tests', () {
    testWidgets('SmartBookScreen renders empty view when no file is loaded', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SmartBookScreen(),
          ),
        ),
      );

      expect(find.text('SmartBook - Leitor de PDF'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf_rounded), findsOneWidget);
      expect(find.text('Selecionar Arquivo PDF'), findsOneWidget);
    });

    testWidgets('SmartBookWindowService open pushes fullscreen route', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => SmartBookWindowService.open(context),
                child: const Text('Open SmartBook'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open SmartBook'));
      await tester.pumpAndSettle();

      expect(find.byType(SmartBookScreen), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/core/localization/app_translation.dart';
import 'package:deskypt/core/services/focus_mode_service.dart';
import 'package:deskypt/features/focus/focus_mode_notifier.dart';
import 'package:deskypt/features/focus/focus_mode_screen.dart';
import 'package:deskypt/features/focus/widgets/distraction_alert_overlay.dart';

void main() {
  Widget buildTestWidget(Widget child, {FocusModeState? initialState}) {
    return ProviderScope(
      overrides: [
        appTranslationProvider.overrideWith(
          (ref) => AppTranslationNotifier(ref)..state = const AppTranslation(languageCode: 'pt'),
        ),
        if (initialState != null)
          focusModeNotifierProvider.overrideWith(
            (ref) => FocusModeNotifier(FocusModeService())..state = initialState,
          ),
      ],
      child: MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('FocusModeScreen renders toggles and allows adding blocked app', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget(const FocusModeScreen()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Modo Foco & Bloqueador'), findsOneWidget);
    expect(find.textContaining('Bloqueador de Distrações'), findsOneWidget);
    expect(find.textContaining('Modo Estrito'), findsOneWidget);
    expect(find.textContaining('Aplicativos Bloqueados'), findsOneWidget);

    // Add a new blocked app
    await tester.enterText(find.byType(TextField), 'steam');
    await tester.tap(find.text('Adicionar'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('steam.exe'), findsOneWidget);
  });

  testWidgets('DistractionAlertOverlay displays alert when distractions are active and dismisses', (tester) async {
    const activeState = FocusModeState(
      activeDistractions: ['discord.exe'],
    );

    await tester.pumpWidget(buildTestWidget(
      const DistractionAlertOverlay(),
      initialState: activeState,
    ));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('discord.exe'), findsOneWidget);
    expect(find.text('Dispensar'), findsOneWidget);

    await tester.tap(find.text('Dispensar'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('discord.exe'), findsNothing);
  });
}

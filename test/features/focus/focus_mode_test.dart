import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deskypt/data/models/focus_mode_settings_model.dart';
import 'package:deskypt/features/focus/focus_mode_notifier.dart';
import 'package:deskypt/features/focus/focus_mode_screen.dart';
import 'package:deskypt/features/focus/widgets/distraction_alert_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Focus Mode Model & Notifier Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('FocusModeSettings toJson and fromJson roundtrip', () {
      const settings = FocusModeSettings(
        isEnabled: true,
        isStrict: true,
        blockedProcesses: ['discord.exe', 'game.exe'],
        checkIntervalSeconds: 3,
      );

      final json = settings.toJson();
      final decoded = FocusModeSettings.fromJson(json);

      expect(decoded.isEnabled, isTrue);
      expect(decoded.isStrict, isTrue);
      expect(decoded.blockedProcesses, contains('discord.exe'));
      expect(decoded.checkIntervalSeconds, 3);
    });

    test('FocusModeNotifier toggles and adds/removes blocked apps', () async {
      final container = ProviderContainer();
      final notifier = container.read(focusModeNotifierProvider.notifier);

      await notifier.toggleEnabled(true);
      expect(container.read(focusModeNotifierProvider).settings.isEnabled, isTrue);

      await notifier.addBlockedApp('customapp.exe');
      expect(container.read(focusModeNotifierProvider).settings.blockedProcesses, contains('customapp.exe'));

      await notifier.removeBlockedApp('customapp.exe');
      expect(container.read(focusModeNotifierProvider).settings.blockedProcesses, isNot(contains('customapp.exe')));

      container.dispose();
    });
  });

  group('Focus Mode UI Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('FocusModeScreen renders switches and app chips', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(splashFactory: InkRipple.splashFactory),
            home: const FocusModeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Modo Foco & Bloqueador'), findsOneWidget);
      expect(find.text('Bloqueador de Distrações'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
      expect(find.text('discord.exe'), findsOneWidget);
    });

    testWidgets('DistractionAlertOverlay displays banner when distraction is detected', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(splashFactory: InkRipple.splashFactory),
            home: const Scaffold(
              body: DistractionAlertOverlay(),
            ),
          ),
        ),
      );

      // Initially empty
      expect(find.byType(DistractionAlertOverlay), findsOneWidget);
      expect(find.textContaining('Aplicativo distrator detectado'), findsNothing);

      // Trigger distraction state
      final notifier = container.read(focusModeNotifierProvider.notifier);
      notifier.state = notifier.state.copyWith(activeDistractions: ['discord.exe']);
      await tester.pump();

      expect(find.textContaining('discord.exe'), findsOneWidget);
      expect(find.text('Dispensar'), findsOneWidget);

      // Tap dismiss
      await tester.tap(find.text('Dispensar'));
      await tester.pump();

      expect(find.textContaining('discord.exe'), findsNothing);
      container.dispose();
    });
  });
}

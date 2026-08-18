import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/core/localization/app_translation.dart';
import 'package:deskypt/core/services/update_service.dart';
import 'package:deskypt/features/updates/models/update_model.dart';
import 'package:deskypt/features/updates/update_notifier.dart';
import 'package:deskypt/features/updates/widgets/update_button.dart';
import 'package:deskypt/features/updates/widgets/update_dialog.dart';

class MockUpdateService extends UpdateService {
  final AppRelease? release;
  MockUpdateService({this.release});

  @override
  Future<AppRelease?> fetchLatestRelease() async => release;
}

void main() {
  group('Update Widgets Tests', () {
    final sampleRelease = const AppRelease(
      id: 999,
      tagName: 'v1.5.0',
      name: 'DeskYPT v1.5.0 - Super Speed',
      body: 'Features:\n- New super fast timer\n- Better group chat',
      htmlUrl: 'https://github.com/huneyoliv/deskypt/releases/tag/v1.5.0',
      assets: [
        ReleaseAsset(
          id: 101,
          name: 'DeskYPT-Windows-Installer-x64.exe',
          size: 50000000,
          downloadUrl: 'https://github.com/test/download.exe',
          contentType: 'application/x-msdownload',
        ),
      ],
    );

    testWidgets('UpdateButton renders when update is available', (tester) async {
      final mockService = MockUpdateService(release: sampleRelease);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            updateServiceProvider.overrideWithValue(mockService),
            updateNotifierProvider.overrideWith((ref) {
              return UpdateNotifier(service: mockService, currentVersion: '1.0.0');
            }),
            appTranslationProvider.overrideWith(
              (ref) => AppTranslationNotifier(ref),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UpdateButton(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(UpdateButton), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    });

    testWidgets('UpdateDialog renders changelog and download buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appTranslationProvider.overrideWith(
              (ref) => AppTranslationNotifier(ref),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UpdateDialog(release: sampleRelease),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Atualização Disponível'), findsOneWidget);
      expect(find.text('v1.5.0'), findsOneWidget);
      expect(find.textContaining('New super fast timer'), findsOneWidget);
      expect(find.textContaining('DeskYPT-Windows-Installer-x64.exe'), findsOneWidget);
      expect(find.text('Ver no GitHub'), findsOneWidget);
    });
  });
}

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
        ReleaseAsset(
          id: 102,
          name: 'DeskYPT-Linux-x64.deb',
          size: 50000000,
          downloadUrl: 'https://github.com/test/download.deb',
          contentType: 'application/vnd.debian.binary-package',
        ),
        ReleaseAsset(
          id: 103,
          name: 'DeskYPT-macOS-Installer.dmg',
          size: 50000000,
          downloadUrl: 'https://github.com/test/download.dmg',
          contentType: 'application/x-apple-diskimage',
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

    testWidgets('UpdateDialog renders changelog with Markdown formatting', (tester) async {
      const markdownRelease = AppRelease(
        id: 1000,
        tagName: 'v1.5.0',
        name: 'DeskYPT v1.5.0 - Super Speed',
        body: '### ✨ Features\n- **Super Timer**: 10x faster\n- `AppConstants` updated\n\nVisit [GitHub](https://github.com/huneyoliv/deskypt)',
        htmlUrl: 'https://github.com/huneyoliv/deskypt/releases/tag/v1.5.0',
        assets: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appTranslationProvider.overrideWith(
              (ref) => AppTranslationNotifier(ref),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UpdateDialog(release: markdownRelease),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Atualização Disponível'), findsOneWidget);
      expect(find.text('v1.5.0'), findsOneWidget);
      expect(find.textContaining('Super Timer'), findsOneWidget);
      expect(find.textContaining('10x faster'), findsOneWidget);
      expect(find.text('Ver no GitHub'), findsOneWidget);
    });

    testWidgets('UpdateDialog renders fallback text when release body is empty', (tester) async {
      const emptyRelease = AppRelease(
        id: 1001,
        tagName: 'v1.6.0',
        name: 'DeskYPT v1.6.0',
        body: '',
        htmlUrl: 'https://github.com/huneyoliv/deskypt/releases/tag/v1.6.0',
        assets: [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appTranslationProvider.overrideWith(
              (ref) => AppTranslationNotifier(ref),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UpdateDialog(release: emptyRelease),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Melhorias de desempenho e correções gerais.'), findsOneWidget);
    });
  });
}

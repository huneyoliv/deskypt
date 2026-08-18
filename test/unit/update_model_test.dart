import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/features/updates/models/update_model.dart';

void main() {
  group('UpdateModel Tests', () {
    final sampleJson = {
      'id': 123456,
      'tag_name': 'v1.1.0',
      'name': 'DeskYPT v1.1.0 - Major Performance Update',
      'body': '### Novidades\n- Novo modo Pomodoro\n- Melhorias no Cam Study',
      'html_url': 'https://github.com/huneyoliv/deskypt/releases/tag/v1.1.0',
      'published_at': '2026-08-18T10:00:00Z',
      'prerelease': false,
      'draft': false,
      'assets': [
        {
          'id': 1,
          'name': 'DeskYPT-Windows-Installer-x64.exe',
          'size': 45000000,
          'browser_download_url':
              'https://github.com/huneyoliv/deskypt/releases/download/v1.1.0/DeskYPT-Windows-Installer-x64.exe',
          'content_type': 'application/x-msdownload',
        },
        {
          'id': 2,
          'name': 'DeskYPT-macOS-Installer.dmg',
          'size': 48000000,
          'browser_download_url':
              'https://github.com/huneyoliv/deskypt/releases/download/v1.1.0/DeskYPT-macOS-Installer.dmg',
          'content_type': 'application/x-apple-diskimage',
        },
        {
          'id': 3,
          'name': 'DeskYPT-Linux-x64.deb',
          'size': 42000000,
          'browser_download_url':
              'https://github.com/huneyoliv/deskypt/releases/download/v1.1.0/DeskYPT-Linux-x64.deb',
          'content_type': 'application/vnd.debian.binary-package',
        },
      ],
    };

    test('AppRelease.fromJson parses fields accurately', () {
      final release = AppRelease.fromJson(sampleJson);

      expect(release.id, 123456);
      expect(release.tagName, 'v1.1.0');
      expect(release.cleanVersion, '1.1.0');
      expect(release.name, contains('DeskYPT v1.1.0'));
      expect(release.body, contains('Novo modo Pomodoro'));
      expect(release.htmlUrl, contains('github.com'));
      expect(release.publishedAt, isNotNull);
      expect(release.assets.length, 3);
      expect(release.assets[0].name, 'DeskYPT-Windows-Installer-x64.exe');
    });

    test('isNewerThan compares SemVer correctly', () {
      final release = AppRelease.fromJson(sampleJson);

      expect(release.isNewerThan('1.0.0'), isTrue);
      expect(release.isNewerThan('v1.0.0'), isTrue);
      expect(release.isNewerThan('1.0.9'), isTrue);
      expect(release.isNewerThan('1.1.0'), isFalse);
      expect(release.isNewerThan('1.1.1'), isFalse);
      expect(release.isNewerThan('2.0.0'), isFalse);
    });

    test('getAssetForPlatform retrieves appropriate installer per OS', () {
      final release = AppRelease.fromJson(sampleJson);

      final winAsset = release.getAssetForPlatform(TargetPlatform.windows);
      expect(winAsset, isNotNull);
      expect(winAsset!.name, endsWith('.exe'));

      final macAsset = release.getAssetForPlatform(TargetPlatform.macOS);
      expect(macAsset, isNotNull);
      expect(macAsset!.name, endsWith('.dmg'));

      final linuxAsset = release.getAssetForPlatform(TargetPlatform.linux);
      expect(linuxAsset, isNotNull);
      expect(linuxAsset!.name, endsWith('.deb'));
    });
  });
}

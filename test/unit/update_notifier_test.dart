import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/core/services/update_service.dart';
import 'package:deskypt/features/updates/models/update_model.dart';
import 'package:deskypt/features/updates/update_notifier.dart';

class FakeUpdateService extends UpdateService {
  AppRelease? simulatedRelease;
  bool shouldThrow = false;

  FakeUpdateService({this.simulatedRelease});

  @override
  Future<AppRelease?> fetchLatestRelease() async {
    if (shouldThrow) {
      throw Exception('Server unreachable');
    }
    return simulatedRelease;
  }
}

void main() {
  group('UpdateNotifier Tests', () {
    test('initializes and triggers update check', () async {
      final fakeRelease = const AppRelease(
        id: 10,
        tagName: 'v1.2.0',
        name: 'DeskYPT 1.2.0',
        body: 'Improvements',
        htmlUrl: 'https://github.com',
      );

      final service = FakeUpdateService(simulatedRelease: fakeRelease);
      final notifier = UpdateNotifier(service: service, currentVersion: '1.0.0');

      await Future.delayed(const Duration(milliseconds: 10));

      expect(notifier.state.hasUpdate, isTrue);
      expect(notifier.state.latestRelease?.tagName, 'v1.2.0');
      expect(notifier.state.isChecking, isFalse);
    });

    test('detects when app is up to date', () async {
      final fakeRelease = const AppRelease(
        id: 10,
        tagName: 'v1.0.0',
        name: 'DeskYPT 1.0.0',
        body: 'Current version',
        htmlUrl: 'https://github.com',
      );

      final service = FakeUpdateService(simulatedRelease: fakeRelease);
      final notifier = UpdateNotifier(service: service, currentVersion: '1.0.0');

      await Future.delayed(const Duration(milliseconds: 10));

      expect(notifier.state.hasUpdate, isFalse);
      expect(notifier.state.latestRelease?.tagName, 'v1.0.0');
    });

    test('handles errors during update check', () async {
      final service = FakeUpdateService();
      service.shouldThrow = true;

      final notifier = UpdateNotifier(service: service, currentVersion: '1.0.0');
      await Future.delayed(const Duration(milliseconds: 10));

      expect(notifier.state.errorMessage, isNotNull);
      expect(notifier.state.hasUpdate, isFalse);
      expect(notifier.state.isChecking, isFalse);
    });
  });
}

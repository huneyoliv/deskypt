import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/core/cdn/cdn_resolver.dart';

void main() {
  group('Studicon and CdnResolver Tests', () {
    test('studiconUrl generates valid CDN URLs for all poses', () {
      expect(CdnResolver.studiconUrl(10, StudiconPose.normal1), equals('https://alicdn.tgclab.com/sc.v2/10/normal1.png'));
      expect(CdnResolver.studiconUrl(10, StudiconPose.sweat1), equals('https://alicdn.tgclab.com/sc.v2/10/sweat1.png'));
      expect(CdnResolver.studiconUrl(10, StudiconPose.sweat2), equals('https://alicdn.tgclab.com/sc.v2/10/sweat2.png'));
      expect(CdnResolver.studiconUrl(10, StudiconPose.ignite1), equals('https://alicdn.tgclab.com/sc.v2/10/ignite1.png'));
      expect(CdnResolver.studiconUrl(10, StudiconPose.smoke1), equals('https://alicdn.tgclab.com/sc.v2/10/smoke1.png'));
      expect(CdnResolver.studiconUrl(10, StudiconPose.fire1), equals('https://alicdn.tgclab.com/sc.v2/10/fire1.png'));
    });

    test('studiconUrl resolves negative or 0 ID as -1 default orange avatar', () {
      expect(CdnResolver.studiconUrl(-1, StudiconPose.normal1), equals('https://alicdn.tgclab.com/sc.v2/-1/normal1.png'));
      expect(CdnResolver.studiconUrl(0, StudiconPose.normal1), equals('https://alicdn.tgclab.com/sc.v2/-1/normal1.png'));
    });

    test('userAvatarUrl handles custom avatar and dynamically selects poses', () {
      final customUrl = CdnResolver.userAvatarUrl(
        userId: 12345,
        hasCustomAvatar: true,
        studiconId: 10,
        isStudying: true,
        studyMs: 10000,
      );
      expect(customUrl, equals('https://alicdn.tgclab.com/user/profile/12345.jpg'));

      final fireUrl = CdnResolver.userAvatarUrl(
        userId: 12345,
        hasCustomAvatar: false,
        studiconId: 10,
        isStudying: true,
        studyMs: 14400000,
        dailyGoalMs: 14400000,
      );
      expect(fireUrl, contains('/10/fire1.png'));

      final smokeUrl = CdnResolver.userAvatarUrl(
        userId: 12345,
        hasCustomAvatar: false,
        studiconId: 10,
        isStudying: true,
        isPaused: true,
        studyMs: 1000,
      );
      expect(smokeUrl, contains('/10/smoke1.png'));
    });

    test('camStudyUrl and chatPhotoUrl format paths correctly', () {
      expect(CdnResolver.camStudyUrl('2026-08-16', 77), equals('https://alicdn.tgclab.com/cam/2026-08-16/77'));
      expect(CdnResolver.chatPhotoUrl('chat/img_123.jpg'), equals('https://alicdn.tgclab.com/chat/img_123.jpg'));
      expect(CdnResolver.chatPhotoUrl('https://example.com/custom.png'), equals('https://example.com/custom.png'));
    });
  });
}

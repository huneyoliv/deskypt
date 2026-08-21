import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/core/oauth/providers/google_oauth_service.dart';
import 'package:deskypt/core/oauth/providers/kakao_oauth_service.dart';
import 'package:deskypt/core/oauth/providers/naver_oauth_service.dart';

void main() {
  group('GoogleOAuthService configuration & instantiation', () {
    test('instantiates with default client id and secret', () {
      final service = GoogleOAuthService();
      expect(service.clientId, equals(GoogleOAuthService.defaultClientId));
      expect(service.clientSecret, equals(GoogleOAuthService.defaultClientSecret));
      expect(service.clientId.contains('googleusercontent.com'), isTrue);
    });

    test('accepts custom client id and secret', () {
      final service = GoogleOAuthService(
        clientId: 'custom-client-id.apps.googleusercontent.com',
        clientSecret: 'custom-secret',
      );
      expect(service.clientId, equals('custom-client-id.apps.googleusercontent.com'));
      expect(service.clientSecret, equals('custom-secret'));
    });
  });

  group('KakaoOAuthService configuration & instantiation', () {
    test('instantiates with default client id', () {
      final service = KakaoOAuthService();
      expect(service.clientId, equals(KakaoOAuthService.defaultClientId));
      expect(service.clientId.isNotEmpty, isTrue);
    });

    test('accepts custom client id', () {
      final service = KakaoOAuthService(clientId: 'custom-kakao-key');
      expect(service.clientId, equals('custom-kakao-key'));
    });
  });

  group('NaverOAuthService configuration & instantiation', () {
    test('instantiates with default client id and secret', () {
      final service = NaverOAuthService();
      expect(service.clientId, equals(NaverOAuthService.defaultClientId));
      expect(service.clientSecret, equals(NaverOAuthService.defaultClientSecret));
    });

    test('accepts custom client id and secret', () {
      final service = NaverOAuthService(
        clientId: 'custom-naver-id',
        clientSecret: 'custom-naver-secret',
      );
      expect(service.clientId, equals('custom-naver-id'));
      expect(service.clientSecret, equals('custom-naver-secret'));
    });
  });
}

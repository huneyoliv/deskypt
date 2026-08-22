import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/core/oauth/oauth_exception.dart';
import 'package:deskypt/core/oauth/oauth_user_info.dart';
import 'package:deskypt/core/oauth/providers/kakao_oauth_service.dart';
import 'package:deskypt/core/oauth/providers/naver_oauth_service.dart';
import 'package:deskypt/data/models/user_model.dart';
import 'package:deskypt/data/repositories/auth_repository.dart';
import 'package:deskypt/features/auth/auth_notifier.dart';

class MockAuthRepository extends AuthRepository {
  OAuthUserInfo? lastSocialLogin;
  bool shouldFail = false;

  @override
  Future<UserModel> signInWithSocial({
    required String provider,
    required String socialId,
    required String email,
    required String name,
    String language = 'pt',
  }) async {
    if (shouldFail) {
      throw Exception('Falha ao autenticar no backend');
    }
    lastSocialLogin = OAuthUserInfo(
      provider: provider,
      socialId: socialId,
      email: email,
      name: name,
    );
    return UserModel(
      id: 123,
      name: name,
      email: email,
      studiconId: 19,
      jwtToken: 'jwt_mock_token_123',
    );
  }
}

class MockKakaoOAuthService extends KakaoOAuthService {
  bool shouldCancel = false;

  @override
  Future<OAuthUserInfo> authenticate({Duration timeout = const Duration(minutes: 3)}) async {
    if (shouldCancel) {
      throw const OAuthException('User cancelled', isCancelled: true);
    }
    return const OAuthUserInfo(
      provider: 'Kakao',
      socialId: 'kakao_id_888',
      email: 'user@kakao.com',
      name: 'Kakao User',
    );
  }

  @override
  Future<void> cancel() async {}
}

class MockNaverOAuthService extends NaverOAuthService {
  bool shouldCancel = false;

  @override
  Future<OAuthUserInfo> authenticate({Duration timeout = const Duration(minutes: 3)}) async {
    if (shouldCancel) {
      throw const OAuthException('User cancelled', isCancelled: true);
    }
    return const OAuthUserInfo(
      provider: 'Naver',
      socialId: 'naver_id_777',
      email: 'user@naver.com',
      name: 'Naver User',
    );
  }

  @override
  Future<void> cancel() async {}
}

void main() {
  group('AuthNotifier Social Login Tests', () {
    late MockAuthRepository mockRepo;
    late MockKakaoOAuthService mockKakao;
    late MockNaverOAuthService mockNaver;
    late AuthNotifier notifier;

    setUp(() {
      mockRepo = MockAuthRepository();
      mockKakao = MockKakaoOAuthService();
      mockNaver = MockNaverOAuthService();
      notifier = AuthNotifier(
        mockRepo,
        kakaoOAuthService: mockKakao,
        naverOAuthService: mockNaver,
      );
    });

    test('signInWithKakao authenticates user and updates state', () async {
      await notifier.signInWithKakao();

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.email, equals('user@kakao.com'));
      expect(notifier.state.user?.jwtToken, equals('jwt_mock_token_123'));
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
      expect(mockRepo.lastSocialLogin?.provider, equals('Kakao'));
    });

    test('signInWithNaver authenticates user and updates state', () async {
      await notifier.signInWithNaver();

      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.user?.email, equals('user@naver.com'));
      expect(notifier.state.user?.jwtToken, equals('jwt_mock_token_123'));
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.errorMessage, isNull);
      expect(mockRepo.lastSocialLogin?.provider, equals('Naver'));
    });

    test('cancelOAuth cancels active oauth services and resets loading', () async {
      notifier.state = notifier.state.copyWith(isLoading: true);
      await notifier.cancelOAuth();

      expect(notifier.state.isLoading, isFalse);
    });
  });
}

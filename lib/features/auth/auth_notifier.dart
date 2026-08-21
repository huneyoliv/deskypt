import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/oauth/oauth_exception.dart';
import '../../core/oauth/providers/google_oauth_service.dart';
import '../../core/oauth/providers/kakao_oauth_service.dart';
import '../../core/oauth/providers/naver_oauth_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final googleOAuthServiceProvider = Provider<GoogleOAuthService>((ref) {
  return GoogleOAuthService();
});

final kakaoOAuthServiceProvider = Provider<KakaoOAuthService>((ref) {
  return KakaoOAuthService();
});

final naverOAuthServiceProvider = Provider<NaverOAuthService>((ref) {
  return NaverOAuthService();
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final GoogleOAuthService _googleOAuthService;
  final KakaoOAuthService _kakaoOAuthService;
  final NaverOAuthService _naverOAuthService;

  AuthNotifier(
    this._repository, {
    GoogleOAuthService? googleOAuthService,
    KakaoOAuthService? kakaoOAuthService,
    NaverOAuthService? naverOAuthService,
  })  : _googleOAuthService = googleOAuthService ?? GoogleOAuthService(),
        _kakaoOAuthService = kakaoOAuthService ?? KakaoOAuthService(),
        _naverOAuthService = naverOAuthService ?? NaverOAuthService(),
        super(const AuthState());

  String _formatError(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'Tempo limite de conexão esgotado. Verifique sua internet.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Falha de conexão com o servidor da TGC Lab / YPT.';
      }
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        if (data['c'] == '112') return 'Senha incorreta. Verifique sua senha e tente novamente.';
        if (data['c'] == '113') return 'E-mail não cadastrado no Yeolpumta.';
        if (data['c'] == '114') return 'Conta suspensa ou inativa.';
        if (data['m'] != null) return data['m'].toString();
      }
    }
    return e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.tryRestoreSession();
      if (user != null) {
        state = AuthState(user: user, isLoading: false);
      } else {
        state = const AuthState(isLoading: false);
      }
    } catch (_) {
      state = const AuthState(isLoading: false);
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatError(e),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userInfo = await _googleOAuthService.authenticate();
      final user = await _repository.signInWithSocial(
        provider: userInfo.provider,
        socialId: userInfo.socialId,
        email: userInfo.email,
        name: userInfo.name,
      );
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      if (e is OAuthException && e.isCancelled) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatError(e),
      );
    }
  }

  Future<void> signInWithKakao() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userInfo = await _kakaoOAuthService.authenticate();
      final user = await _repository.signInWithSocial(
        provider: userInfo.provider,
        socialId: userInfo.socialId,
        email: userInfo.email,
        name: userInfo.name,
      );
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      if (e is OAuthException && e.isCancelled) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatError(e),
      );
    }
  }

  Future<void> signInWithNaver() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userInfo = await _naverOAuthService.authenticate();
      final user = await _repository.signInWithSocial(
        provider: userInfo.provider,
        socialId: userInfo.socialId,
        email: userInfo.email,
        name: userInfo.name,
      );
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      if (e is OAuthException && e.isCancelled) {
        state = state.copyWith(isLoading: false);
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: _formatError(e),
      );
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(
      isLoading: false,
      errorMessage: 'alert_user_sign_in_apple_msg',
    );
  }

  Future<void> cancelOAuth() async {
    await _googleOAuthService.cancel();
    await _kakaoOAuthService.cancel();
    await _naverOAuthService.cancel();
    state = state.copyWith(isLoading: false);
  }

  Future<bool> updateNickname(String newNickname) async {
    final success = await _repository.changeNickname(newNickname);
    if (success && state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(name: newNickname),
      );
    }
    return success;
  }

  Future<bool> updateStatusMessage(String newStatusMsg) async {
    final success = await _repository.changeStatusMessage(newStatusMsg);
    if (success && state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(statusMessage: newStatusMsg),
      );
    }
    return success;
  }

  Future<bool> updateCategory(int categoryId, String defaultTitle) async {
    final res = await _repository.changeCategory(categoryId);
    if (res != null && state.user != null) {
      final categoryName = (res['ct'] as String?) ?? defaultTitle;
      state = state.copyWith(
        user: state.user!.copyWith(
          categoryId: categoryId,
          categoryName: categoryName,
        ),
      );
      return true;
    }
    return false;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String nickname,
    required int categoryId,
    required int countryId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _repository.signUp(
        email: email,
        password: password,
        nickname: nickname,
        categoryId: categoryId,
        countryId: countryId,
      );
      state = AuthState(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _repository.deleteAccount();
      if (success) {
        state = const AuthState();
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Falha ao excluir conta. Tente novamente.',
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> refreshUserGroups() async {
    try {
      final groups = await _repository.fetchUserGroups();
      if (state.user != null && groups.isNotEmpty) {
        final updatedUser = state.user!.copyWith(userGroups: groups);
        state = state.copyWith(user: updatedUser);
        await _repository.cacheUser(updatedUser);
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final googleOAuth = ref.watch(googleOAuthServiceProvider);
  final kakaoOAuth = ref.watch(kakaoOAuthServiceProvider);
  final naverOAuth = ref.watch(naverOAuthServiceProvider);
  return AuthNotifier(
    repository,
    googleOAuthService: googleOAuth,
    kakaoOAuthService: kakaoOAuth,
    naverOAuthService: naverOAuth,
  );
});

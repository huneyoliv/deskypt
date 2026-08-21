import 'package:dio/dio.dart';
import '../oauth_desktop_service.dart';
import '../oauth_exception.dart';
import '../oauth_pkce.dart';
import '../oauth_user_info.dart';

class KakaoOAuthService {
  final Dio _dio;
  final OAuthDesktopService _desktopService;
  final String clientId;

  static const String defaultClientId = 'da929e6e12cac448477e77644e3be131';

  KakaoOAuthService({
    Dio? dio,
    OAuthDesktopService? desktopService,
    String? clientId,
  })  : _dio = dio ?? Dio(),
        _desktopService = desktopService ?? OAuthDesktopService(),
        clientId = clientId ?? defaultClientId;

  Future<OAuthUserInfo> authenticate({
    Duration timeout = const Duration(minutes: 3),
  }) async {
    final state = OAuthPkce.generateState();
    int? activePort;

    try {
      final callbackParams = await _desktopService.startAuthFlow(
        authUrlBuilder: (port) {
          activePort = port;
          final redirectUri = 'http://127.0.0.1:$port/oauth';
          return Uri.https('kauth.kakao.com', '/oauth/authorize', {
            'client_id': clientId,
            'redirect_uri': redirectUri,
            'response_type': 'code',
            'state': state,
          });
        },
        expectedState: state,
        timeout: timeout,
      );

      final code = callbackParams['code'];
      if (code == null || code.isEmpty) {
        throw const OAuthException('Código de autorização não recebido do Kakao.');
      }

      final redirectUri = 'http://127.0.0.1:$activePort/oauth';
      final tokenResponse = await _dio.post(
        'https://kauth.kakao.com/oauth/token',
        data: {
          'grant_type': 'authorization_code',
          'client_id': clientId,
          'redirect_uri': redirectUri,
          'code': code,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final tokenData = tokenResponse.data;
      if (tokenData is! Map || tokenData['access_token'] == null) {
        final errorDesc = tokenData is Map
            ? (tokenData['error_description'] ?? tokenData['error'] ?? 'Falha ao trocar código Kakao por token')
            : 'Resposta inválida do servidor Kakao';
        throw OAuthException(errorDesc.toString());
      }

      final accessToken = tokenData['access_token'].toString();

      final userResponse = await _dio.get(
        'https://kapi.kakao.com/v2/user/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final userData = userResponse.data;
      if (userData is! Map || userData['id'] == null) {
        throw const OAuthException('Não foi possível obter dados do perfil Kakao.');
      }

      final socialId = userData['id'].toString();
      final kakaoAccount = userData['kakao_account'] as Map?;
      final properties = userData['properties'] as Map?;

      final email = kakaoAccount?['email']?.toString() ?? 'kakao_$socialId@kakao.com';
      final name = properties?['nickname']?.toString() ??
          kakaoAccount?['profile']?['nickname']?.toString() ??
          'Usuário Kakao';

      return OAuthUserInfo(
        provider: 'Kakao',
        socialId: socialId,
        email: email,
        name: name,
      );
    } catch (e) {
      if (e is OAuthException) rethrow;
      throw OAuthException('Erro ao autenticar com Kakao: $e');
    }
  }

  Future<void> cancel() => _desktopService.cancel();
}

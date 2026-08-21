import 'package:dio/dio.dart';
import '../oauth_desktop_service.dart';
import '../oauth_exception.dart';
import '../oauth_pkce.dart';
import '../oauth_user_info.dart';

class NaverOAuthService {
  final Dio _dio;
  final OAuthDesktopService _desktopService;
  final String clientId;
  final String clientSecret;

  static const String defaultClientId = '4pErv_GmX2TyYf5HhV4y';
  static const String defaultClientSecret = 'RUw5ntdTX7';

  NaverOAuthService({
    Dio? dio,
    OAuthDesktopService? desktopService,
    String? clientId,
    String? clientSecret,
  })  : _dio = dio ?? Dio(),
        _desktopService = desktopService ?? OAuthDesktopService(),
        clientId = clientId ?? defaultClientId,
        clientSecret = clientSecret ?? defaultClientSecret;

  Future<OAuthUserInfo> authenticate({
    Duration timeout = const Duration(minutes: 3),
  }) async {
    final state = OAuthPkce.generateState();

    try {
      final callbackParams = await _desktopService.startAuthFlow(
        authUrlBuilder: (port) {
          final redirectUri = 'http://127.0.0.1:$port/oauth';
          return Uri.https('nid.naver.com', '/oauth2.0/authorize', {
            'response_type': 'code',
            'client_id': clientId,
            'redirect_uri': redirectUri,
            'state': state,
          });
        },
        expectedState: state,
        timeout: timeout,
      );

      final code = callbackParams['code'];
      if (code == null || code.isEmpty) {
        throw const OAuthException('Código de autorização não recebido do Naver.');
      }

      final tokenResponse = await _dio.post(
        'https://nid.naver.com/oauth2.0/token',
        data: {
          'grant_type': 'authorization_code',
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': code,
          'state': state,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final tokenData = tokenResponse.data;
      if (tokenData is! Map || tokenData['access_token'] == null) {
        final errorDesc = tokenData is Map
            ? (tokenData['error_description'] ?? tokenData['error'] ?? 'Falha ao obter token Naver')
            : 'Resposta inválida do servidor Naver';
        throw OAuthException(errorDesc.toString());
      }

      final accessToken = tokenData['access_token'].toString();

      final userResponse = await _dio.get(
        'https://openapi.naver.com/v1/nid/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final userData = userResponse.data;
      final responseObj = userData is Map ? userData['response'] as Map? : null;

      if (responseObj == null || responseObj['id'] == null) {
        throw const OAuthException('Não foi possível obter os dados de perfil do Naver.');
      }

      final socialId = responseObj['id'].toString();
      final email = responseObj['email']?.toString() ?? 'naver_$socialId@naver.com';
      final name = responseObj['name']?.toString() ??
          responseObj['nickname']?.toString() ??
          'Usuário Naver';

      return OAuthUserInfo(
        provider: 'Naver',
        socialId: socialId,
        email: email,
        name: name,
      );
    } catch (e) {
      if (e is OAuthException) rethrow;
      throw OAuthException('Erro ao autenticar com Naver: $e');
    }
  }

  Future<void> cancel() => _desktopService.cancel();
}

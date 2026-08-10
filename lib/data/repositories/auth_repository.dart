import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api/api_client.dart';
import '../../core/api/auth_interceptor.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  AuthRepository({
    ApiClient? apiClient,
    FlutterSecureStorage? storage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.signInJwt,
      data: {
        'email': email,
        'password': password,
        'loginProvider': 'Email',
        'new': true,
        'getx': true,
        'language': 'pt',
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['s'] != true) {
      throw Exception(data['m'] ?? 'Falha ao autenticar');
    }

    final token = data['jwt'] as String;
    await _storage.write(key: AuthInterceptor.keyJwtToken, value: token);

    // Call splash-login after authentication
    try {
      await splashLogin();
    } catch (_) {
      // Ignorar erros secundários de splash login se autenticou com sucesso
    }

    return UserModel.fromJson(data, token);
  }

  Future<UserModel> signInWithSocial({
    required String provider, // "Google" or "Apple"
    required String socialId,
    required String email,
    required String name,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.signInJwt,
      data: {
        'email': email,
        'socialId': socialId,
        'name': name,
        'loginProvider': provider,
        'new': true,
        'getx': true,
        'language': 'pt',
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['s'] != true) {
      throw Exception(data['m'] ?? 'Falha ao autenticar via $provider');
    }

    final token = data['jwt'] as String;
    await _storage.write(key: AuthInterceptor.keyJwtToken, value: token);

    try {
      await splashLogin();
    } catch (_) {}

    return UserModel.fromJson(data, token);
  }

  Future<void> splashLogin() async {
    await _apiClient.post(
      ApiConstants.splashLogin,
      data: {
        'version': 810041,
        'pushToken': '',
        'timezone': 'America/Sao_Paulo',
        'deviceType': 'WIN',
        'osVersion': 10,
        'deviceModel': 'Desktop',
        'pv': 19,
        'language': 'pt',
      },
    );
  }

  Future<String?> getStoredToken() async {
    return _storage.read(key: AuthInterceptor.keyJwtToken);
  }

  Future<void> logout() async {
    await _storage.delete(key: AuthInterceptor.keyJwtToken);
  }
}

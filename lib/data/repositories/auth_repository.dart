import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
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

    final data = response.data;
    if (data is! Map<String, dynamic> || data['s'] != true) {
      final msg = (data is Map && (data['m'] != null || data['message'] != null))
          ? (data['m'] ?? data['message']).toString()
          : 'E-mail ou senha incorretos';
      throw ApiException(msg, statusCode: response.statusCode);
    }

    final token = (data['jwt'] ?? '').toString();
    if (token.isEmpty) {
      throw const ApiException('Token JWT não foi retornado pelo servidor');
    }

    await _storage.write(key: AuthInterceptor.keyJwtToken, value: token);

    try {
      await splashLogin();
    } catch (_) {}

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

    final data = response.data;
    if (data is! Map<String, dynamic> || data['s'] != true) {
      final msg = (data is Map && (data['m'] != null || data['message'] != null))
          ? (data['m'] ?? data['message']).toString()
          : 'Falha ao autenticar via $provider';
      throw ApiException(msg, statusCode: response.statusCode);
    }

    final token = (data['jwt'] ?? '').toString();
    if (token.isEmpty) {
      throw ApiException('Token JWT via $provider não retornado pelo servidor');
    }

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

  Future<bool> changeNickname(String nickname) async {
    try {
      final response = await _apiClient.post(
        '/user/nickname/change',
        data: {'nickname': nickname},
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['s'] == true;
    } catch (_) {}
    return false;
  }

  Future<bool> changeStatusMessage(String statusMsg) async {
    try {
      final response = await _apiClient.post(
        '/user/status_msg/change',
        data: {'statusMsg': statusMsg},
      );
      final data = response.data;
      return data is Map<String, dynamic> && data['s'] == true;
    } catch (_) {}
    return false;
  }

  Future<Map<String, dynamic>?> changeCategory(int categoryId) async {
    try {
      final response = await _apiClient.post(
        '/category/category-by-country',
        data: {'category_id': categoryId},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['s'] == true) {
        return data;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> sendPasswordResetCode(String email) async {
    final response = await _apiClient.post(
      '/user/v2/send-password-reset-code',
      data: {
        'email': email,
        'language': 'pt',
      },
    );
    final data = response.data;
    return data is Map<String, dynamic> && data['s'] == true;
  }

  Future<bool> verifyPasswordResetCode(String email, String code) async {
    final response = await _apiClient.post(
      '/user/v2/verify-code',
      data: {
        'email': email,
        'code': code,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['s'] == false) {
      final msg = data['c'] == 'invalid_auth_code_msg'
          ? 'Código de validação inválido'
          : 'Código incorreto';
      throw ApiException(msg);
    }
    return data is Map<String, dynamic> && data['s'] == true;
  }

  Future<UserModel> resetPassword({
    required String email,
    required String password,
    required String code,
  }) async {
    final response = await _apiClient.post(
      '/user/v2/reset-password',
      data: {
        'email': email,
        'password': password,
        'code': code,
      },
    );
    final data = response.data;
    if (data is! Map<String, dynamic> || data['s'] != true) {
      throw const ApiException('Falha ao redefinir senha');
    }
    final token = (data['jwt'] ?? '').toString();
    if (token.isNotEmpty) {
      await _storage.write(key: AuthInterceptor.keyJwtToken, value: token);
    }
    return UserModel.fromJson(data, token);
  }

  Future<bool> sendSignUpVerificationCode(String email) async {
    final response = await _apiClient.post(
      '/user/auth/check-email',
      data: {
        'email': email,
        'language': 'pt',
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['s'] == false) {
      final msg = data['m'] ?? data['message'] ?? 'E-mail já cadastrado ou inválido';
      throw ApiException(msg.toString());
    }
    return data is Map<String, dynamic> && data['s'] == true;
  }

  Future<bool> verifySignUpCode(String email, String code) async {
    final response = await _apiClient.post(
      '/user/auth/verify-code',
      data: {
        'email': email,
        'code': code,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['s'] == false) {
      final msg = data['c'] == 'invalid_auth_code_msg'
          ? 'Código de validação inválido'
          : (data['m'] ?? 'Código de verificação incorreto');
      throw ApiException(msg.toString());
    }
    return data is Map<String, dynamic> && data['s'] == true;
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String nickname,
    required int categoryId,
    required int countryId,
  }) async {
    final response = await _apiClient.post(
      '/user/auth/join',
      data: {
        'email': email,
        'password': password,
        'nickname': nickname,
        'category_id': categoryId,
        'country_id': countryId,
        'language': 'pt',
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['s'] != true) {
      final msg = (data is Map && (data['m'] != null || data['message'] != null))
          ? (data['m'] ?? data['message']).toString()
          : 'Erro ao realizar cadastro';
      throw ApiException(msg, statusCode: response.statusCode);
    }

    final token = (data['jwt'] ?? '').toString();
    if (token.isNotEmpty) {
      await _storage.write(key: AuthInterceptor.keyJwtToken, value: token);
    }

    try {
      await splashLogin();
    } catch (_) {}

    return UserModel.fromJson(data, token);
  }

  Future<String?> getStoredToken() async {
    return _storage.read(key: AuthInterceptor.keyJwtToken);
  }

  Future<bool> deleteAccount() async {
    final response = await _apiClient.post('/user/delete');
    final data = response.data;
    final isSuccess = data is Map<String, dynamic> && data['s'] == true;
    if (isSuccess) {
      await _storage.delete(key: AuthInterceptor.keyJwtToken);
    }
    return isSuccess;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/user/logout', data: {'pushToken': ''});
    } catch (_) {}
    await _storage.delete(key: AuthInterceptor.keyJwtToken);
  }
}

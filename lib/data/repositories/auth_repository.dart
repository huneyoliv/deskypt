import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/api/auth_interceptor.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/group_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;
  static const String keyCachedUser = 'cached_user_profile';

  AuthRepository({
    ApiClient? apiClient,
    FlutterSecureStorage? storage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<void> _saveToken(String token) async {
    try {
      await _storage.write(key: AuthInterceptor.keyJwtToken, value: token);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AuthInterceptor.keyJwtToken, token);
    } catch (_) {}
  }

  Future<void> _deleteToken() async {
    try {
      await _storage.delete(key: AuthInterceptor.keyJwtToken);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AuthInterceptor.keyJwtToken);
      await prefs.remove(keyCachedUser);
    } catch (_) {}
  }

  Future<void> _cacheUserData(Map<String, dynamic> data, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = UserModel.fromJson(data, token);
      await prefs.setString(keyCachedUser, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
    String language = ApiConstants.defaultLanguage,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.signInJwt,
      data: {
        'email': email,
        'password': password,
        'loginProvider': 'Email',
        'new': true,
        'getx': true,
        'language': language,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['s'] != true) {
      String msg = 'E-mail ou senha incorretos';
      if (data is Map) {
        if (data['m'] != null || data['message'] != null) {
          msg = (data['m'] ?? data['message']).toString();
        } else if (data['c'] != null) {
          final code = data['c'].toString();
          if (code == '112') {
            msg = 'Senha incorreta. Verifique sua senha e tente novamente.';
          } else if (code == '113') {
            msg = 'E-mail não cadastrado no Yeolpumta.';
          } else if (code == '114') {
            msg = 'Conta suspensa ou inativa.';
          } else {
            msg = 'Falha na autenticação (código $code)';
          }
        }
      }
      throw ApiException(msg, statusCode: response.statusCode);
    }

    final token = (data['jwt'] ?? '').toString();
    if (token.isEmpty) {
      throw const ApiException('Token JWT não foi retornado pelo servidor');
    }

    await _saveToken(token);

    try {
      final splashData = await splashLogin(language: language);
      if (splashData != null && splashData['gs'] != null) {
        data['gs'] = splashData['gs'];
      }
    } catch (_) {}

    await _cacheUserData(data, token);
    return UserModel.fromJson(data, token);
  }

  Future<UserModel> signInWithSocial({
    required String provider, // "Google" or "Apple"
    required String socialId,
    required String email,
    required String name,
    String language = ApiConstants.defaultLanguage,
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
        'language': language,
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

    await _saveToken(token);

    try {
      final splashData = await splashLogin(language: language);
      if (splashData != null && splashData['gs'] != null) {
        data['gs'] = splashData['gs'];
      }
    } catch (_) {}

    await _cacheUserData(data, token);
    return UserModel.fromJson(data, token);
  }

  Future<Map<String, dynamic>?> splashLogin({
    String language = ApiConstants.defaultLanguage,
    String timezone = ApiConstants.defaultTimezone,
    int version = ApiConstants.defaultVersion,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.splashLogin,
        data: {
          'version': version,
          'pushToken': '',
          'timezone': timezone,
          'deviceType': ApiConstants.defaultDeviceType,
          'osVersion': 10,
          'deviceModel': ApiConstants.defaultDeviceModel,
          'pv': 19,
          'language': language,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['s'] == true) {
        return data;
      }
    } catch (_) {}
    return null;
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

  Future<bool> sendPasswordResetCode(
    String email, {
    String language = ApiConstants.defaultLanguage,
  }) async {
    final response = await _apiClient.post(
      '/user/v2/send-password-reset-code',
      data: {
        'email': email,
        'language': language,
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
      await _saveToken(token);
      await _cacheUserData(data, token);
    }
    return UserModel.fromJson(data, token);
  }

  Future<bool> sendSignUpVerificationCode(
    String email, {
    String language = ApiConstants.defaultLanguage,
  }) async {
    final response = await _apiClient.post(
      '/user/auth/check-email',
      data: {
        'email': email,
        'language': language,
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
    String language = ApiConstants.defaultLanguage,
  }) async {
    final response = await _apiClient.post(
      '/user/auth/join',
      data: {
        'email': email,
        'password': password,
        'nickname': nickname,
        'category_id': categoryId,
        'country_id': countryId,
        'language': language,
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
      await _saveToken(token);
      await _cacheUserData(data, token);
    }

    try {
      await splashLogin(language: language);
    } catch (_) {}

    return UserModel.fromJson(data, token);
  }

  Future<String?> getStoredToken() async {
    try {
      final token = await _storage
          .read(key: AuthInterceptor.keyJwtToken)
          .timeout(const Duration(seconds: 2), onTimeout: () => null);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AuthInterceptor.keyJwtToken);
    } catch (_) {}
    return null;
  }

  Future<void> cacheUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyCachedUser, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  Future<List<GroupModel>> fetchUserGroups() async {
    try {
      final splashData = await splashLogin();
      if (splashData != null) {
        final groupsRaw = splashData['gs'] ?? splashData['groups'] ?? splashData['userGroups'];
        if (groupsRaw is List) {
          return groupsRaw
              .whereType<Map<String, dynamic>>()
              .map((g) => GroupModel.fromJson(g))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<UserModel?> tryRestoreSession() async {
    final token = await getStoredToken();
    if (token == null || token.isEmpty) return null;

    UserModel? user;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString(keyCachedUser);
      if (userStr != null && userStr.isNotEmpty) {
        final decoded = jsonDecode(userStr);
        if (decoded is Map<String, dynamic>) {
          user = UserModel.fromJson(decoded, token);
        }
      }
    } catch (_) {}

    try {
      final splashData = await splashLogin().timeout(const Duration(seconds: 4));
      if (splashData != null) {
        final groupsRaw = splashData['gs'] ?? splashData['groups'] ?? splashData['userGroups'];
        List<GroupModel>? groups;
        if (groupsRaw is List) {
          groups = groupsRaw
              .whereType<Map<String, dynamic>>()
              .map((g) => GroupModel.fromJson(g))
              .toList();
        }

        if (user != null) {
          user = user.copyWith(
            userGroups: groups ?? user.userGroups,
            statusMessage: splashData['stm']?.toString() ?? user.statusMessage,
            studiconId: (splashData['pv'] as int?) ?? user.studiconId,
            flamesBalance: (splashData['fl'] as int?) ?? user.flamesBalance,
          );
        } else {
          user = UserModel.fromJson(splashData, token);
        }
        await cacheUser(user);
      }
    } catch (_) {}

    try {
      final response = await _apiClient.post(
        ApiConstants.reloadInfo,
        data: {
          'pv': user?.studiconId ?? 19,
          'cd': {},
        },
      ).timeout(const Duration(seconds: 3));
      final data = response.data;
      if (data is Map<String, dynamic> && data['s'] == true) {
        if (user != null) {
          final p = data['p'];
          if (p is Map) {
            user = user.copyWith(
              statusMessage: (p['stm'] ?? user.statusMessage).toString(),
              studiconId: (p['pv'] as int?) ?? user.studiconId,
            );
            await cacheUser(user);
          }
        }
      }
    } catch (_) {}

    return user;
  }

  Future<bool> deleteAccount() async {
    final response = await _apiClient.post('/user/delete');
    final data = response.data;
    final isSuccess = data is Map<String, dynamic> && data['s'] == true;
    if (isSuccess) {
      await _deleteToken();
    }
    return isSuccess;
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/user/logout', data: {'pushToken': ''});
    } catch (_) {}
    await _deleteToken();
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import 'constants.dart';

class YptAuthResult {
  final String jwt;
  final String email;
  final String name;
  final String? socialId;
  final Map<String, dynamic>? rawData;

  const YptAuthResult({
    required this.jwt,
    required this.email,
    required this.name,
    this.socialId,
    this.rawData,
  });
}

class YptAuthException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  const YptAuthException(this.message, {this.code, this.statusCode});

  @override
  String toString() => message;
}

class YptAuthService {
  final Dio _dio;

  YptAuthService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: CompanionConstants.yptBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'Content-Type': 'application/json',
                  'User-Agent': 'Dart/3.11 (dart:io)',
                },
              ),
            );

  static String? extractSubFromIdToken(String idToken) {
    try {
      final parts = idToken.split('.');
      if (parts.length < 2) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalized);
      final decodedString = utf8.decode(decodedBytes);
      final Map<String, dynamic> json = jsonDecode(decodedString);
      return json['sub']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<YptAuthResult> signInWithGoogle({
    required String idToken,
    required String email,
    required String name,
    String language = 'pt',
  }) async {
    final socialId = extractSubFromIdToken(idToken);
    if (socialId == null || socialId.isEmpty) {
      throw const YptAuthException(
        'Não foi possível extrair o socialId do token do Google.',
      );
    }

    return signInWithSocial(
      provider: 'Google',
      socialId: socialId,
      email: email,
      name: name,
      language: language,
    );
  }

  Future<YptAuthResult> signInWithSocial({
    required String provider,
    required String socialId,
    required String email,
    required String name,
    String language = 'pt',
  }) async {
    try {
      final response = await _dio.post(
        CompanionConstants.signInJwtEndpoint,
        data: {
          'email': email,
          'password': null,
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
        String msg = 'Falha ao autenticar via $provider.';
        String? errCode;

        if (data is Map) {
          errCode = data['c']?.toString();
          msg = data['m']?.toString() ??
              data['message']?.toString() ??
              (errCode != null ? 'Erro de autenticação [$errCode]' : msg);
        }

        throw YptAuthException(
          msg,
          code: errCode,
          statusCode: response.statusCode,
        );
      }

      final jwt = (data['jwt'] ?? '').toString().trim();
      if (jwt.isEmpty) {
        throw const YptAuthException(
          'Token JWT não foi retornado pelo servidor do YPT.',
        );
      }

      return YptAuthResult(
        jwt: jwt,
        email: email,
        name: (data['name'] ?? name).toString(),
        socialId: socialId,
        rawData: data,
      );
    } on YptAuthException {
      rethrow;
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String msg = 'Erro de comunicação com o servidor do Yeolpumta.';
      String? code;

      if (responseData is Map) {
        code = responseData['c']?.toString();
        msg = responseData['m']?.toString() ??
            responseData['message']?.toString() ??
            msg;
      }

      throw YptAuthException(
        msg,
        code: code,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw YptAuthException('Erro inesperado na autenticação: $e');
    }
  }
}

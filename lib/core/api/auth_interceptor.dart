import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  static const String keyJwtToken = 'jwt_token';

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['User-Agent'] = ApiConstants.userAgent;
    options.headers['Content-Type'] = 'application/json';

    final token = await _storage.read(key: keyJwtToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = '${ApiConstants.jwtPrefix}$token';
    } else {
      options.headers['Authorization'] = 'JWT';
    }

    return handler.next(options);
  }
}

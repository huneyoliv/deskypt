import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:companion/core/ypt_auth_service.dart';

void main() {
  group('YptAuthService - extractSubFromIdToken', () {
    test('extracts sub correctly from valid JWT token', () {
      final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'RS256'})));
      final payload = base64Url.encode(
        utf8.encode(
          jsonEncode({
            'sub': '109876543210987654321',
            'email': 'user@gmail.com',
            'name': 'Test User',
          }),
        ),
      );
      final fakeJwt = '$header.$payload.fakesignature';

      final sub = YptAuthService.extractSubFromIdToken(fakeJwt);
      expect(sub, '109876543210987654321');
    });

    test('returns null for malformed token', () {
      expect(YptAuthService.extractSubFromIdToken('not-a-jwt'), isNull);
      expect(YptAuthService.extractSubFromIdToken('only.two'), isNull);
    });

    test('returns null when sub field is missing', () {
      final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'RS256'})));
      final payload = base64Url.encode(utf8.encode(jsonEncode({'email': 'test@gmail.com'})));
      final fakeJwt = '$header.$payload.fakesignature';

      expect(YptAuthService.extractSubFromIdToken(fakeJwt), isNull);
    });
  });

  group('YptAuthService - signInWithGoogle and signInWithSocial', () {
    late Dio dio;
    late YptAuthService authService;

    setUp(() {
      dio = Dio();
      dio.httpClientAdapter = HttpClientAdapter();
      authService = YptAuthService(dio: dio);
    });

    test('signInWithSocial succeeds and returns YptAuthResult on valid API response', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  's': true,
                  'jwt': 'test_jwt_token_12345',
                  'name': 'Test User',
                  'email': 'user@gmail.com',
                },
              ),
            );
          },
        ),
      );

      final result = await authService.signInWithSocial(
        provider: 'Google',
        socialId: '123456789',
        email: 'user@gmail.com',
        name: 'Test User',
      );

      expect(result.jwt, 'test_jwt_token_12345');
      expect(result.email, 'user@gmail.com');
      expect(result.name, 'Test User');
      expect(result.socialId, '123456789');
    });

    test('signInWithGoogle extracts sub and invokes signInWithSocial successfully', () async {
      final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'RS256'})));
      final payload = base64Url.encode(
        utf8.encode(
          jsonEncode({
            'sub': 'google_sub_999',
            'email': 'user@gmail.com',
          }),
        ),
      );
      final fakeJwt = '$header.$payload.fakesig';

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.data['socialId'], 'google_sub_999');
            expect(options.data['loginProvider'], 'Google');
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  's': true,
                  'jwt': 'ypt_jwt_google_success',
                  'name': 'Google User',
                },
              ),
            );
          },
        ),
      );

      final result = await authService.signInWithGoogle(
        idToken: fakeJwt,
        email: 'user@gmail.com',
        name: 'Google User',
      );

      expect(result.jwt, 'ypt_jwt_google_success');
      expect(result.socialId, 'google_sub_999');
    });

    test('throws YptAuthException when API returns s: false with error code', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  's': false,
                  'c': '113',
                  'm': 'Conta não encontrada',
                },
              ),
            );
          },
        ),
      );

      expect(
        () => authService.signInWithSocial(
          provider: 'Google',
          socialId: '123',
          email: 'test@gmail.com',
          name: 'Test',
        ),
        throwsA(
          isA<YptAuthException>()
              .having((e) => e.code, 'code', '113')
              .having((e) => e.message, 'message', 'Conta não encontrada'),
        ),
      );
    });

    test('throws YptAuthException when jwt is missing from success response', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  's': true,
                  'jwt': '',
                },
              ),
            );
          },
        ),
      );

      expect(
        () => authService.signInWithSocial(
          provider: 'Google',
          socialId: '123',
          email: 'test@gmail.com',
          name: 'Test',
        ),
        throwsA(
          isA<YptAuthException>().having(
            (e) => e.message,
            'message',
            contains('Token JWT não foi retornado'),
          ),
        ),
      );
    });

    test('handles DioException and extracts error response message', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 400,
                  data: {
                    's': false,
                    'm': 'Erro de validação nos dados fornecidos',
                  },
                ),
              ),
            );
          },
        ),
      );

      expect(
        () => authService.signInWithSocial(
          provider: 'Google',
          socialId: '123',
          email: 'test@gmail.com',
          name: 'Test',
        ),
        throwsA(
          isA<YptAuthException>().having(
            (e) => e.message,
            'message',
            'Erro de validação nos dados fornecidos',
          ),
        ),
      );
    });
  });
}

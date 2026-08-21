import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:deskypt/core/api/api_client.dart';
import 'package:deskypt/data/repositories/auth_repository.dart';

class MockStorage extends FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) _data[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  group('AuthRepository Tests', () {
    late AuthRepository repository;
    late MockStorage mockStorage;
    late Dio mockDio;

    setUp(() {
      mockStorage = MockStorage();
      mockDio = Dio();
      // Setup adapter interceptor mock
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/user/sign-in-jwt')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    's': true,
                    'jwt': 'fake_jwt_token_123',
                    'id': 16300695,
                    'n': 'Test User',
                    'e': 'test@example.com',
                    'pv': 377,
                  },
                ),
              );
            }
            if (options.path.contains('/user/v2/splash-login')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'s': true},
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final apiClient = ApiClient(customDio: mockDio);
      repository = AuthRepository(apiClient: apiClient, storage: mockStorage);
    });

    test('signInWithEmail authenticates and stores JWT token', () async {
      final user = await repository.signInWithEmail(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(user.id, equals(16300695));
      expect(user.name, equals('Test User'));
      expect(user.jwtToken, equals('fake_jwt_token_123'));

      final storedToken = await mockStorage.read(key: 'jwt_token');
      expect(storedToken, equals('fake_jwt_token_123'));
    });

    test('signInWithEmail handles error code 112 (wrong password)', () async {
      final errorDio = Dio();
      errorDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'s': false, 'c': '112'},
              ),
            );
          },
        ),
      );
      final repo = AuthRepository(apiClient: ApiClient(customDio: errorDio), storage: mockStorage);

      expect(
        () => repo.signInWithEmail(email: 'test@example.com', password: 'wrong'),
        throwsA(predicate((e) => e.toString().contains('Senha incorreta'))),
      );
    });

    test('signInWithEmail handles error code 113 (email not found)', () async {
      final errorDio = Dio();
      errorDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'s': false, 'c': '113'},
              ),
            );
          },
        ),
      );
      final repo = AuthRepository(apiClient: ApiClient(customDio: errorDio), storage: mockStorage);

      expect(
        () => repo.signInWithEmail(email: 'notfound@example.com', password: 'pass'),
        throwsA(predicate((e) => e.toString().contains('E-mail não cadastrado'))),
      );
    });

    test('signInWithEmail handles error code 114 (account suspended)', () async {
      final errorDio = Dio();
      errorDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'s': false, 'c': '114'},
              ),
            );
          },
        ),
      );
      final repo = AuthRepository(apiClient: ApiClient(customDio: errorDio), storage: mockStorage);

      expect(
        () => repo.signInWithEmail(email: 'suspended@example.com', password: 'pass'),
        throwsA(predicate((e) => e.toString().contains('Conta suspensa'))),
      );
    });

    test('logout deletes stored JWT token', () async {
      await mockStorage.write(key: 'jwt_token', value: 'token_abc');
      await repository.logout();

      final storedToken = await mockStorage.read(key: 'jwt_token');
      expect(storedToken, isNull);
    });

    test('signInWithSocial sends password:null and returns user on success', () async {
      Map<String, dynamic>? capturedData;
      final socialDio = Dio();
      socialDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/user/sign-in-jwt')) {
              capturedData = options.data as Map<String, dynamic>?;
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    's': true,
                    'jwt': 'social_jwt_token',
                    'id': 99999,
                    'n': 'Google User',
                    'e': 'google@gmail.com',
                    'pv': 1,
                  },
                ),
              );
            }
            if (options.path.contains('/user/v2/splash-login')) {
              return handler.resolve(
                Response(requestOptions: options, statusCode: 200, data: {'s': true}),
              );
            }
            return handler.next(options);
          },
        ),
      );
      final repo = AuthRepository(apiClient: ApiClient(customDio: socialDio), storage: mockStorage);

      final user = await repo.signInWithSocial(
        provider: 'Google',
        socialId: 'google_sub_12345',
        email: 'google@gmail.com',
        name: 'Google User',
      );

      expect(user.id, equals(99999));
      expect(user.name, equals('Google User'));
      expect(capturedData, isNotNull);
      expect(capturedData!.containsKey('password'), isTrue);
      expect(capturedData!['password'], isNull);
      expect(capturedData!['socialId'], equals('google_sub_12345'));
      expect(capturedData!['loginProvider'], equals('Google'));
    });

    test('signInWithSocial throws ApiException on error c:111 (social id not found)', () async {
      final errorDio = Dio();
      errorDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'s': false, 'c': '111'},
              ),
            );
          },
        ),
      );
      final repo = AuthRepository(apiClient: ApiClient(customDio: errorDio), storage: mockStorage);

      expect(
        () => repo.signInWithSocial(
          provider: 'Google',
          socialId: 'nonexistent_sub',
          email: 'ghost@gmail.com',
          name: 'Ghost',
        ),
        throwsA(predicate((e) => e.toString().contains('111') || e.toString().contains('Erro'))),
      );
    });
  });
}

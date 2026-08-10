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

    test('logout deletes stored JWT token', () async {
      await mockStorage.write(key: 'jwt_token', value: 'token_abc');
      await repository.logout();

      final storedToken = await mockStorage.read(key: 'jwt_token');
      expect(storedToken, isNull);
    });
  });
}

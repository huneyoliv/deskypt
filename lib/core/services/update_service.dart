import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/updates/models/update_model.dart';

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

class UpdateService {
  final Dio _dio;
  static const String latestReleaseUrl =
      'https://api.github.com/repos/huneyoliv/deskypt/releases/latest';

  UpdateService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'Accept': 'application/vnd.github.v3+json',
                  'User-Agent': 'DeskYPT-App',
                },
              ),
            );

  Future<AppRelease?> fetchLatestRelease() async {
    try {
      final response = await _dio.get(latestReleaseUrl);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return AppRelease.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Retorna null silenciosamente em caso de erro de rede ou 404 sem quebrar o app
    }
    return null;
  }
}

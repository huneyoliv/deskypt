import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:deskypt/core/api/api_client.dart';
import 'package:deskypt/data/repositories/rank_repository.dart';

class MockApiClient extends ApiClient {
  MockApiClient() : super(customDio: Dio());

  Map<String, dynamic>? getResponse;
  Map<String, dynamic>? postResponse;

  @override
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? baseUrl,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: getResponse,
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Options? options,
    String? baseUrl,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: postResponse,
      statusCode: 200,
    );
  }
}

void main() {
  group('RankRepository Tests', () {
    late MockApiClient mockApiClient;
    late RankRepository repository;

    setUp(() {
      mockApiClient = MockApiClient();
      repository = RankRepository(apiClient: mockApiClient);
    });

    test('fetchGlobalRanks returns parsed RankEntryModel list', () async {
      mockApiClient.getResponse = {
        's': true,
        'ms': [
          {
            'ud': 101,
            'n': 'Lara',
            'sd': 2,
            'ct': 'ENEM',
            'dl': {'sm': 36000000},
          },
          {
            'ud': 102,
            'n': 'Lucas',
            'sd': 3,
            'ct': 'ENEM',
            'dl': {'sm': 32400000},
          },
        ]
      };

      final ranks = await repository.fetchGlobalRanks(period: 'day', categoryId: 1);
      expect(ranks.length, equals(2));
      expect(ranks[0].userName, equals('Lara'));
      expect(ranks[0].rank, equals(1));
      expect(ranks[1].userName, equals('Lucas'));
      expect(ranks[1].rank, equals(2));
    });

    test('fetchMyCategoryRank returns user current rank integer', () async {
      mockApiClient.getResponse = {
        's': true,
        'mr': 42,
      };

      final rank = await repository.fetchMyCategoryRank(categoryId: 1);
      expect(rank, equals(42));
    });

    test('fetchUserStats sends POST to /logs/range/days and returns logs', () async {
      mockApiClient.postResponse = {
        's': true,
        'ls': [
          {'dt': '2026-08-10', 'sm': 18000000, 'sb': 'Matemática'},
        ],
        'ss': [],
      };

      final stats = await repository.fetchUserStats(
        userId: 101,
        startDate: '2026-08-01',
        endDate: '2026-08-31',
      );

      expect(stats['s'], isTrue);
      expect((stats['ls'] as List).length, equals(1));
    });
  });
}

import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/constants/api_constants.dart';
import '../models/category_model.dart';
import '../models/country_model.dart';

class SettingsRepository {
  final ApiClient _apiClient;
  final SharedPreferences? _prefs;

  SettingsRepository({
    ApiClient? apiClient,
    SharedPreferences? prefs,
  })  : _apiClient = apiClient ?? ApiClient(),
        _prefs = prefs;

  static const String keyCountryId = 'selected_country_id';
  static const String keyCountryCode = 'selected_country_code';
  static const String keyCountryName = 'selected_country_name';
  static const String keyTimezone = 'selected_timezone';
  static const String keyLanguage = 'selected_language';

  static const CountryModel defaultCountry = CountryModel(
    id: 23,
    name: 'BRAZIL',
    code: 'BR',
    timezone: 'America/Sao_Paulo',
    continent: 'South America',
  );

  Future<List<CountryModel>> fetchCountries() async {
    final response = await _apiClient.get(
      '/category/countries',
      baseUrl: ApiConstants.metadataCdnUrl,
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['s'] == true && data['cs'] is List) {
      return (data['cs'] as List)
          .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic> && data['m'] != null) {
      throw ApiException(data['m'].toString(), statusCode: response.statusCode);
    }
    throw const ApiException('Falha ao carregar lista de países do servidor');
  }

  Future<List<CategoryModel>> fetchCategoriesByCountry({
    required int countryId,
    required String language,
  }) async {
    final response = await _apiClient.get(
      '/category/category-by-country',
      baseUrl: ApiConstants.metadataCdnUrl,
      queryParameters: {
        'countryID': countryId,
        'country_id': countryId,
        'lang': language,
        'language': language,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic> && data['s'] == true && data['cs'] is List) {
      return (data['cs'] as List)
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic> && data['m'] != null) {
      throw ApiException(data['m'].toString(), statusCode: response.statusCode);
    }
    throw const ApiException('Falha ao carregar categorias da região');
  }

  Future<CountryModel> getSavedCountry() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final id = prefs.getInt(keyCountryId);
    if (id == null) return defaultCountry;

    return CountryModel(
      id: id,
      name: prefs.getString(keyCountryName) ?? defaultCountry.name,
      code: prefs.getString(keyCountryCode) ?? defaultCountry.code,
      timezone: prefs.getString(keyTimezone) ?? defaultCountry.timezone,
      continent: '',
    );
  }

  Future<void> saveCountry(CountryModel country) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setInt(keyCountryId, country.id);
    await prefs.setString(keyCountryName, country.name);
    await prefs.setString(keyCountryCode, country.code);
    await prefs.setString(keyTimezone, country.timezone);
  }

  Future<String> getSavedLanguage() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getString(keyLanguage) ?? 'pt';
  }

  Future<void> saveLanguage(String languageCode) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(keyLanguage, languageCode);
  }
}

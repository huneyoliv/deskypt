import 'dart:ui' as ui;
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
  static const String keyDayResetHour = 'day_reset_hour';
  static const String keyShowRestTime = 'show_rest_time';
  static const String keyWakeNotifications = 'wake_notifications';
  static const String keySoundEffects = 'sound_effects';
  static const String keyBlockedUsers = 'blocked_users_list';

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
    final saved = prefs.getString(keyLanguage);
    if (saved != null && saved.isNotEmpty) {
      return saved;
    }

    // Automatically detect PC / Operating System locale
    try {
      final systemLocale = ui.PlatformDispatcher.instance.locale;
      final lang = systemLocale.languageCode.toLowerCase();
      final script = systemLocale.scriptCode?.toLowerCase() ?? '';
      final country = systemLocale.countryCode?.toLowerCase() ?? '';

      if (lang == 'zh') {
        if (script.contains('hant') || country == 'tw' || country == 'hk') {
          return 'zh_hant';
        }
        return 'zh_hans';
      }

      const supported = [
        'pt', 'en', 'es', 'ko', 'ja', 'fr', 'de', 'it', 'ru', 'vi',
        'th', 'tr', 'id', 'hi', 'nl', 'pl', 'sv', 'fi', 'da', 'nb',
        'et', 'lv', 'lt'
      ];
      if (supported.contains(lang)) {
        return lang;
      }
    } catch (_) {}

    return 'pt';
  }

  Future<void> saveLanguage(String languageCode) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(keyLanguage, languageCode);
  }

  Future<int> getDayResetHour() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getInt(keyDayResetHour) ?? 5;
  }

  Future<void> saveDayResetHour(int hour) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setInt(keyDayResetHour, hour);
  }

  Future<bool> getShowRestTime() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getBool(keyShowRestTime) ?? true;
  }

  Future<void> saveShowRestTime(bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(keyShowRestTime, value);
  }

  Future<bool> getWakeNotifications() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getBool(keyWakeNotifications) ?? true;
  }

  Future<void> saveWakeNotifications(bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(keyWakeNotifications, value);
  }

  Future<bool> getSoundEffects() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getBool(keySoundEffects) ?? true;
  }

  Future<void> saveSoundEffects(bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setBool(keySoundEffects, value);
  }

  Future<List<String>> getBlockedUsers() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    return prefs.getStringList(keyBlockedUsers) ?? [];
  }

  Future<void> saveBlockedUsers(List<String> users) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setStringList(keyBlockedUsers, users);
  }
}

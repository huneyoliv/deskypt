import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/data/models/country_model.dart';
import 'package:deskypt/data/models/category_model.dart';
import 'package:deskypt/data/repositories/settings_repository.dart';
import 'package:deskypt/features/settings/settings_notifier.dart';

class MockSettingsRepository extends SettingsRepository {
  CountryModel savedCountry = const CountryModel(
    id: 23,
    name: 'Brasil',
    code: 'BR',
    timezone: 'America/Sao_Paulo',
    continent: 'South America',
  );
  String savedLanguage = 'pt';

  @override
  Future<CountryModel> getSavedCountry() async => savedCountry;

  @override
  Future<String> getSavedLanguage() async => savedLanguage;

  @override
  Future<void> saveCountry(CountryModel country) async => savedCountry = country;

  @override
  Future<void> saveLanguage(String languageCode) async => savedLanguage = languageCode;

  @override
  Future<List<CountryModel>> fetchCountries() async => [
    const CountryModel(
      id: 23,
      name: 'Brasil',
      code: 'BR',
      timezone: 'America/Sao_Paulo',
      continent: 'South America',
    ),
    const CountryModel(
      id: 231,
      name: 'United States',
      code: 'US',
      timezone: 'America/New_York',
      continent: 'North America',
    ),
  ];

  @override
  Future<List<CategoryModel>> fetchCategoriesByCountry({int countryId = 23, String language = 'pt'}) async => [
    const CategoryModel(id: 1, title: 'Vestibular', shortTitle: 'Vest', order: 1, section: 'geral'),
  ];
}

void main() {
  group('SettingsNotifier Tests', () {
    late MockSettingsRepository mockRepo;
    late SettingsNotifier notifier;

    setUp(() {
      mockRepo = MockSettingsRepository();
      notifier = SettingsNotifier(mockRepo);
    });

    test('selectCountry saves country and updates state', () async {
      const newCountry = CountryModel(
        id: 231,
        name: 'United States',
        code: 'US',
        timezone: 'America/New_York',
        continent: 'North America',
      );
      await notifier.selectCountry(newCountry);

      expect(notifier.state.selectedCountry.id, equals(231));
      expect(mockRepo.savedCountry.id, equals(231));
    });

    test('selectLanguage saves language and updates state', () async {
      await notifier.selectLanguage('en');

      expect(notifier.state.selectedLanguage, equals('en'));
      expect(mockRepo.savedLanguage, equals('en'));
    });
  });
}

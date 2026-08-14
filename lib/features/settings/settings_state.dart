import '../../data/models/category_model.dart';
import '../../data/models/country_model.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsState {
  final CountryModel selectedCountry;
  final String selectedLanguage;
  final List<CountryModel> availableCountries;
  final List<CategoryModel> countryCategories;
  final bool isLoadingCountries;
  final bool isLoadingCategories;
  final String? errorMessage;

  const SettingsState({
    this.selectedCountry = SettingsRepository.defaultCountry,
    this.selectedLanguage = 'pt',
    this.availableCountries = const [],
    this.countryCategories = const [],
    this.isLoadingCountries = false,
    this.isLoadingCategories = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    CountryModel? selectedCountry,
    String? selectedLanguage,
    List<CountryModel>? availableCountries,
    List<CategoryModel>? countryCategories,
    bool? isLoadingCountries,
    bool? isLoadingCategories,
    String? errorMessage,
  }) {
    return SettingsState(
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      availableCountries: availableCountries ?? this.availableCountries,
      countryCategories: countryCategories ?? this.countryCategories,
      isLoadingCountries: isLoadingCountries ?? this.isLoadingCountries,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      errorMessage: errorMessage,
    );
  }
}

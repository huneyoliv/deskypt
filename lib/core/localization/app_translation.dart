import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/settings_notifier.dart';

class AppTranslation {
  final String languageCode;
  final Map<String, String> _translations;

  const AppTranslation({
    required this.languageCode,
    Map<String, String> translations = const {},
  }) : _translations = translations;

  String tr(String key, {List<String>? args, String? fallback}) {
    String? val = _translations[key];
    if (val == null || val.isEmpty) {
      return fallback ?? key;
    }
    if (args != null && args.isNotEmpty) {
      for (final arg in args) {
        val = val!.replaceFirst('{}', arg);
      }
    }
    return val!;
  }

  static String normalizeCode(String code) {
    final lower = code.toLowerCase().replaceAll('_', '-');
    if (lower == 'zh-hans' || lower == 'zh-cn' || lower == 'zh') return 'zh-CN';
    if (lower == 'zh-hant' || lower == 'zh-tw' || lower == 'zh-hk') return 'zh-TW';
    return lower;
  }

  static Future<AppTranslation> load(String languageCode) async {
    final norm = normalizeCode(languageCode);
    Map<String, String> map = {};

    try {
      final jsonStr = await rootBundle.loadString('assets/translations/$norm.json');
      final dynamic decoded = json.decode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        map = decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (_) {
      try {
        final fallbackJson = await rootBundle.loadString('assets/translations/pt.json');
        final dynamic decoded = json.decode(fallbackJson);
        if (decoded is Map<String, dynamic>) {
          map = decoded.map((k, v) => MapEntry(k, v.toString()));
        }
      } catch (_) {}
    }

    return AppTranslation(languageCode: norm, translations: map);
  }
}

class AppTranslationNotifier extends StateNotifier<AppTranslation> {
  AppTranslationNotifier() : super(const AppTranslation(languageCode: 'pt')) {
    loadLanguage('pt');
  }

  Future<void> loadLanguage(String code) async {
    final translation = await AppTranslation.load(code);
    state = translation;
  }
}

final appTranslationProvider =
    StateNotifierProvider<AppTranslationNotifier, AppTranslation>((ref) {
  final notifier = AppTranslationNotifier();
  ref.listen(settingsNotifierProvider.select((s) => s.selectedLanguage), (prev, next) {
    if (next.isNotEmpty && prev != next) {
      notifier.loadLanguage(next);
    }
  });
  return notifier;
});

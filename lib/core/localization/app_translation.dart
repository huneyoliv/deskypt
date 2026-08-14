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

  static const Map<String, List<String>> _keyAliases = {
    'home': ['bottom_home', 'timer_title', 'study_time_title'],
    'timer': ['bottom_home', 'timer_title'],
    'groups': ['bottom_group', 'group_title', 'group_menu_group'],
    'group': ['bottom_group', 'group_title'],
    'planner': ['bottom_calendar', 'calendar_title', 'timetable'],
    'calendar': ['bottom_calendar'],
    'ranks': ['ranking', 'group_menu_ranking', 'rank_title'],
    'ranking': ['ranking', 'group_menu_ranking'],
    'flashcards': ['flashcard', 'flashcard_title', 'add_flashcards'],
    'flashcard': ['flashcard', 'flashcard_title'],
    'store': ['store_title', 'studicon_title'],
    'studicons': ['store_title', 'studicon_title'],
    'challenges': ['challenge', 'challenge_title', 'group_challenge'],
    'challenge': ['challenge', 'challenge_title'],
    'profile': ['profile_title', 'drawer_user_profile', 'user_profile'],
    'settings': ['drawer_settings_title', 'setting_title'],
    'logout': ['drawer_settings_menu_account_logout', 'account_logout'],
    'notifications': ['alert_user_notice', 'drawer_notice_title', 'notice'],
    'notice': ['drawer_notice_title', 'alert_user_notice'],
    'pause': ['study_visual_timer_pause', 'pause'],
    'restart': ['study_visual_timer_restart', 'restart'],
    'break': ['study_rest_label', 'timer_options_pomodoro_break'],
    'focus': ['timer_options_pomodoro_study', 'focus'],
    'pomodoro': ['timer_options_pomodoro'],
  };

  String tr(String key, {List<String>? args, String? fallback}) {
    String? val = _translations[key];

    if (val == null || val.isEmpty) {
      final aliases = _keyAliases[key.toLowerCase()];
      if (aliases != null) {
        for (final alias in aliases) {
          final aliasVal = _translations[alias];
          if (aliasVal != null && aliasVal.isNotEmpty) {
            val = aliasVal;
            break;
          }
        }
      }
    }

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
  final Ref _ref;

  AppTranslationNotifier(this._ref) : super(const AppTranslation(languageCode: 'pt')) {
    _init();
  }

  Future<void> _init() async {
    final lang = _ref.read(settingsNotifierProvider).selectedLanguage;
    await loadLanguage(lang.isNotEmpty ? lang : 'pt');
  }

  Future<void> loadLanguage(String code) async {
    final translation = await AppTranslation.load(code);
    state = translation;
  }
}

final appTranslationProvider =
    StateNotifierProvider<AppTranslationNotifier, AppTranslation>((ref) {
  final notifier = AppTranslationNotifier(ref);
  ref.listen(settingsNotifierProvider.select((s) => s.selectedLanguage), (prev, next) {
    if (next.isNotEmpty && prev != next) {
      notifier.loadLanguage(next);
    }
  });
  return notifier;
});

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
    // Navigation
    'home': ['bottom_home', 'timer_title', 'study_time_title'],
    'timer': ['bottom_home', 'timer_title'],
    'groups': ['bottom_group', 'group_title', 'group_menu_group', 'alert_group_list_title'],
    'group': ['bottom_group', 'group_title'],
    'planner': ['bottom_calendar', 'calendar_title', 'timetable'],
    'calendar': ['bottom_calendar', 'calendar_title'],
    'ranks': ['ranking', 'group_menu_ranking', 'rank_title', 'tab_ranking', 'challenge_rank'],
    'ranking': ['ranking', 'group_menu_ranking', 'tab_ranking'],
    'flashcards': ['flashcard', 'flashcard_title', 'add_flashcards'],
    'flashcard': ['flashcard', 'flashcard_title'],
    'store': ['store_title', 'studicon_title'],
    'studicons': ['store_title', 'studicon_title'],
    'my_studicons': ['studicon_title', 'store_title'],
    'challenges': ['challenge', 'challenge_title', 'group_challenge'],
    'challenge': ['challenge', 'challenge_title'],
    'profile': ['profile_title', 'drawer_user_profile', 'user_profile', 'group_setting_profile_list_tile_text'],
    'settings': ['drawer_settings_title', 'setting_title', 'calendar_access_move'],
    'logout': ['drawer_settings_menu_account_logout', 'account_logout'],
    'notifications': ['alert_user_notice', 'drawer_notice_title', 'notice'],
    'notice': ['drawer_notice_title', 'alert_user_notice'],

    // Common actions & buttons
    'cancel': ['cancel', 'cancel_selection', 'btn_cancel'],
    'save': ['save', 'btn_save'],
    'delete': ['delete', 'dday_delete', 'alert_todo_delete', 'btn_delete'],
    'confirm': ['confirm', 'btn_confirm', 'sign_up_check_hint'],
    'edit': ['edit', 'modify', 'dday_edit_button_text'],
    'add': ['add', 'alert_todo_add'],
    'close': ['close', 'modify'],
    'refresh': ['refresh', 'reload'],
    'done': ['alert_todo_complete_done', 'done'],

    // Auth & Account
    'login': ['sign_in', 'login', 'btn_login', 'sign_in_title'],
    'sign_up': ['sign_up', 'btn_sign_up', 'sign_up_title'],
    'email': ['sign_in_hint_email', 'sign_up_email_hint', 'email'],
    'password': ['sign_in_hint_password', 'sign_up_password_hint', 'password'],
    'forgot_password': ['sign_in_forget_password', 'forget_password'],
    'nickname': ['sign_up_nick_name_hint', 'user_profile_name'],

    // Timer & Pomodoro
    'pause': ['study_visual_timer_pause', 'pause'],
    'restart': ['study_visual_timer_restart', 'restart'],
    'stop': ['study_visual_timer_stop', 'stop'],
    'break': ['study_rest_label', 'timer_options_pomodoro_break', 'pomodoro_rest_time_title'],
    'focus': ['focus_time', 'pomodoro_session_time_title', 'timer_options_pomodoro_study'],
    'pomodoro': ['timer_options_pomodoro'],
    'today_study_time': ['today_total_study_time', 'study_time_title'],

    // Subjects
    'subjects': ['subject_manage', 'subject_title', 'subject_list'],
    'active': ['active', 'subject_tab_active'],
    'archived': ['archived', 'subject_tab_archive'],

    // Planner & Timetable
    'todo': ['planner_insight_bottom_sheet_todo', 'alert_todo_add'],
    'dday': ['dday_edit_button_text', 'dday_delete'],
    'timetable': ['timetable', 'timetable_title'],

    // Challenge
    'my_challenges': ['challenge_tabview_history', 'challenge_title'],
    'available_challenges': ['challenge_group', 'challenge_title'],
    'checkin': ['challenge_proof', 'challenge_title'],
    'success': ['challenge_success'],
    'failed': ['challenge_fail'],
    'ended': ['challenge_end'],
    'bet': ['challenge_flame_cost'],
    'goal': ['daily_goal_hour', 'goal'],

    // Periods & Stats
    'today': ['today', 'day', 'study_time_title'],
    'this_week': ['unit_this_week', 'analytics_stairs_info_this_week'],
    'this_month': ['analytics_stairs_info_this_month'],
    'stats': ['analytics', 'statistics', 'graph'],

    // General UI
    'student': ['user_profile', 'profile_title'],
    'online': ['active'],
    'pending': ['offline_pending'],
    'synchronized': ['offline_synced'],
    'sent': ['offline_sent'],
    'exit_focus': ['focus_exit'],
    'day_of_week': ['calendar_repeat_cycle_day_of_week'],
    'start_time': ['calendar_event_start_time'],
    'end_time': ['calendar_event_end_time'],
    'subject_distribution': ['analytics_pie_chart_title'],
  };

  // Multilingual fallback map for core app terms when JSON missing
  static const Map<String, Map<String, String>> _coreFallbackTranslations = {
    'login': {
      'pt': 'Entrar',
      'en': 'Log In',
      'es': 'Iniciar sesión',
      'ko': '로그인',
      'ja': 'ログイン',
      'zh-cn': '登录',
      'zh-tw': '登入',
    },
    'login_title': {
      'pt': 'Entrar na sua conta',
      'en': 'Log in to your account',
      'es': 'Inicia sesión en tu cuenta',
      'ko': '계정에 로그인',
      'ja': 'アカウントにログイン',
      'zh-cn': '登录您的账户',
      'zh-tw': '登入您的帳戶',
    },
    'sign_up': {
      'pt': 'Cadastre-se',
      'en': 'Sign Up',
      'es': 'Registrarse',
      'ko': '회원가입',
      'ja': '新規登録',
      'zh-cn': '注册',
      'zh-tw': '註冊',
    },
    'sign_up_title': {
      'pt': 'Crie sua Conta',
      'en': 'Create your Account',
      'es': 'Crea tu Cuenta',
      'ko': '계정 만들기',
      'ja': 'アカウント作成',
      'zh-cn': '创建账户',
      'zh-tw': '建立帳戶',
    },
    'email': {
      'pt': 'E-mail',
      'en': 'Email',
      'es': 'Correo electrónico',
      'ko': '이메일',
      'ja': 'メールアドレス',
      'zh-cn': '邮箱',
      'zh-tw': '電子郵件',
    },
    'password': {
      'pt': 'Senha',
      'en': 'Password',
      'es': 'Contraseña',
      'ko': '비밀번호',
      'ja': 'パスワード',
      'zh-cn': '密码',
      'zh-tw': '密碼',
    },
    'confirm_password': {
      'pt': 'Confirmar Senha',
      'en': 'Confirm Password',
      'es': 'Confirmar Contraseña',
      'ko': '비밀번호 확인',
      'ja': 'パスワード再確認',
      'zh-cn': '确认密码',
      'zh-tw': '確認密碼',
    },
    'forgot_password': {
      'pt': 'Esqueci minha senha',
      'en': 'Forgot password?',
      'es': '¿Olvidaste tu contraseña?',
      'ko': '비밀번호를 잊으셨나요?',
      'ja': 'パスワードをお忘れですか？',
      'zh-cn': '忘记密码？',
      'zh-tw': '忘記密碼？',
    },
    'or_login_with': {
      'pt': 'ou entre com',
      'en': 'or log in with',
      'es': 'o entra con',
      'ko': '또는 다음으로 로그인',
      'ja': 'または次でログイン',
      'zh-cn': '或通过以下方式登录',
      'zh-tw': '或透過以下方式登入',
    },
    'dont_have_account': {
      'pt': 'Não tem uma conta?',
      'en': "Don't have an account?",
      'es': '¿No tienes una cuenta?',
      'ko': '계정이 없으신가요?',
      'ja': 'アカウントをお持ちでないですか？',
      'zh-cn': '还没有账户？',
      'zh-tw': '還沒有帳戶？',
    },
    'already_have_account': {
      'pt': 'Já possui uma conta?',
      'en': 'Already have an account?',
      'es': '¿Ya tienes una cuenta?',
      'ko': '이미 계정이 있으신가요?',
      'ja': 'すでにアカウントをお持ちですか？',
      'zh-cn': '已有账户？',
      'zh-tw': '已有帳戶？',
    },
    'my_studicons': {
      'pt': 'Meus Studicons',
      'en': 'My Studicons',
      'es': 'Mis Studicons',
      'ko': '내 스터디콘',
      'ja': 'マイスターディコン',
      'zh-cn': '我的 Studicons',
      'zh-tw': '我的 Studicons',
    },
    'flashcards': {
      'pt': 'Flashcards',
      'en': 'Flashcards',
      'es': 'Flashcards',
      'ko': '플래시카드',
      'ja': 'フラッシュカード',
      'zh-cn': '抽认卡',
      'zh-tw': '抽認卡',
    },
    'challenges': {
      'pt': 'Desafios',
      'en': 'Challenges',
      'es': 'Desafíos',
      'ko': '챌린지',
      'ja': 'チャレンジ',
      'zh-cn': '挑战',
      'zh-tw': '挑戰',
    },
    'ranks': {
      'pt': 'Rankings',
      'en': 'Rankings',
      'es': 'Rankings',
      'ko': '랭킹',
      'ja': 'ランキング',
      'zh-cn': '排行榜',
      'zh-tw': '排行榜',
    },
    'groups': {
      'pt': 'Grupos',
      'en': 'Groups',
      'es': 'Grupos',
      'ko': '그룹',
      'ja': 'グループ',
      'zh-cn': '群组',
      'zh-tw': '群組',
    },
    'planner': {
      'pt': 'Planner',
      'en': 'Planner',
      'es': 'Planner',
      'ko': '플래너',
      'ja': 'プランナー',
      'zh-cn': '计划表',
      'zh-tw': '計劃表',
    },
    'timer': {
      'pt': 'Cronômetro',
      'en': 'Timer',
      'es': 'Cronómetro',
      'ko': '타이머',
      'ja': 'タイマー',
      'zh-cn': '计时器',
      'zh-tw': '計時器',
    },
    'profile': {
      'pt': 'Perfil',
      'en': 'Profile',
      'es': 'Perfil',
      'ko': '프로필',
      'ja': 'プロフィール',
      'zh-cn': '个人资料',
      'zh-tw': '個人資料',
    },
    'settings': {
      'pt': 'Configurações',
      'en': 'Settings',
      'es': 'Ajustes',
      'ko': '설정',
      'ja': '設定',
      'zh-cn': '设置',
      'zh-tw': '設定',
    },
    'logout': {
      'pt': 'Sair',
      'en': 'Log out',
      'es': 'Cerrar sesión',
      'ko': '로그아웃',
      'ja': 'ログアウト',
      'zh-cn': '退出登录',
      'zh-tw': '登出',
    },
    'cancel': {
      'pt': 'Cancelar',
      'en': 'Cancel',
      'es': 'Cancelar',
      'ko': '취소',
      'ja': 'キャンセル',
      'zh-cn': '取消',
      'zh-tw': '取消',
    },
    'save': {
      'pt': 'Salvar',
      'en': 'Save',
      'es': 'Guardar',
      'ko': '저장',
      'ja': '保存',
      'zh-cn': '保存',
      'zh-tw': '儲存',
    },
    'confirm': {
      'pt': 'Confirmar',
      'en': 'Confirm',
      'es': 'Confirmar',
      'ko': '확인',
      'ja': '確認',
      'zh-cn': '确认',
      'zh-tw': '確認',
    },
    'delete': {
      'pt': 'Excluir',
      'en': 'Delete',
      'es': 'Eliminar',
      'ko': '삭제',
      'ja': '削除',
      'zh-cn': '删除',
      'zh-tw': '刪除',
    },
    'close': {
      'pt': 'Fechar',
      'en': 'Close',
      'es': 'Cerrar',
      'ko': '닫기',
      'ja': '閉じる',
      'zh-cn': '关闭',
      'zh-tw': '關閉',
    },
    'subjects': {
      'pt': 'Matérias',
      'en': 'Subjects',
      'es': 'Materias',
      'ko': '과목',
      'ja': '科目',
      'zh-cn': '科目',
      'zh-tw': '科目',
    },
    'manage_subjects': {
      'pt': 'Gerenciar Matérias',
      'en': 'Manage Subjects',
      'es': 'Administrar Materias',
      'ko': '과목 관리',
      'ja': '科目管理',
      'zh-cn': '管理科目',
      'zh-tw': '管理科目',
    },
    'active': {
      'pt': 'Ativas',
      'en': 'Active',
      'es': 'Activas',
      'ko': '진행중',
      'ja': 'アクティブ',
      'zh-cn': '进行中',
      'zh-tw': '進行中',
    },
    'archived': {
      'pt': 'Arquivadas',
      'en': 'Archived',
      'es': 'Archivadas',
      'ko': '보관됨',
      'ja': 'アーカイブ',
      'zh-cn': '已归档',
      'zh-tw': '已封存',
    },
    'new_subject': {
      'pt': 'Nova Matéria',
      'en': 'New Subject',
      'es': 'Nueva Materia',
      'ko': '새 과목',
      'ja': '新規科目',
      'zh-cn': '新科目',
      'zh-tw': '新科目',
    },
    'edit_subject': {
      'pt': 'Editar Matéria',
      'en': 'Edit Subject',
      'es': 'Editar Materia',
      'ko': '과목 수정',
      'ja': '科目編集',
      'zh-cn': '编辑科目',
      'zh-tw': '編輯科目',
    },
    'delete_subject': {
      'pt': 'Excluir Matéria',
      'en': 'Delete Subject',
      'es': 'Eliminar Materia',
      'ko': '과목 삭제',
      'ja': '科目削除',
      'zh-cn': '删除科目',
      'zh-tw': '刪除科目',
    },
    'today': {
      'pt': 'Hoje',
      'en': 'Today',
      'es': 'Hoy',
      'ko': '오늘',
      'ja': '今日',
      'zh-cn': '今天',
      'zh-tw': '今天',
    },
    'this_week': {
      'pt': 'Esta Semana',
      'en': 'This Week',
      'es': 'Esta Semana',
      'ko': '이번 주',
      'ja': '今週',
      'zh-cn': '本周',
      'zh-tw': '本週',
    },
    'this_month': {
      'pt': 'Este Mês',
      'en': 'This Month',
      'es': 'Este Mes',
      'ko': '이번 달',
      'ja': '今月',
      'zh-cn': '本月',
      'zh-tw': '本月',
    },
    'region': {
      'pt': 'Região / País',
      'en': 'Region / Country',
      'es': 'Región / País',
      'ko': '지역 / 국가',
      'ja': '地域 / 国',
      'zh-cn': '地区 / 国家',
      'zh-tw': '地區 / 國家',
    },
    'language': {
      'pt': 'Idioma do Aplicativo',
      'en': 'App Language',
      'es': 'Idioma de la App',
      'ko': '앱 언어',
      'ja': 'アプリの言語',
      'zh-cn': '应用语言',
      'zh-tw': '應用語言',
    },
    'select_language': {
      'pt': 'Selecionar Idioma',
      'en': 'Select Language',
      'es': 'Seleccionar Idioma',
      'ko': '언어 선택',
      'ja': '言語を選択',
      'zh-cn': '选择语言',
      'zh-tw': '選擇語言',
    },
  };

  String tr(String key, {List<String>? args, String? fallback}) {
    String? val = _translations[key];

    // Check alias list
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

    // Check multilingual fallback dict
    if (val == null || val.isEmpty) {
      final fallbackMap = _coreFallbackTranslations[key.toLowerCase()];
      if (fallbackMap != null) {
        final langLower = languageCode.toLowerCase();
        val = fallbackMap[langLower] ?? fallbackMap['en'] ?? fallbackMap['pt'];
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

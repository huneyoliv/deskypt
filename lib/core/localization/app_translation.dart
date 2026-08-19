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
    'home': ['bottom_home', 'timer_title', 'study_time_title', 'home_tab_timer'],
    'timer': ['home_tab_timer', 'study_tab_timer_title', 'timer_title', 'bottom_home'],
    'bottom_home': ['home_tab_timer', 'study_tab_timer_title', 'timer_title'],
    'groups': ['group_my_groups', 'bottom_group', 'group_title', 'group_menu_group', 'alert_group_list_title'],
    'group': ['bottom_group', 'group_title'],
    'bottom_group': ['group_my_groups', 'group_title'],
    'my_groups': ['group_my_groups', 'bottom_group'],
    'explore': ['group_search_title', 'explore'],
    'explore_groups': ['group_search_title', 'explore'],
    'planner': ['bottom_calendar', 'calendar_title', 'timetable'],
    'bottom_calendar': ['calendar_title', 'timetable'],
    'calendar': ['calendar_setting', 'calendar_title', 'bottom_calendar'],
    'ranks': ['ranking', 'group_menu_ranking', 'rank_title', 'tab_ranking', 'challenge_rank'],
    'ranking': ['ranking', 'group_menu_ranking', 'tab_ranking'],
    'flashcards': ['flashcard', 'flashcard_title', 'add_flashcards'],
    'flashcard': ['flashcard', 'flashcard_title'],
    'store': ['store_title', 'studicon_title'],
    'studicons': ['store_title', 'studicon_title'],
    'my_studicons': ['studicon_title', 'store_title'],
    'challenges': ['challenge', 'challenge_title', 'group_challenge'],
    'challenge': ['challenge', 'challenge_title'],
    'profile': ['user_profile', 'profile_title', 'drawer_user_profile'],
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
    'search': ['group_search_title', 'drawer_apps_search_hint', 'search'],

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
    'short_break': ['pomodoro_rest_time_title', 'timer_options_pomodoro_break'],
    'long_break': ['pomodoro_long_rest_time_title', 'study_rest_label'],
    'focus': ['focus_time', 'pomodoro_session_time_title', 'timer_options_pomodoro_study'],
    'pomodoro': ['timer_options_pomodoro', 'pomodoro_mode', 'pomodoro_notification_settings_title'],
    'timer_options_pomodoro': ['pomodoro_mode', 'timer_options_pomodoro'],
    'timer_options_pomodoro_study': ['pomodoro_session_time_title', 'focus_time'],
    'timer_options_pomodoro_break': ['pomodoro_rest_time_title', 'timer_options_pomodoro_break'],
    'study_rest_label': ['pomodoro_long_rest_time_title', 'study_rest_label'],
    'today_study_time': ['pomodoro_today_total', 'today_total_study_time', 'study_time_title'],
    'today_total_study_time': ['pomodoro_today_total', 'study_time_title'],
    'timer_study_subject': ['alert_planner_add_study_log_error1', 'subject_title'],

    // Subjects
    'subjects': ['subject_manage', 'subject_title', 'subject_list'],
    'active': ['active', 'subject_tab_active'],
    'archived': ['archived', 'subject_tab_archive'],

    // Planner & Timetable
    'todo': ['planner_insight_bottom_sheet_todo', 'alert_todo_add'],
    'dday': ['dday_home_label', 'dday_dialog_add_title', 'dday_edit_button_text', 'dday_delete'],
    'timetable': ['timetable_title', 'base_timetable', 'timetable'],

    // Challenge
    'my_challenges': ['challenge_tabview_history', 'challenge_title'],
    'available_challenges': ['challenge_group', 'challenge_title'],
    'checkin': ['challenge_proof', 'challenge_title'],
    'success': ['challenge_success'],
    'failed': ['challenge_fail'],
    'ended': ['challenge_end'],
    'bet': ['challenge_flame_cost'],
    'goal': ['daily_goal_hour', 'goal_statistics_text_total_time', 'goal'],

    // Periods & Stats
    'today': ['today', 'day', 'study_time_title'],
    'this_week': ['unit_this_week', 'analytics_stairs_info_this_week'],
    'this_month': ['analytics_stairs_info_this_month'],
    'stats': ['analytics', 'statistics', 'graph'],

    // Groups & Cam
    'join': ['group_join_button_text', 'join'],
    'join_group': ['group_join_button_text', 'alert_group_join_title'],
    'leave_group': ['alert_group_leave_member_msg', 'group_leave'],
    'open': ['view', 'open'],
    'members': ['max_member', 'member_capacity', 'book_share_members'],
    'shake': ['group_shake', 'shake'],
    'cam_live': ['cam_live', 'cam_study'],
    'active_cam': ['cam_live', 'cam_study'],
    'chat': ['group_chat', 'chat'],

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
    'paused': ['paused', 'pause', 'study_rest_label'],
    'studying': ['studying', 'study', 'timer_options_pomodoro_study'],
    'resting': ['resting', 'rest', 'study_rest_label'],
    'ypt_stickers': ['sticker', 'ypt_stickers'],
    'leader_menu': ['group_manager', 'leader_menu'],
    'member_capacity': ['max_member', 'member_capacity'],
    'daily_goal_hours': ['daily_goal_hour', 'daily_goal_hours'],
    'group_name': ['group_title', 'group_name'],
    'save_changes': ['save', 'btn_save', 'save_changes'],
    'minimize': ['minimize'],
    'maximize': ['maximize'],
    'restore': ['restore'],
    'equipped': ['equipped'],
    'equip': ['equip'],
    'studicon': ['studicon_title', 'studicon'],
  };

  static const Map<String, Map<String, String>> _coreFallbackTranslations = {
    // Auth
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

    // Navigation & Screens
    'home': {
      'pt': 'Cronômetro',
      'en': 'Timer',
      'es': 'Cronómetro',
      'ko': '타이머',
      'ja': 'タイマー',
      'zh-cn': '计时器',
      'zh-tw': '計時器',
    },
    'bottom_home': {
      'pt': 'Cronômetro',
      'en': 'Timer',
      'es': 'Cronómetro',
      'ko': '타이머',
      'ja': 'タイマー',
      'zh-cn': '计时器',
      'zh-tw': '計時器',
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
    'groups': {
      'pt': 'Grupos',
      'en': 'Groups',
      'es': 'Grupos',
      'ko': '그룹',
      'ja': 'グループ',
      'zh-cn': '群组',
      'zh-tw': '群組',
    },
    'bottom_group': {
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
    'studying': {
      'pt': 'Estudando',
      'en': 'Studying',
      'es': 'Estudiando',
      'ko': '공부 중',
      'ja': '勉強中',
      'zh-cn': '学习中',
      'zh-tw': '學習中',
    },
    'idle': {
      'pt': 'Inativo',
      'en': 'Inactive',
      'es': 'Inactivo',
      'ko': '자리비움',
      'ja': '退席中',
      'zh-cn': '空闲',
      'zh-tw': '閒置',
    },
    'bottom_calendar': {
      'pt': 'Planner',
      'en': 'Planner',
      'es': 'Planner',
      'ko': '플래너',
      'ja': 'プランナー',
      'zh-cn': '计划表',
      'zh-tw': '計劃表',
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
    'ranking': {
      'pt': 'Rankings',
      'en': 'Rankings',
      'es': 'Rankings',
      'ko': '랭킹',
      'ja': 'ランキング',
      'zh-cn': '排行榜',
      'zh-tw': '排行榜',
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
    'flashcard': {
      'pt': 'Flashcards',
      'en': 'Flashcards',
      'es': 'Flashcards',
      'ko': '플래시카드',
      'ja': 'フラッシュカード',
      'zh-cn': '抽认卡',
      'zh-tw': '抽認卡',
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
    'store': {
      'pt': 'Loja',
      'en': 'Store',
      'es': 'Tienda',
      'ko': '스토어',
      'ja': 'ストア',
      'zh-cn': '商店',
      'zh-tw': '商店',
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
    'challenge': {
      'pt': 'Desafios',
      'en': 'Challenges',
      'es': 'Desafíos',
      'ko': '챌린지',
      'ja': 'チャレンジ',
      'zh-cn': '挑战',
      'zh-tw': '挑戰',
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
    'notifications': {
      'pt': 'Notificações',
      'en': 'Notifications',
      'es': 'Notificaciones',
      'ko': '알림',
      'ja': '通知',
      'zh-cn': '通知',
      'zh-tw': '通知',
    },

    // Timer & Pomodoro Fallbacks
    'today_total_study_time': {
      'pt': 'Tempo Total de Hoje',
      'en': 'Total Time Today',
      'es': 'Tiempo Total de Hoy',
      'ko': '오늘 총 공부 시간',
      'ja': '今日の合計勉強時間',
      'zh-cn': '今日总学习时间',
      'zh-tw': '今日總學習時間',
    },
    'today_study_time': {
      'pt': 'Tempo Total de Hoje',
      'en': 'Total Time Today',
      'es': 'Tiempo Total de Hoy',
      'ko': '오늘 총 공부 시간',
      'ja': '今日の合計勉強時間',
      'zh-cn': '今日总学习时间',
      'zh-tw': '今日總學習時間',
    },
    'pomodoro_today_total': {
      'pt': 'Tempo Total de Hoje',
      'en': 'Total Time Today',
      'es': 'Tiempo Total de Hoy',
      'ko': '오늘 총 공부 시간',
      'ja': '今日の合計勉強時間',
      'zh-cn': '今日总学习时间',
      'zh-tw': '今日總學習時間',
    },
    'timer_options_pomodoro': {
      'pt': 'Pomodoro',
      'en': 'Pomodoro',
      'es': 'Pomodoro',
      'ko': '뽀모도로',
      'ja': 'ポモドーロ',
      'zh-cn': '番茄钟',
      'zh-tw': '番茄鐘',
    },
    'pomodoro': {
      'pt': 'Pomodoro',
      'en': 'Pomodoro',
      'es': 'Pomodoro',
      'ko': '뽀모도로',
      'ja': 'ポモドーロ',
      'zh-cn': '番茄钟',
      'zh-tw': '番茄鐘',
    },
    'focus': {
      'pt': 'Foco',
      'en': 'Focus',
      'es': 'Enfoque',
      'ko': '집중',
      'ja': '集中',
      'zh-cn': '专注',
      'zh-tw': '專注',
    },
    'timer_options_pomodoro_study': {
      'pt': 'Foco',
      'en': 'Focus',
      'es': 'Enfoque',
      'ko': '집중',
      'ja': '集中',
      'zh-cn': '专注',
      'zh-tw': '專注',
    },
    'short_break': {
      'pt': 'Pausa Curta',
      'en': 'Short Break',
      'es': 'Pausa Corta',
      'ko': '짧은 휴식',
      'ja': '短い休憩',
      'zh-cn': '短休息',
      'zh-tw': '短休息',
    },
    'timer_options_pomodoro_break': {
      'pt': 'Pausa Curta',
      'en': 'Short Break',
      'es': 'Pausa Corta',
      'ko': '짧은 휴식',
      'ja': '短い休憩',
      'zh-cn': '短休息',
      'zh-tw': '短休息',
    },
    'long_break': {
      'pt': 'Pausa Longa',
      'en': 'Long Break',
      'es': 'Pausa Larga',
      'ko': '긴 휴식',
      'ja': '長い休憩',
      'zh-cn': '长休息',
      'zh-tw': '長休息',
    },
    'study_rest_label': {
      'pt': 'Tempo de Descanso',
      'en': 'Rest Time',
      'es': 'Tiempo de Descanso',
      'ko': '쉬는시간',
      'ja': '休憩時間',
      'zh-cn': '休息时间',
      'zh-tw': '休息時間',
    },
    'mini_player': {
      'pt': 'Mini-Player Flutuante',
      'en': 'Floating Mini-Player',
      'es': 'Mini-Reproductor Flotante',
      'ko': '플로팅 미니 플레이어',
      'ja': 'フローティングミニプレーヤー',
      'zh-cn': '悬浮迷你播放器',
      'zh-tw': '懸浮迷你播放器',
    },
    'alert_planner_add_study_log': {
      'pt': 'Registro Manual de Estudo',
      'en': 'Manual Study Log',
      'es': 'Registro Manual de Estudio',
      'ko': '수동 학습 기록',
      'ja': '手動学習記録',
      'zh-cn': '手动学习记录',
      'zh-tw': '手動學習記錄',
    },
    'timer_study_subject': {
      'pt': 'Selecionar Matéria',
      'en': 'Select Subject',
      'es': 'Seleccionar Materia',
      'ko': '과목 선택',
      'ja': '科目選択',
      'zh-cn': '选择科目',
      'zh-tw': '選擇科目',
    },
    'skip': {
      'pt': 'Pular',
      'en': 'Skip',
      'es': 'Saltar',
      'ko': '건너뛰기',
      'ja': 'スキップ',
      'zh-cn': '跳过',
      'zh-tw': '略過',
    },
    'pomodoro_settings': {
      'pt': 'Configurações do Pomodoro',
      'en': 'Pomodoro Settings',
      'es': 'Configuración de Pomodoro',
      'ko': '뽀모도로 설정',
      'ja': 'ポモドーロ設定',
      'zh-cn': '番茄钟设置',
      'zh-tw': '番茄鐘設定',
    },

    // Actions & Buttons
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
    'edit': {
      'pt': 'Editar',
      'en': 'Edit',
      'es': 'Editar',
      'ko': '수정',
      'ja': '編集',
      'zh-cn': '编辑',
      'zh-tw': '編輯',
    },
    'add': {
      'pt': 'Adicionar',
      'en': 'Add',
      'es': 'Añadir',
      'ko': '추가',
      'ja': '追加',
      'zh-cn': '添加',
      'zh-tw': '新增',
    },
    'search': {
      'pt': 'Buscar',
      'en': 'Search',
      'es': 'Buscar',
      'ko': '검색',
      'ja': '検索',
      'zh-cn': '搜索',
      'zh-tw': '搜尋',
    },

    // Subjects
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

    // Groups & Explore
    'my_groups': {
      'pt': 'Meus Grupos',
      'en': 'My Groups',
      'es': 'Mis Grupos',
      'ko': '내 그룹',
      'ja': 'マイグループ',
      'zh-cn': '我的群组',
      'zh-tw': '我的群組',
    },
    'explore': {
      'pt': 'Explorar Grupos',
      'en': 'Explore Groups',
      'es': 'Explorar Grupos',
      'ko': '그룹 탐색',
      'ja': 'グループを探す',
      'zh-cn': '探索群组',
      'zh-tw': '探索群組',
    },
    'explore_groups': {
      'pt': 'Explorar Grupos',
      'en': 'Explore Groups',
      'es': 'Explorar Grupos',
      'ko': '그룹 탐색',
      'ja': 'グループを探す',
      'zh-cn': '探索群组',
      'zh-tw': '探索群組',
    },
    'featured_groups': {
      'pt': 'Grupos em Destaque',
      'en': 'Featured Groups',
      'es': 'Grupos Destacados',
      'ko': '추천 그룹',
      'ja': '注目のグループ',
      'zh-cn': '精选群组',
      'zh-tw': '精選群組',
    },
    'no_groups': {
      'pt': 'Você não participa de nenhum grupo de estudos no momento.',
      'en': 'You are not in any study group at the moment.',
      'es': 'No participas en ningún grupo de estudio actualmente.',
      'ko': '현재 참여 중인 스터디 그룹이 없습니다.',
      'ja': '現在参加しているスタディグループはありません。',
      'zh-cn': '您目前尚未加入任何学习群组。',
      'zh-tw': '您目前尚未加入任何學習群組。',
    },
    'no_groups_found': {
      'pt': 'Nenhum grupo disponível para explorar no momento.',
      'en': 'No groups available to explore at the moment.',
      'es': 'No hay grupos disponibles para explorar en este momento.',
      'ko': '현재 탐색 가능한 그룹이 없습니다.',
      'ja': '現在利用可能なグループはありません。',
      'zh-cn': '目前没有可探索的群组。',
      'zh-tw': '目前沒有可探索的群組。',
    },
    'no_results': {
      'pt': 'Nenhum grupo encontrado para sua busca.',
      'en': 'No groups found for your search.',
      'es': 'No se encontraron grupos para tu búsqueda.',
      'ko': '검색 결과가 없습니다.',
      'ja': '該当するグループが見つかりませんでした。',
      'zh-cn': '未找到相关群组。',
      'zh-tw': '未找到相關群組。',
    },
    'members': {
      'pt': 'membros',
      'en': 'members',
      'es': 'miembros',
      'ko': '멤버',
      'ja': 'メンバー',
      'zh-cn': '位成员',
      'zh-tw': '位成員',
    },
    'goal': {
      'pt': 'Meta',
      'en': 'Goal',
      'es': 'Meta',
      'ko': '목표',
      'ja': '目標',
      'zh-cn': '目标',
      'zh-tw': '目標',
    },
    'open': {
      'pt': 'Abrir',
      'en': 'Open',
      'es': 'Abrir',
      'ko': '열기',
      'ja': '開く',
      'zh-cn': '打开',
      'zh-tw': '開啟',
    },
    'join': {
      'pt': 'Entrar',
      'en': 'Join',
      'es': 'Unirse',
      'ko': '참여',
      'ja': '参加',
      'zh-cn': '加入',
      'zh-tw': '加入',
    },
    'join_group': {
      'pt': 'Entrar no Grupo',
      'en': 'Join Group',
      'es': 'Unirse al Grupo',
      'ko': '그룹 참여하기',
      'ja': 'グループに参加',
      'zh-cn': '加入群组',
      'zh-tw': '加入群組',
    },
    'leave_group': {
      'pt': 'Sair do Grupo',
      'en': 'Leave Group',
      'es': 'Salir del Grupo',
      'ko': '그룹 탈퇴',
      'ja': 'グループを退出',
      'zh-cn': '退出群组',
      'zh-tw': '退出群組',
    },
    'active_cam': {
      'pt': 'Câmeras / Estudo ao Vivo',
      'en': 'Cameras / Live Study',
      'es': 'Cámaras / Estudio en Vivo',
      'ko': '카메라 / 라이브 공부',
      'ja': 'カメラ / ライブ勉強',
      'zh-cn': '自习室摄像头',
      'zh-tw': '自習室視訊',
    },
    'chat': {
      'pt': 'Chat em Tempo Real',
      'en': 'Live Chat',
      'es': 'Chat en Tiempo Real',
      'ko': '실시간 채팅',
      'ja': 'リアルタイムチャット',
      'zh-cn': '实时聊天',
      'zh-tw': '即時聊天',
    },

    // Planner, D-Day & Timetable
    'todo': {
      'pt': 'Tarefas & D-Days',
      'en': 'To-Do & D-Days',
      'es': 'Tareas & D-Days',
      'ko': '투두 & 디데이',
      'ja': 'To-Do & D-Day',
      'zh-cn': '待办与倒计时',
      'zh-tw': '待辦與倒數日',
    },
    'dday': {
      'pt': 'D-Day',
      'en': 'D-Day',
      'es': 'D-Day',
      'ko': '디데이',
      'ja': 'D-Day',
      'zh-cn': '倒计时',
      'zh-tw': '倒數日',
    },
    'dday_empty': {
      'pt': 'Nenhum D-Day cadastrado',
      'en': 'No D-Days registered',
      'es': 'Ningún D-Day registrado',
      'ko': '등록된 디데이가 없습니다',
      'ja': '登録されたD-Dayはありません',
      'zh-cn': '暂无倒计时日',
      'zh-tw': '暫無倒數日',
    },
    'calendar': {
      'pt': 'Calendário de Estudos',
      'en': 'Study Calendar',
      'es': 'Calendario de Estudio',
      'ko': '학습 캘린더',
      'ja': '学習カレンダー',
      'zh-cn': '学习日历',
      'zh-tw': '學習行事曆',
    },
    'timetable': {
      'pt': 'Grade Horária',
      'en': 'Timetable',
      'es': 'Horario',
      'ko': '시간표',
      'ja': '時間割',
      'zh-cn': '课程表',
      'zh-tw': '課表',
    },
    'add_timetable': {
      'pt': 'Novo Horário',
      'en': 'New Timetable Block',
      'es': 'Nuevo Horario',
      'ko': '새 시간표 추가',
      'ja': '新規時間割',
      'zh-cn': '添加时间块',
      'zh-tw': '新增時間塊',
    },
    'timetable_desc': {
      'pt': 'Organize seus horários de aulas e sessões de estudo',
      'en': 'Organize your class schedules and study sessions',
      'es': 'Organiza tus horarios de clases y sesiones de estudio',
      'ko': '수업 일정과 학습 세션을 관리하세요',
      'ja': '授業や勉強のスケジュールを管理しましょう',
      'zh-cn': '安排您的课程与自习时间',
      'zh-tw': '安排您的課程與自習時間',
    },
    'delete_timetable': {
      'pt': 'Excluir Horário',
      'en': 'Delete Timetable Block',
      'es': 'Eliminar Horario',
      'ko': '시간표 삭제',
      'ja': '時間割を削除',
      'zh-cn': '删除时间块',
      'zh-tw': '刪除時間塊',
    },
    'recurring_todo_desc': {
      'pt': 'Esta tarefa se repete em vários dias:',
      'en': 'This task repeats on multiple days:',
      'es': 'Esta tarea se repite en varios días:',
      'ko': '이 할 일은 여러 날 반복됩니다:',
      'ja': 'このタスクは複数日に繰り返されます:',
      'zh-cn': '此任务在多天内重复：',
      'zh-tw': '此任務在多天內重複：',
    },
    'only_this_todo': {
      'pt': 'Apenas esta tarefa',
      'en': 'Only this task',
      'es': 'Solo esta tarea',
      'ko': '이 할 일만',
      'ja': 'このタスクのみ',
      'zh-cn': '仅此任务',
      'zh-tw': '僅此任務',
    },
    'all_series_todos': {
      'pt': 'Esta e todas as tarefas da série',
      'en': 'This and all tasks in series',
      'es': 'Esta y todas las tareas de la serie',
      'ko': '이 할 일 및 전체 시리즈',
      'ja': 'このタスクとシリーズ全体',
      'zh-cn': '此任务及系列所有任务',
      'zh-tw': '此任務及系列所有任務',
    },
    'delete_only_this_todo': {
      'pt': 'Excluir apenas esta tarefa',
      'en': 'Delete only this task',
      'es': 'Eliminar solo esta tarea',
      'ko': '이 할 일만 삭제',
      'ja': 'このタスクのみ削除',
      'zh-cn': '仅删除此任务',
      'zh-tw': '僅刪除此任務',
    },
    'delete_all_series_todos': {
      'pt': 'Excluir todas as tarefas da série',
      'en': 'Delete all tasks in series',
      'es': 'Eliminar todas las tareas de la serie',
      'ko': '전체 시리즈 삭제',
      'ja': 'シリーズ全体を削除',
      'zh-cn': '删除系列所有任务',
      'zh-tw': '刪除系列所有任務',
    },
    'delete_todo_confirm': {
      'pt': 'Tem certeza que deseja excluir esta tarefa?',
      'en': 'Are you sure you want to delete this task?',
      'es': '¿Estás seguro de que deseas eliminar esta tarea?',
      'ko': '이 할 일을 삭제하시겠습니까?',
      'ja': 'このタスクを削除してもよろしいですか？',
      'zh-cn': '确定要删除此任务吗？',
      'zh-tw': '確定要刪除此任務嗎？',
    },

    // Days of Week
    'monday': {
      'pt': 'Segunda-feira',
      'en': 'Monday',
      'es': 'Lunes',
      'ko': '월요일',
      'ja': '月曜日',
      'zh-cn': '星期一',
      'zh-tw': '星期一',
    },
    'tuesday': {
      'pt': 'Terça-feira',
      'en': 'Tuesday',
      'es': 'Martes',
      'ko': '화요일',
      'ja': '火曜日',
      'zh-cn': '星期二',
      'zh-tw': '星期二',
    },
    'wednesday': {
      'pt': 'Quarta-feira',
      'en': 'Wednesday',
      'es': 'Miércoles',
      'ko': '수요일',
      'ja': '水曜日',
      'zh-cn': '星期三',
      'zh-tw': '星期三',
    },
    'thursday': {
      'pt': 'Quinta-feira',
      'en': 'Thursday',
      'es': 'Jueves',
      'ko': '목요일',
      'ja': '木曜日',
      'zh-cn': '星期四',
      'zh-tw': '星期四',
    },
    'friday': {
      'pt': 'Sexta-feira',
      'en': 'Friday',
      'es': 'Viernes',
      'ko': '금요일',
      'ja': '金曜日',
      'zh-cn': '星期五',
      'zh-tw': '星期五',
    },
    'saturday': {
      'pt': 'Sábado',
      'en': 'Saturday',
      'es': 'Sábado',
      'ko': '토요일',
      'ja': '土曜日',
      'zh-cn': '星期六',
      'zh-tw': '星期六',
    },
    'sunday': {
      'pt': 'Domingo',
      'en': 'Sunday',
      'es': 'Domingo',
      'ko': '일요일',
      'ja': '日曜日',
      'zh-cn': '星期日',
      'zh-tw': '星期日',
    },
    'monday_short': {
      'pt': 'Seg',
      'en': 'Mon',
      'es': 'Lun',
      'ko': '월',
      'ja': '月',
      'zh-cn': '一',
      'zh-tw': '一',
    },
    'tuesday_short': {
      'pt': 'Ter',
      'en': 'Tue',
      'es': 'Mar',
      'ko': '화',
      'ja': '火',
      'zh-cn': '二',
      'zh-tw': '二',
    },
    'wednesday_short': {
      'pt': 'Qua',
      'en': 'Wed',
      'es': 'Mié',
      'ko': '수',
      'ja': '水',
      'zh-cn': '三',
      'zh-tw': '三',
    },
    'thursday_short': {
      'pt': 'Qui',
      'en': 'Thu',
      'es': 'Jue',
      'ko': '목',
      'ja': '木',
      'zh-cn': '四',
      'zh-tw': '四',
    },
    'friday_short': {
      'pt': 'Sex',
      'en': 'Fri',
      'es': 'Vie',
      'ko': '금',
      'ja': '金',
      'zh-cn': '五',
      'zh-tw': '五',
    },
    'saturday_short': {
      'pt': 'Sáb',
      'en': 'Sat',
      'es': 'Sáb',
      'ko': '토',
      'ja': '土',
      'zh-cn': '六',
      'zh-tw': '六',
    },
    'sunday_short': {
      'pt': 'Dom',
      'en': 'Sun',
      'es': 'Dom',
      'ko': '일',
      'ja': '日',
      'zh-cn': '日',
      'zh-tw': '日',
    },

    // Dates & Periods
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
    'update_available': {
      'pt': 'Atualização Disponível',
      'en': 'Update Available',
      'es': 'Actualización Disponible',
      'ko': '업데이트 가능',
      'ja': 'アップデートが利用可能',
      'zh-cn': '有可用更新',
      'zh-tw': '有可用更新',
    },
    'new_version_available': {
      'pt': 'Nova versão disponível',
      'en': 'New version available',
      'es': 'Nueva versión disponible',
      'ko': '새 버전 사용 가능',
      'ja': '新しいバージョンが利用可能',
      'zh-cn': '新版本可用',
      'zh-tw': '新版本可用',
    },
    'download_update': {
      'pt': 'Baixar Atualização',
      'en': 'Download Update',
      'es': 'Descargar Actualización',
      'ko': '업데이트 다운로드',
      'ja': 'アップデートをダウンロード',
      'zh-cn': '下载更新',
      'zh-tw': '下載更新',
    },
    'download_installer': {
      'pt': 'Baixar Instalador',
      'en': 'Download Installer',
      'es': 'Descargar Instalador',
      'ko': '설치 프로그램 다운로드',
      'ja': 'インストーラーをダウンロード',
      'zh-cn': '下载安装程序',
      'zh-tw': '下載安裝程式',
    },
    'view_on_github': {
      'pt': 'Ver no GitHub',
      'en': 'View on GitHub',
      'es': 'Ver en GitHub',
      'ko': 'GitHub에서 보기',
      'ja': 'GitHubで表示',
      'zh-cn': '在GitHub上查看',
      'zh-tw': '在GitHub上查看',
    },
    'changelog': {
      'pt': 'Novidades & Changelog',
      'en': 'What\'s New & Changelog',
      'es': 'Novedades y Changelog',
      'ko': '새로운 기능 및 변경 로그',
      'ja': '新機能と変更履歴',
      'zh-cn': '更新日志',
      'zh-tw': '更新日誌',
    },
    'released_on': {
      'pt': 'Lançado em',
      'en': 'Released on',
      'es': 'Lanzado el',
      'ko': '출시일',
      'ja': 'リリース日',
      'zh-cn': '发布于',
      'zh-tw': '發布於',
    },
    'checking_updates': {
      'pt': 'Verificando atualizações...',
      'en': 'Checking for updates...',
      'es': 'Buscando actualizaciones...',
      'ko': '업데이트 확인 중...',
      'ja': 'アップデートを確認中...',
      'zh-cn': '正在检查更新...',
      'zh-tw': '正在檢查更新...',
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

    // Check multilingual fallback dict for key
    if (val == null || val.isEmpty) {
      final fallbackMap = _coreFallbackTranslations[key.toLowerCase()];
      if (fallbackMap != null) {
        final langLower = languageCode.toLowerCase();
        val = fallbackMap[langLower] ?? fallbackMap['en'] ?? fallbackMap['pt'];
      }
    }

    // Check multilingual fallback dict for aliases
    if (val == null || val.isEmpty) {
      final aliases = _keyAliases[key.toLowerCase()];
      if (aliases != null) {
        for (final alias in aliases) {
          final fallbackMap = _coreFallbackTranslations[alias.toLowerCase()];
          if (fallbackMap != null) {
            final langLower = languageCode.toLowerCase();
            val = fallbackMap[langLower] ?? fallbackMap['en'] ?? fallbackMap['pt'];
            if (val != null && val.isNotEmpty) break;
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

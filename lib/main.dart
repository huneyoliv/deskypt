import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/localization/app_translation.dart';
import 'features/auth/auth_notifier.dart';
import 'shared/widgets/app_title_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  // Initialize Desktop Window Manager
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1024, 700),
    center: true,
    backgroundColor: Color(0xFF0F1117),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'DeskYPT - Yeolpumta Desktop',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setBackgroundColor(const Color(0xFF0F1117));
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    const ProviderScope(
      child: DeskYptApp(),
    ),
  );
}

class DeskYptApp extends ConsumerStatefulWidget {
  const DeskYptApp({super.key});

  @override
  ConsumerState<DeskYptApp> createState() => _DeskYptAppState();
}

class _DeskYptAppState extends ConsumerState<DeskYptApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final translation = ref.watch(appTranslationProvider);

    return MaterialApp.router(
      title: 'DeskYPT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: Locale(translation.languageCode.split('-').first),
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            color: AppColors.background,
            child: Column(
              children: [
                const AppTitleBar(title: 'DeskYPT'),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            ),
          ),
        );
      },
    );
  }
}

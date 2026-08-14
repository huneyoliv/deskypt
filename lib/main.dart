import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/localization/app_translation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Desktop Window Manager
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(1024, 700),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'DeskYPT - Yeolpumta Desktop',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    const ProviderScope(
      child: DeskYptApp(),
    ),
  );
}

class DeskYptApp extends ConsumerWidget {
  const DeskYptApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final translation = ref.watch(appTranslationProvider);

    return MaterialApp.router(
      title: 'DeskYPT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: Locale(translation.languageCode.split('-').first),
      routerConfig: router,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              height: 32,
              color: const Color(0xFF141418),
              child: const WindowCaption(
                brightness: Brightness.dark,
                backgroundColor: Colors.transparent,
                title: Row(
                  children: [
                    SizedBox(width: 8),
                    Text(
                      'DeskYPT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
    );
  }
}

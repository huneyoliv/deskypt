import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';

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

class DeskYptApp extends StatelessWidget {
  const DeskYptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeskYPT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'DeskYPT',
                style: AppTextStyles.displayLarge,
              ),
              SizedBox(height: 12),
              Text(
                'YPT for Desktop Client - Phase 0 Setup OK',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontFamily: AppTextStyles.fontPretendard,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

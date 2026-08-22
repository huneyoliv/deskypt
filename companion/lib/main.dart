import 'package:flutter/material.dart';
import 'core/constants.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DeskYptCompanionApp());
}

class DeskYptCompanionApp extends StatelessWidget {
  const DeskYptCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: CompanionConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: CompanionConstants.backgroundDark,
        fontFamily: 'Pretendard',
        colorScheme: const ColorScheme.dark(
          primary: CompanionConstants.primaryOrange,
          surface: CompanionConstants.cardDark,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

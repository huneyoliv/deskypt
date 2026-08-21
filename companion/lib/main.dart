import 'package:flutter/material.dart';
import 'core/constants.dart';

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
      home: const Scaffold(
        body: Center(
          child: Text(
            CompanionConstants.appName,
            style: TextStyle(
              color: CompanionConstants.primaryOrange,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

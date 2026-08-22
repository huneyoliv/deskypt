import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:companion/core/constants.dart';
import 'package:companion/core/google_sign_in_service.dart';
import 'package:companion/core/ypt_auth_service.dart';
import 'package:companion/screens/login_screen.dart';
import 'package:companion/screens/success_screen.dart';

class MockGoogleSignInService extends GoogleSignInService {
  final GoogleAuthResult? mockResult;
  final Exception? mockException;

  MockGoogleSignInService({this.mockResult, this.mockException});

  @override
  Future<GoogleAuthResult> signIn() async {
    if (mockException != null) throw mockException!;
    return mockResult ??
        const GoogleAuthResult(
          idToken: 'mock_google_id_token',
          email: 'test@example.com',
          displayName: 'Test User',
        );
  }
}

class MockYptAuthService extends YptAuthService {
  final YptAuthResult? mockResult;
  final Exception? mockException;

  MockYptAuthService({this.mockResult, this.mockException});

  @override
  Future<YptAuthResult> signInWithGoogle({
    required String idToken,
    required String email,
    required String name,
    String language = 'pt',
  }) async {
    if (mockException != null) throw mockException!;
    return mockResult ??
        YptAuthResult(
          jwt: 'mock_ypt_jwt_123',
          email: email,
          name: name,
          socialId: 'mock_social_123',
        );
  }
}

void main() {
  testWidgets('LoginScreen renders app name and Google login button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text(CompanionConstants.appName), findsOneWidget);
    expect(find.text('Continuar com o Google'), findsOneWidget);
  });

  testWidgets('LoginScreen navigates to SuccessScreen on successful Google login', (tester) async {
    final mockGoogle = MockGoogleSignInService();
    final mockYpt = MockYptAuthService();

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          googleSignInService: mockGoogle,
          yptAuthService: mockYpt,
        ),
      ),
    );

    await tester.tap(find.text('Continuar com o Google'));
    await tester.pump(); // Inicia o login
    await tester.pumpAndSettle(); // Conclui animação e navegação

    expect(find.byType(SuccessScreen), findsOneWidget);
    expect(find.text('Sessão Autenticada'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
  });

  testWidgets('LoginScreen shows error snackbar on YptAuthException', (tester) async {
    final mockGoogle = MockGoogleSignInService();
    final mockYpt = MockYptAuthService(
      mockException: const YptAuthException('Conta Yeolpumta não cadastrada.'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          googleSignInService: mockGoogle,
          yptAuthService: mockYpt,
        ),
      ),
    );

    await tester.tap(find.text('Continuar com o Google'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Conta Yeolpumta não cadastrada.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}

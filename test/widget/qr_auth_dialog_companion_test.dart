import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/core/oauth/companion_listener.dart';
import 'package:deskypt/core/oauth/qr_auth_service.dart';
import 'package:deskypt/data/repositories/auth_repository.dart';
import 'package:deskypt/features/auth/auth_notifier.dart';
import 'package:deskypt/features/auth/widgets/qr_auth_dialog.dart';

class MockQrAuthService extends QrAuthService {
  final Completer<String> completer = Completer<String>();
  final StreamController<CompanionAuthEvent> companionController =
      StreamController<CompanionAuthEvent>.broadcast();

  @override
  Future<QrAuthSession> startSession({
    Duration timeout = const Duration(minutes: 5),
    String? preferredIp,
  }) async {
    return QrAuthSession(
      sessionId: 'mock_session_123',
      pairingUrl: 'http://192.168.1.100:50000/pair?session=mock_session_123',
      hostIp: '192.168.1.100',
      port: 50000,
      availableIps: const [
        LanInterfaceInfo(name: 'Wi-Fi', ip: '192.168.1.100'),
      ],
      tokenFuture: completer.future,
      companionStream: companionController.stream,
    );
  }

  @override
  Future<void> cancel() async {}
}

class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier() : super(AuthRepository());

  @override
  Future<bool> signInWithCustomJwt(String token) async {
    return token == 'valid_jwt_from_companion';
  }
}

void main() {
  testWidgets('QrAuthDialog renders Companion status card and updates on Companion event', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1000));
    final mockQrService = MockQrAuthService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          qrAuthServiceProvider.overrideWithValue(mockQrService),
          authStateProvider.overrideWith((ref) => MockAuthNotifier()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: QrAuthDialog(providerName: 'Google'),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Entrar com Google'), findsOneWidget);
    expect(find.text('DeskYPT Companion APK'), findsOneWidget);
    expect(find.text('Faça login pelo app Companion para sincronizar automaticamente.'), findsOneWidget);

    // Emite evento simulado do Companion
    mockQrService.companionController.add(
      CompanionAuthEvent(
        jwt: 'valid_jwt_from_companion',
        email: 'aluno@ypt.com',
        name: 'Aluno Focado',
        timestamp: 1724275000,
        sourceAddress: InternetAddress.loopbackIPv4,
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Companion Detectado (Aluno Focado)'), findsOneWidget);
    expect(find.text('Sincronizando sessão e efetuando login...'), findsOneWidget);

    // Completa o token da sessão
    mockQrService.completer.complete('valid_jwt_from_companion');
    await tester.pumpAndSettle();
  });
}

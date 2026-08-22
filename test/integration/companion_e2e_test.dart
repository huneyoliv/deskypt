import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/core/oauth/companion_listener.dart';
import 'package:deskypt/core/oauth/qr_auth_service.dart';

void main() {
  group('DeskYPT Companion E2E Integration Tests', () {
    late QrAuthService qrAuthService;

    setUp(() {
      qrAuthService = QrAuthService();
    });

    tearDown(() async {
      await qrAuthService.cancel();
    });

    test('Full E2E: Companion broadcasts UDP payload -> DeskYPT receives, emits, responds ACK and completes session token', () async {
      final session = await qrAuthService.startSession(
        timeout: const Duration(seconds: 10),
      );

      expect(session.sessionId, isNotEmpty);
      expect(session.pairingUrl, contains('/pair?session='));
      expect(session.companionStream, isNotNull);

      // Listener para o stream de eventos
      final receivedEvents = <CompanionAuthEvent>[];
      final sub = session.companionStream!.listen(receivedEvents.add);

      // Simula o Companion APK criando socket UDP para broadcast
      final clientSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      clientSocket.broadcastEnabled = true;

      final ackCompleter = Completer<String>();
      clientSocket.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = clientSocket.receive();
          if (datagram != null) {
            final message = utf8.decode(datagram.data);
            ackCompleter.complete(message);
          }
        }
      });

      final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final payloadJson = jsonEncode({
        'type': 'deskypt-companion-auth',
        'version': 1,
        'jwt': 'e2e_mock_jwt_token_from_companion_app_42',
        'email': 'estudante_dedicado@tgclab.com',
        'name': 'Estudante Focado E2E',
        'timestamp': nowUnix,
      });

      // Envia para localhost na porta Companion
      final bytes = utf8.encode(payloadJson);
      clientSocket.send(bytes, InternetAddress.loopbackIPv4, CompanionListener.defaultPort);

      // 1. O session.tokenFuture deve completar com o JWT do Companion
      final token = await session.tokenFuture.timeout(const Duration(seconds: 5));
      expect(token, 'e2e_mock_jwt_token_from_companion_app_42');

      // 2. O companionStream deve ter recebido o CompanionAuthEvent correspondente
      await Future.delayed(const Duration(milliseconds: 100));
      expect(receivedEvents.length, greaterThanOrEqualTo(1));
      expect(receivedEvents.first.jwt, 'e2e_mock_jwt_token_from_companion_app_42');
      expect(receivedEvents.first.email, 'estudante_dedicado@tgclab.com');
      expect(receivedEvents.first.name, 'Estudante Focado E2E');

      // 3. O Companion deve ter recebido a resposta ACK de confirmação
      final ackMessage = await ackCompleter.future.timeout(const Duration(seconds: 5));
      final ackMap = jsonDecode(ackMessage) as Map<String, dynamic>;
      expect(ackMap['type'], 'deskypt-companion-ack');

      await sub.cancel();
      clientSocket.close();
    });
  });
}

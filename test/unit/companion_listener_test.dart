import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:deskypt/core/oauth/companion_listener.dart';

void main() {
  group('CompanionListener Unit Tests', () {
    late CompanionListener listener;

    setUp(() {
      listener = CompanionListener();
    });

    tearDown(() async {
      await listener.stopListening();
      listener.dispose();
    });

    test('starts listening and binds socket', () async {
      expect(listener.isListening, isFalse);
      await listener.startListening(port: 0);
      expect(listener.isListening, isTrue);
    });

    test('emits CompanionAuthEvent on valid UDP payload and sends ACK', () async {
      // Cria socket temporário para receber na porta aleatória do sistema
      final serverSocket = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
      final assignedPort = serverSocket.port;
      serverSocket.close();

      await listener.startListening(port: assignedPort);

      // Socket cliente simulando o Companion APK
      final clientSocket = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);

      final events = <CompanionAuthEvent>[];
      final sub = listener.events.listen(events.add);

      final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final payload = jsonEncode({
        'type': 'deskypt-companion-auth',
        'version': 1,
        'jwt': 'received_jwt_payload_123',
        'email': 'student@ypt.com',
        'name': 'Student Name',
        'timestamp': currentTimestamp,
      });

      // Escuta resposta ACK no cliente
      final ackCompleter = <String>[];
      clientSocket.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = clientSocket.receive();
          if (dg != null) {
            final text = utf8.decode(dg.data);
            ackCompleter.add(text);
          }
        }
      });

      clientSocket.send(
        utf8.encode(payload),
        InternetAddress.loopbackIPv4,
        assignedPort,
      );

      await Future.delayed(const Duration(milliseconds: 300));

      expect(events.length, 1);
      expect(events.first.jwt, 'received_jwt_payload_123');
      expect(events.first.email, 'student@ypt.com');
      expect(events.first.name, 'Student Name');
      expect(events.first.timestamp, currentTimestamp);

      expect(ackCompleter.isNotEmpty, isTrue);
      final ackJson = jsonDecode(ackCompleter.first);
      expect(ackJson['type'], 'deskypt-companion-ack');

      await sub.cancel();
      clientSocket.close();
    });

    test('rejects payload with expired timestamp (> 60s skew)', () async {
      final serverSocket = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
      final assignedPort = serverSocket.port;
      serverSocket.close();

      await listener.startListening(port: assignedPort);

      final clientSocket = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);

      final events = <CompanionAuthEvent>[];
      final sub = listener.events.listen(events.add);

      final oldTimestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 120;
      final payload = jsonEncode({
        'type': 'deskypt-companion-auth',
        'version': 1,
        'jwt': 'expired_jwt',
        'email': 'student@ypt.com',
        'name': 'Student Name',
        'timestamp': oldTimestamp,
      });

      clientSocket.send(
        utf8.encode(payload),
        InternetAddress.loopbackIPv4,
        assignedPort,
      );

      await Future.delayed(const Duration(milliseconds: 300));

      expect(events, isEmpty);

      await sub.cancel();
      clientSocket.close();
    });

    test('rejects payload with invalid type or version', () async {
      final serverSocket = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
      final assignedPort = serverSocket.port;
      serverSocket.close();

      await listener.startListening(port: assignedPort);

      final clientSocket = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);

      final events = <CompanionAuthEvent>[];
      final sub = listener.events.listen(events.add);

      final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final payloadWrongType = jsonEncode({
        'type': 'unknown-auth',
        'version': 1,
        'jwt': 'some_jwt',
        'email': 'student@ypt.com',
        'timestamp': currentTimestamp,
      });

      clientSocket.send(
        utf8.encode(payloadWrongType),
        InternetAddress.loopbackIPv4,
        assignedPort,
      );

      await Future.delayed(const Duration(milliseconds: 300));
      expect(events, isEmpty);

      await sub.cancel();
      clientSocket.close();
    });
  });
}

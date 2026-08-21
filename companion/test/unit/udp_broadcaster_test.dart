import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:companion/core/constants.dart';
import 'package:companion/core/udp_broadcaster.dart';

void main() {
  group('UdpBroadcastPayload', () {
    test('serializes payload to JSON string accurately', () {
      final fixedTimestamp = 1724275000;
      final payload = UdpBroadcastPayload.create(
        jwt: 'test_jwt_value',
        email: 'student@gmail.com',
        name: 'Alexandre',
        timestamp: fixedTimestamp,
      );

      final jsonString = payload.toJsonString();
      final map = jsonDecode(jsonString);

      expect(map['type'], CompanionConstants.udpPayloadType);
      expect(map['version'], CompanionConstants.udpPayloadVersion);
      expect(map['jwt'], 'test_jwt_value');
      expect(map['email'], 'student@gmail.com');
      expect(map['name'], 'Alexandre');
      expect(map['timestamp'], fixedTimestamp);
    });

    test('deserializes JSON string back to UdpBroadcastPayload', () {
      final jsonStr = jsonEncode({
        'type': 'deskypt-companion-auth',
        'version': 1,
        'jwt': 'xyz123',
        'email': 'user@domain.com',
        'name': 'User Name',
        'timestamp': 1724276000,
      });

      final parsed = UdpBroadcastPayload.fromJsonString(jsonStr);
      expect(parsed, isNotNull);
      expect(parsed!.type, 'deskypt-companion-auth');
      expect(parsed.version, 1);
      expect(parsed.jwt, 'xyz123');
      expect(parsed.email, 'user@domain.com');
      expect(parsed.name, 'User Name');
      expect(parsed.timestamp, 1724276000);
    });

    test('returns null when fromJsonString receives invalid JSON', () {
      expect(UdpBroadcastPayload.fromJsonString('invalid json text'), isNull);
      expect(UdpBroadcastPayload.fromJsonString('["not", "a", "map"]'), isNull);
    });
  });

  group('UdpBroadcaster Lifecycle and Network Communication', () {
    late UdpBroadcaster broadcaster;

    setUp(() {
      broadcaster = UdpBroadcaster();
    });

    tearDown(() async {
      await broadcaster.stop();
      broadcaster.dispose();
    });

    test('starts in idle status', () {
      expect(broadcaster.currentStatus, BroadcasterStatus.idle);
    });

    test('transitions to broadcasting status on startBroadcast', () async {
      await broadcaster.startBroadcast(
        jwt: 'mock_jwt',
        email: 'test@gmail.com',
        name: 'Tester',
        interval: const Duration(seconds: 1),
      );

      expect(broadcaster.currentStatus, BroadcasterStatus.broadcasting);
    });

    test('transitions to idle when stopped', () async {
      await broadcaster.startBroadcast(
        jwt: 'mock_jwt',
        email: 'test@gmail.com',
        name: 'Tester',
      );

      await broadcaster.stop();
      expect(broadcaster.currentStatus, BroadcasterStatus.idle);
    });

    test('transitions to connected when receiving ACK datagram', () async {
      // Sobe um socket simulando o DeskYPT receptor
      final receiverSocket = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
      final receiverPort = receiverSocket.port;

      final statusEvents = <BroadcasterStatus>[];
      final sub = broadcaster.statusStream.listen(statusEvents.add);

      receiverSocket.listen((event) {
        if (event == RawSocketEvent.read) {
          final dg = receiverSocket.receive();
          if (dg != null) {
            // Responde com ACK para o remetente
            final ackBytes = utf8.encode(jsonEncode({'type': CompanionConstants.udpAckType}));
            receiverSocket.send(ackBytes, dg.address, dg.port);
          }
        }
      });

      await broadcaster.startBroadcast(
        jwt: 'mock_jwt_ack',
        email: 'test_ack@gmail.com',
        name: 'Ack Tester',
        port: receiverPort,
        targetAddress: '127.0.0.1',
      );

      // Aguarda processamento do ACK
      await Future.delayed(const Duration(milliseconds: 300));

      expect(broadcaster.currentStatus, BroadcasterStatus.connected);
      expect(statusEvents, contains(BroadcasterStatus.connected));

      await sub.cancel();
      receiverSocket.close();
    });
  });
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

class CompanionAuthEvent {
  final String jwt;
  final String email;
  final String name;
  final int timestamp;
  final InternetAddress sourceAddress;

  const CompanionAuthEvent({
    required this.jwt,
    required this.email,
    required this.name,
    required this.timestamp,
    required this.sourceAddress,
  });
}

class CompanionListener {
  static const int defaultPort = 47221;
  static const String payloadType = 'deskypt-companion-auth';
  static const String ackType = 'deskypt-companion-ack';
  static const int maxClockSkewSeconds = 60;

  RawDatagramSocket? _socket;
  final _eventController = StreamController<CompanionAuthEvent>.broadcast();

  bool get isListening => _socket != null;
  Stream<CompanionAuthEvent> get events => _eventController.stream;

  Future<void> startListening({int port = defaultPort}) async {
    await stopListening();

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
      _socket?.broadcastEnabled = true;

      _socket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket?.receive();
          if (datagram != null) {
            _processDatagram(datagram);
          }
        }
      });
    } catch (_) {
      await stopListening();
    }
  }

  void _processDatagram(Datagram datagram) {
    try {
      final jsonString = utf8.decode(datagram.data);
      final dynamic decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) return;

      final type = decoded['type']?.toString();
      final version = (decoded['version'] as num?)?.toInt();
      final jwt = decoded['jwt']?.toString().trim();
      final email = decoded['email']?.toString().trim();
      final name = decoded['name']?.toString().trim() ?? '';
      final timestamp = (decoded['timestamp'] as num?)?.toInt();

      if (type != payloadType || version != 1) return;
      if (jwt == null || jwt.isEmpty) return;
      if (email == null || email.isEmpty) return;
      if (timestamp == null) return;

      final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if ((nowSeconds - timestamp).abs() > maxClockSkewSeconds) {
        return;
      }

      final authEvent = CompanionAuthEvent(
        jwt: jwt,
        email: email,
        name: name.isNotEmpty ? name : email.split('@').first,
        timestamp: timestamp,
        sourceAddress: datagram.address,
      );

      _sendAck(datagram.address, datagram.port);

      if (!_eventController.isClosed) {
        _eventController.add(authEvent);
      }
    } catch (_) {}
  }

  void _sendAck(InternetAddress address, int port) {
    try {
      final ackPayload = jsonEncode({'type': ackType});
      final bytes = utf8.encode(ackPayload);
      _socket?.send(bytes, address, port);
    } catch (_) {}
  }

  Future<void> stopListening() async {
    if (_socket != null) {
      try {
        _socket?.close();
      } catch (_) {}
      _socket = null;
    }
  }

  void dispose() {
    stopListening();
    _eventController.close();
  }
}

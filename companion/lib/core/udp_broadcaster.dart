import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'constants.dart';

enum BroadcasterStatus {
  idle,
  broadcasting,
  connected,
  timeout,
  error,
}

class UdpBroadcastPayload {
  final String type;
  final int version;
  final String jwt;
  final String email;
  final String name;
  final int timestamp;

  const UdpBroadcastPayload({
    required this.type,
    required this.version,
    required this.jwt,
    required this.email,
    required this.name,
    required this.timestamp,
  });

  factory UdpBroadcastPayload.create({
    required String jwt,
    required String email,
    required String name,
    int? timestamp,
  }) {
    return UdpBroadcastPayload(
      type: CompanionConstants.udpPayloadType,
      version: CompanionConstants.udpPayloadVersion,
      jwt: jwt,
      email: email,
      name: name,
      timestamp: timestamp ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'version': version,
        'jwt': jwt,
        'email': email,
        'name': name,
        'timestamp': timestamp,
      };

  String toJsonString() => jsonEncode(toJson());

  static UdpBroadcastPayload? fromJsonString(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr);
      if (map is! Map<String, dynamic>) return null;
      return UdpBroadcastPayload(
        type: map['type']?.toString() ?? '',
        version: (map['version'] as num?)?.toInt() ?? 1,
        jwt: map['jwt']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}

class UdpBroadcaster {
  RawDatagramSocket? _socket;
  Timer? _broadcastTimer;
  Timer? _timeoutTimer;
  final _statusController = StreamController<BroadcasterStatus>.broadcast();
  BroadcasterStatus _status = BroadcasterStatus.idle;

  BroadcasterStatus get currentStatus => _status;
  Stream<BroadcasterStatus> get statusStream => _statusController.stream;

  void _updateStatus(BroadcasterStatus newStatus) {
    _status = newStatus;
    if (!_statusController.isClosed) {
      _statusController.add(newStatus);
    }
  }

  Future<void> startBroadcast({
    required String jwt,
    required String email,
    required String name,
    Duration interval = const Duration(seconds: 3),
    Duration maxDuration = const Duration(seconds: 30),
    int port = CompanionConstants.udpDiscoveryPort,
    String targetAddress = CompanionConstants.udpBroadcastAddress,
  }) async {
    await stop();

    final payload = UdpBroadcastPayload.create(
      jwt: jwt,
      email: email,
      name: name,
    );
    final payloadBytes = utf8.encode(payload.toJsonString());

    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _socket?.broadcastEnabled = true;

      _updateStatus(BroadcasterStatus.broadcasting);

      _socket?.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket?.receive();
          if (datagram != null) {
            try {
              final responseStr = utf8.decode(datagram.data);
              final responseJson = jsonDecode(responseStr);
              if (responseJson is Map &&
                  responseJson['type'] == CompanionConstants.udpAckType) {
                _updateStatus(BroadcasterStatus.connected);
                _cleanupTimers();
              }
            } catch (_) {}
          }
        }
      });

      _sendDatagram(payloadBytes, port, targetAddress);

      _broadcastTimer = Timer.periodic(interval, (_) {
        if (_status == BroadcasterStatus.broadcasting) {
          _sendDatagram(payloadBytes, port, targetAddress);
        }
      });

      _timeoutTimer = Timer(maxDuration, () {
        if (_status == BroadcasterStatus.broadcasting) {
          _updateStatus(BroadcasterStatus.timeout);
          stop();
        }
      });
    } catch (e) {
      _updateStatus(BroadcasterStatus.error);
    }
  }

  void _sendDatagram(List<int> bytes, int port, String targetAddress) {
    try {
      final dest = InternetAddress(targetAddress);
      _socket?.send(bytes, dest, port);
    } catch (_) {}
  }

  void _cleanupTimers() {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  Future<void> stop() async {
    _cleanupTimers();
    if (_socket != null) {
      try {
        _socket?.close();
      } catch (_) {}
      _socket = null;
    }
    if (_status == BroadcasterStatus.broadcasting) {
      _updateStatus(BroadcasterStatus.idle);
    }
  }

  void dispose() {
    stop();
    _statusController.close();
  }
}

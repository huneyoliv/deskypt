import 'package:flutter/material.dart';

class CompanionConstants {
  CompanionConstants._();

  static const String appName = 'DeskYPT Companion';

  static const String googleWebClientId =
      '817104413429-3m0gmfk1vedr2prb0rktubcujia098lc.apps.googleusercontent.com';

  static const String yptBaseUrl = 'https://pi.tgclab.com';
  static const String signInJwtEndpoint = '/user/sign-in-jwt';

  static const int udpDiscoveryPort = 47221;
  static const String udpBroadcastAddress = '255.255.255.255';
  static const String udpPayloadType = 'deskypt-companion-auth';
  static const String udpAckType = 'deskypt-companion-ack';
  static const int udpPayloadVersion = 1;

  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color surfaceDark = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF666666);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFE53935);
}

import 'dart:convert';

class FocusModeSettings {
  final bool isEnabled;
  final bool isStrict;
  final List<String> blockedProcesses;
  final int checkIntervalSeconds;

  const FocusModeSettings({
    this.isEnabled = false,
    this.isStrict = false,
    this.blockedProcesses = const [
      'discord.exe',
      'telegram.exe',
      'steam.exe',
      'spotify.exe',
      'tiktok.exe',
      'epicgameslauncher.exe',
    ],
    this.checkIntervalSeconds = 5,
  });

  FocusModeSettings copyWith({
    bool? isEnabled,
    bool? isStrict,
    List<String>? blockedProcesses,
    int? checkIntervalSeconds,
  }) {
    return FocusModeSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      isStrict: isStrict ?? this.isStrict,
      blockedProcesses: blockedProcesses ?? this.blockedProcesses,
      checkIntervalSeconds: checkIntervalSeconds ?? this.checkIntervalSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'isStrict': isStrict,
      'blockedProcesses': blockedProcesses,
      'checkIntervalSeconds': checkIntervalSeconds,
    };
  }

  factory FocusModeSettings.fromJson(Map<String, dynamic> json) {
    return FocusModeSettings(
      isEnabled: json['isEnabled'] as bool? ?? false,
      isStrict: json['isStrict'] as bool? ?? false,
      blockedProcesses: (json['blockedProcesses'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toList() ??
          const [
            'discord.exe',
            'telegram.exe',
            'steam.exe',
            'spotify.exe',
            'tiktok.exe',
            'epicgameslauncher.exe',
          ],
      checkIntervalSeconds: json['checkIntervalSeconds'] as int? ?? 5,
    );
  }

  String encode() => jsonEncode(toJson());

  static FocusModeSettings decode(String source) {
    try {
      return FocusModeSettings.fromJson(jsonDecode(source) as Map<String, dynamic>);
    } catch (_) {
      return const FocusModeSettings();
    }
  }
}

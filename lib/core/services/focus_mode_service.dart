import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/focus_mode_settings_model.dart';

class FocusModeService {
  static const String _storageKey = 'deskypt_focus_mode_settings_v1';
  Timer? _monitorTimer;
  final StreamController<List<String>> _distractionsController =
      StreamController<List<String>>.broadcast();

  Stream<List<String>> get distractionsStream => _distractionsController.stream;

  Future<FocusModeSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return const FocusModeSettings();
    return FocusModeSettings.decode(raw);
  }

  Future<void> saveSettings(FocusModeSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, settings.encode());
  }

  Future<List<String>> getRunningProcessNames() async {
    final processNames = <String>{};
    try {
      if (Platform.isWindows) {
        final result = await Process.run('tasklist', ['/fo', 'csv', '/nh']);
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          final parts = line.split(',');
          if (parts.isNotEmpty) {
            final name = parts[0].replaceAll('"', '').trim().toLowerCase();
            if (name.isNotEmpty) processNames.add(name);
          }
        }
      } else if (Platform.isLinux || Platform.isMacOS) {
        final result = await Process.run('ps', ['-e', '-o', 'comm=']);
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          final name = line.trim().toLowerCase();
          if (name.isNotEmpty) processNames.add(name);
        }
      }
    } catch (_) {}
    return processNames.toList();
  }

  Future<List<String>> checkActiveDistractions(List<String> blockedList) async {
    if (blockedList.isEmpty) return [];
    final running = await getRunningProcessNames();
    final runningSet = running.toSet();

    final detected = <String>[];
    for (final blocked in blockedList) {
      final clean = blocked.trim().toLowerCase();
      if (clean.isEmpty) continue;
      if (runningSet.contains(clean) ||
          runningSet.any((r) => r.contains(clean) || clean.contains(r))) {
        detected.add(clean);
      }
    }
    return detected;
  }

  void startMonitoring(FocusModeSettings settings) {
    stopMonitoring();
    if (!settings.isEnabled) return;

    _monitorTimer = Timer.periodic(
      Duration(seconds: settings.checkIntervalSeconds),
      (_) async {
        final detected = await checkActiveDistractions(settings.blockedProcesses);
        if (detected.isNotEmpty) {
          _distractionsController.add(detected);
        }
      },
    );
  }

  void stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
  }

  void dispose() {
    stopMonitoring();
    _distractionsController.close();
  }
}

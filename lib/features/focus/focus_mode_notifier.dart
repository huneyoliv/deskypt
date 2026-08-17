import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/focus_mode_settings_model.dart';
import '../../core/services/focus_mode_service.dart';

final focusModeServiceProvider = Provider<FocusModeService>((ref) {
  final service = FocusModeService();
  ref.onDispose(() => service.dispose());
  return service;
});

class FocusModeState {
  final FocusModeSettings settings;
  final List<String> activeDistractions;
  final bool isMonitoring;
  final int distractionCount;
  final String? lastDetectedApp;

  const FocusModeState({
    this.settings = const FocusModeSettings(),
    this.activeDistractions = const [],
    this.isMonitoring = false,
    this.distractionCount = 0,
    this.lastDetectedApp,
  });

  FocusModeState copyWith({
    FocusModeSettings? settings,
    List<String>? activeDistractions,
    bool? isMonitoring,
    int? distractionCount,
    String? lastDetectedApp,
  }) {
    return FocusModeState(
      settings: settings ?? this.settings,
      activeDistractions: activeDistractions ?? this.activeDistractions,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      distractionCount: distractionCount ?? this.distractionCount,
      lastDetectedApp: lastDetectedApp ?? this.lastDetectedApp,
    );
  }
}

class FocusModeNotifier extends StateNotifier<FocusModeState> {
  final FocusModeService _service;
  StreamSubscription<List<String>>? _sub;

  FocusModeNotifier(this._service) : super(const FocusModeState()) {
    _init();
  }

  Future<void> _init() async {
    final loaded = await _service.loadSettings();
    if (!mounted) return;
    state = state.copyWith(settings: loaded);

    _sub = _service.distractionsStream.listen((distractions) {
      if (!mounted) return;
      state = state.copyWith(
        activeDistractions: distractions,
        distractionCount: state.distractionCount + 1,
        lastDetectedApp: distractions.isNotEmpty ? distractions.first : null,
      );
    });
  }

  Future<void> updateSettings(FocusModeSettings newSettings) async {
    state = state.copyWith(settings: newSettings);
    await _service.saveSettings(newSettings);
    if (state.isMonitoring) {
      _service.startMonitoring(newSettings);
    }
  }

  Future<void> toggleEnabled(bool enabled) async {
    final updated = state.settings.copyWith(isEnabled: enabled);
    await updateSettings(updated);
  }

  Future<void> toggleStrict(bool strict) async {
    final updated = state.settings.copyWith(isStrict: strict);
    await updateSettings(updated);
  }

  Future<void> addBlockedApp(String appName) async {
    final clean = appName.trim().toLowerCase();
    if (clean.isEmpty || state.settings.blockedProcesses.contains(clean)) return;
    final updatedList = [...state.settings.blockedProcesses, clean];
    await updateSettings(state.settings.copyWith(blockedProcesses: updatedList));
  }

  Future<void> removeBlockedApp(String appName) async {
    final clean = appName.trim().toLowerCase();
    final updatedList = state.settings.blockedProcesses.where((p) => p != clean).toList();
    await updateSettings(state.settings.copyWith(blockedProcesses: updatedList));
  }

  void startSessionMonitoring() {
    if (state.settings.isEnabled) {
      state = state.copyWith(isMonitoring: true, distractionCount: 0, activeDistractions: []);
      _service.startMonitoring(state.settings);
    }
  }

  void stopSessionMonitoring() {
    state = state.copyWith(isMonitoring: false, activeDistractions: []);
    _service.stopMonitoring();
  }

  void dismissAlert() {
    state = state.copyWith(activeDistractions: []);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final focusModeNotifierProvider =
    StateNotifierProvider<FocusModeNotifier, FocusModeState>((ref) {
  final service = ref.watch(focusModeServiceProvider);
  return FocusModeNotifier(service);
});

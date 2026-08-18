import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/update_service.dart';
import 'models/update_model.dart';

class UpdateState {
  final String currentVersion;
  final bool isChecking;
  final bool hasUpdate;
  final AppRelease? latestRelease;
  final String? errorMessage;
  final DateTime? lastCheckedAt;

  const UpdateState({
    this.currentVersion = '1.0.0',
    this.isChecking = false,
    this.hasUpdate = false,
    this.latestRelease,
    this.errorMessage,
    this.lastCheckedAt,
  });

  UpdateState copyWith({
    String? currentVersion,
    bool? isChecking,
    bool? hasUpdate,
    AppRelease? latestRelease,
    String? errorMessage,
    DateTime? lastCheckedAt,
    bool clearError = false,
  }) {
    return UpdateState(
      currentVersion: currentVersion ?? this.currentVersion,
      isChecking: isChecking ?? this.isChecking,
      hasUpdate: hasUpdate ?? this.hasUpdate,
      latestRelease: latestRelease ?? this.latestRelease,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
    );
  }
}

class UpdateNotifier extends StateNotifier<UpdateState> {
  final UpdateService _service;

  UpdateNotifier({
    required UpdateService service,
    String currentVersion = '1.0.0',
  })  : _service = service,
        super(UpdateState(currentVersion: currentVersion)) {
    checkForUpdates();
  }

  Future<void> checkForUpdates() async {
    if (state.isChecking) return;

    state = state.copyWith(isChecking: true, clearError: true);

    try {
      final release = await _service.fetchLatestRelease();
      if (release == null) {
        state = state.copyWith(
          isChecking: false,
          lastCheckedAt: DateTime.now(),
        );
        return;
      }

      final hasUpdate = release.isNewerThan(state.currentVersion);

      state = state.copyWith(
        isChecking: false,
        hasUpdate: hasUpdate,
        latestRelease: release,
        lastCheckedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isChecking: false,
        errorMessage: e.toString(),
        lastCheckedAt: DateTime.now(),
      );
    }
  }
}

final updateNotifierProvider =
    StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  final service = ref.watch(updateServiceProvider);
  return UpdateNotifier(service: service);
});

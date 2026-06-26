import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'update_installer.dart';
import 'update_manifest.dart';
import 'update_service.dart';

/// Loads the running app version from the platform package metadata.
final currentVersionLoaderProvider = Provider<CurrentVersionLoader>((ref) {
  return () async {
    final info = await PackageInfo.fromPlatform();
    return AppVersion.from(
          info.version,
          build: int.tryParse(info.buildNumber),
        ) ??
        const AppVersion(0, 0, 0);
  };
});

/// The running app version, exposed for display (e.g. on the Profile screen).
final currentAppVersionProvider = FutureProvider<AppVersion>(
  (ref) => ref.watch(currentVersionLoaderProvider)(),
);

final updateConfigProvider = Provider<UpdateConfig>(
  (ref) => UpdateConfig.resolve(),
);

final updateServiceProvider = Provider<UpdateService>((ref) {
  final service = UpdateService(
    config: ref.watch(updateConfigProvider),
    currentVersionLoader: ref.watch(currentVersionLoaderProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final updateInstallerProvider = Provider<UpdateInstaller>((ref) {
  final installer = UpdateInstaller(
    platform: ref.watch(updateConfigProvider).platform,
  );
  ref.onDispose(installer.dispose);
  return installer;
});

final updateControllerProvider =
    NotifierProvider<UpdateController, UpdateUiState>(UpdateController.new);

@immutable
class UpdateUiState {
  const UpdateUiState({
    this.availability,
    this.isChecking = false,
    this.checkError,
    this.progress = const UpdateProgress.idle(),
    this.isInstalling = false,
    this.installError,
    this.hasPrompted = false,
    this.hasCheckedOnLaunch = false,
  });

  final UpdateAvailability? availability;
  final bool isChecking;
  final String? checkError;
  final UpdateProgress progress;
  final bool isInstalling;
  final String? installError;

  /// Whether the launch prompt has already been shown this session, so we do
  /// not re-prompt on every navigation.
  final bool hasPrompted;
  final bool hasCheckedOnLaunch;

  bool get hasUpdate => availability?.hasUpdate ?? false;
  bool get isMandatory => availability?.isMandatory ?? false;
  PlatformRelease? get release => availability?.release;

  /// A non-mandatory update prompt should be shown once per session; a
  /// mandatory one should keep being shown until resolved.
  bool get shouldPrompt => hasUpdate && (isMandatory || !hasPrompted);

  UpdateUiState copyWith({
    UpdateAvailability? availability,
    bool? isChecking,
    String? checkError,
    bool clearCheckError = false,
    UpdateProgress? progress,
    bool? isInstalling,
    String? installError,
    bool clearInstallError = false,
    bool? hasPrompted,
    bool? hasCheckedOnLaunch,
  }) {
    return UpdateUiState(
      availability: availability ?? this.availability,
      isChecking: isChecking ?? this.isChecking,
      checkError: clearCheckError ? null : (checkError ?? this.checkError),
      progress: progress ?? this.progress,
      isInstalling: isInstalling ?? this.isInstalling,
      installError:
          clearInstallError ? null : (installError ?? this.installError),
      hasPrompted: hasPrompted ?? this.hasPrompted,
      hasCheckedOnLaunch: hasCheckedOnLaunch ?? this.hasCheckedOnLaunch,
    );
  }
}

class UpdateController extends Notifier<UpdateUiState> {
  @override
  UpdateUiState build() => const UpdateUiState();

  /// Runs a single silent check shortly after the app reaches the main shell.
  Future<void> checkOnLaunch() async {
    if (state.hasCheckedOnLaunch) return;
    state = state.copyWith(hasCheckedOnLaunch: true);
    await _check();
  }

  /// User-initiated check (e.g. from the Profile screen). Returns the result so
  /// the caller can show "you're up to date" feedback.
  Future<UpdateAvailability?> checkNow() => _check();

  Future<UpdateAvailability?> _check() async {
    if (state.isChecking) return state.availability;
    state = state.copyWith(isChecking: true, clearCheckError: true);
    try {
      final result = await ref.read(updateServiceProvider).check();
      state = state.copyWith(availability: result, isChecking: false);
      return result;
    } on UpdateException catch (error) {
      state = state.copyWith(isChecking: false, checkError: error.message);
      return null;
    } catch (error) {
      state = state.copyWith(isChecking: false, checkError: error.toString());
      return null;
    }
  }

  void markPrompted() => state = state.copyWith(hasPrompted: true);

  /// Downloads and installs the available release, streaming progress into
  /// [UpdateUiState.progress].
  Future<void> startInstall() async {
    final release = state.release;
    if (release == null || state.isInstalling) return;

    state = state.copyWith(
      isInstalling: true,
      clearInstallError: true,
      progress: const UpdateProgress(phase: InstallPhase.preparing),
    );

    try {
      await ref.read(updateInstallerProvider).install(
        release,
        onProgress: (progress) => state = state.copyWith(progress: progress),
      );
      // Windows exits the process during install; Android hands off to the OS
      // installer. Reaching here without exit just means the handoff happened.
      state = state.copyWith(isInstalling: false);
    } on UpdateException catch (error) {
      state = state.copyWith(
        isInstalling: false,
        installError: error.message,
        progress: const UpdateProgress(phase: InstallPhase.failed),
      );
    } catch (error) {
      state = state.copyWith(
        isInstalling: false,
        installError: error.toString(),
        progress: const UpdateProgress(phase: InstallPhase.failed),
      );
    }
  }

  /// Clears install progress/errors so the prompt can be retried cleanly.
  void resetInstall() {
    state = state.copyWith(
      isInstalling: false,
      clearInstallError: true,
      progress: const UpdateProgress.idle(),
    );
  }
}

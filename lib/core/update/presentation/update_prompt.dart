import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/infra_theme.dart';
import '../update_controller.dart';
import '../update_installer.dart';
import '../update_manifest.dart';

/// Wraps the authenticated app shell. Runs a single silent update check after
/// the first frame and shows the update prompt when a newer build is available.
class UpdateGate extends ConsumerStatefulWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends ConsumerState<UpdateGate> {
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(updateControllerProvider.notifier).checkOnLaunch();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UpdateUiState>(updateControllerProvider, (previous, next) {
      if (next.shouldPrompt && !_dialogOpen) {
        _showPrompt();
      }
    });
    return widget.child;
  }

  Future<void> _showPrompt() async {
    _dialogOpen = true;
    ref.read(updateControllerProvider.notifier).markPrompted();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showUpdateDialog(context);
      _dialogOpen = false;
    });
  }
}

/// Shows the update dialog. Mandatory updates are non-dismissible.
Future<void> showUpdateDialog(BuildContext context) {
  final container = ProviderScope.containerOf(context);
  container.read(updateControllerProvider.notifier).markPrompted();
  final mandatory =
      container.read(updateControllerProvider).isMandatory;
  return showDialog<void>(
    context: context,
    barrierDismissible: !mandatory,
    builder: (_) => const UpdateDialog(),
  );
}

class UpdateDialog extends ConsumerWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateControllerProvider);
    final controller = ref.read(updateControllerProvider.notifier);
    final release = state.release;
    final platform = ref.watch(updateConfigProvider).platform;

    final mandatory = state.isMandatory;
    final installing = state.isInstalling;
    final phase = state.progress.phase;
    final completed = phase == InstallPhase.completed;

    final title = mandatory ? 'Update required' : 'Update available';

    return PopScope(
      canPop: !mandatory && !installing,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(
              mandatory ? Icons.gpp_maybe_outlined : Icons.system_update_alt,
              color: mandatory ? InfraColors.orange : InfraColors.royalBlue,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (release != null)
                Text(
                  'Version ${release.version} is available.',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              if (state.availability?.currentVersion != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'You have ${state.availability!.currentVersion!.displayLabel}.',
                    style: const TextStyle(
                      color: InfraColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              if ((release?.notes ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: InfraColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: InfraColors.border),
                  ),
                  child: Text(
                    release!.notes!.trim(),
                    style: const TextStyle(fontSize: 13, height: 1.35),
                  ),
                ),
              ],
              if (installing || completed || phase == InstallPhase.failed) ...[
                const SizedBox(height: 16),
                _ProgressSection(state: state, platform: platform),
              ],
              if (state.installError != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.installError!,
                  style: const TextStyle(
                    color: InfraColors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (!installing && platform == UpdatePlatform.android) ...[
                const SizedBox(height: 12),
                const Text(
                  'You\'ll be asked to confirm the install when the download '
                  'finishes.',
                  style: TextStyle(
                    color: InfraColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: _actions(context, state, controller, platform),
      ),
    );
  }

  List<Widget> _actions(
    BuildContext context,
    UpdateUiState state,
    UpdateController controller,
    UpdatePlatform platform,
  ) {
    final mandatory = state.isMandatory;
    final installing = state.isInstalling;
    final failed = state.progress.phase == InstallPhase.failed;
    final completed = state.progress.phase == InstallPhase.completed;

    if (installing) {
      // Busy: no actions while the download/handoff is in flight.
      return const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Working...',
            style: TextStyle(color: InfraColors.textSecondary),
          ),
        ),
      ];
    }

    // Android hands off to the OS installer; let the user close the prompt.
    if (completed && platform == UpdatePlatform.android) {
      return [
        FilledButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Done'),
        ),
      ];
    }

    final primaryLabel = switch (platform) {
      UpdatePlatform.android || UpdatePlatform.windows =>
        failed ? 'Retry' : 'Update now',
      UpdatePlatform.macos || UpdatePlatform.unsupported => 'Open download',
    };

    return [
      if (!mandatory)
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Later'),
        ),
      FilledButton.icon(
        onPressed: () {
          if (failed) controller.resetInstall();
          controller.startInstall();
        },
        icon: const Icon(Icons.download, size: 18),
        label: Text(primaryLabel),
      ),
    ];
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.state, required this.platform});

  final UpdateUiState state;
  final UpdatePlatform platform;

  @override
  Widget build(BuildContext context) {
    final progress = state.progress;
    final fraction = progress.fraction;
    final label = _phaseLabel(progress, platform);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.phase == InstallPhase.downloading ? fraction : null,
            minHeight: 7,
            backgroundColor: InfraColors.border,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: InfraColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _phaseLabel(UpdateProgress progress, UpdatePlatform platform) {
    switch (progress.phase) {
      case InstallPhase.preparing:
        return 'Preparing...';
      case InstallPhase.downloading:
        final pct = progress.fraction;
        if (pct != null) {
          return 'Downloading... ${(pct * 100).toStringAsFixed(0)}%'
              ' (${_mb(progress.received)} / ${_mb(progress.total)})';
        }
        return 'Downloading... ${_mb(progress.received)}';
      case InstallPhase.verifying:
        return 'Verifying download...';
      case InstallPhase.extracting:
        return 'Extracting...';
      case InstallPhase.launching:
        return platform == UpdatePlatform.windows
            ? 'Applying update and restarting...'
            : 'Opening installer...';
      case InstallPhase.completed:
        return platform == UpdatePlatform.windows
            ? 'Update applied. The app will restart.'
            : 'Installer opened.';
      case InstallPhase.failed:
        return 'Update failed.';
      case InstallPhase.idle:
        return '';
    }
  }

  String _mb(int bytes) {
    if (bytes <= 0) return '0 MB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/infra_theme.dart';
import '../../../core/refresh/pull_to_refresh.dart';
import '../../../data/repositories/infra_repository.dart';
import '../../../shared/components/infra_components.dart';
import '../../../shared/widgets/infra_shell.dart';
import '../../infra/data/infra_report_service.dart';
import '../application/challan_flow_state.dart';
import '../application/challan_providers.dart';
import '../data/challan_portal_adapter.dart';
import '../domain/challan_models.dart';
import 'challan_portal_screen.dart';
import 'widgets/challan_list.dart';
import 'widgets/challan_preview_step.dart';
import 'widgets/challan_save_step.dart';
import 'widgets/challan_step_indicator.dart';
import 'widgets/challan_verification_step.dart';
import 'widgets/duplicate_challan_dialog.dart';
import 'widgets/government_portal_step.dart';
import 'widgets/material_selection_step.dart';

/// E-Pass Challan module: the five-step entry flow plus the saved-challan list.
///
/// Adapts across mobile (one step per screen, thumb-friendly), tablet (wider
/// stepper, split layout) and desktop (premium cards with the list alongside).
class ChallanScreen extends ConsumerStatefulWidget {
  const ChallanScreen({super.key});

  @override
  ConsumerState<ChallanScreen> createState() => _ChallanScreenState();
}

class _ChallanScreenState extends ConsumerState<ChallanScreen> {
  final Set<String> _selectedChallanIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(currentOrgPermissionsProvider);
    final width = MediaQuery.sizeOf(context).width;
    final visibleChallans =
        ref.watch(challansProvider).value ?? const <EPassChallan>[];
    final hasSelectedVisibleChallans = visibleChallans.any(
      (challan) => _selectedChallanIds.contains(challan.id),
    );

    // Keep the controller's offline flag in step with connectivity so the portal
    // button and its messaging stay correct.
    final online = ref.watch(networkOnlineProvider);
    ref.listen(networkOnlineProvider, (previous, next) {
      ref.read(challanFlowControllerProvider.notifier).setOffline(!next);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(challanFlowControllerProvider.notifier).setOffline(!online);
    });

    _listenForDuplicates();

    if (!permissions.canViewChallans) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.lock_outline,
          title: 'No access to challans',
          message: 'Ask an owner or manager to grant you access.',
        ),
      );
    }

    final isMobile = width <= AdaptiveBreakpoints.mobileMax;
    final isDesktop = width > AdaptiveBreakpoints.tabletMax;

    return Scaffold(
      backgroundColor: InfraColors.background,
      appBar: AppBar(
        title: const Text('E-Pass Challan'),
        actions: [
          if (!online)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Tooltip(
                message: 'Offline — portal verification needs internet',
                child: Icon(Icons.wifi_off_outlined, size: 20),
              ),
            ),
          if (_selectedChallanIds.isNotEmpty)
            IconButton(
              tooltip: 'Clear selected challans',
              icon: const Icon(Icons.clear_all_outlined),
              onPressed: _clearChallanSelection,
            ),
          IconButton(
            tooltip: hasSelectedVisibleChallans
                ? 'Download selected challans'
                : 'Download challan PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: visibleChallans.isEmpty ? null : _downloadListPdf,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          ref.invalidate(challansProvider);
          return ref.awaitRefresh(ref.read(challansProvider.future));
        },
        child: isDesktop
            ? _desktopLayout(permissions.canAddChallan)
            : isMobile
            ? _mobileLayout(permissions.canAddChallan)
            : _tabletLayout(permissions.canAddChallan),
      ),
    );
  }

  /// Surfaces the duplicate dialog whenever the flow detects an existing record.
  void _listenForDuplicates() {
    ref.listen(challanFlowControllerProvider, (previous, next) {
      final duplicate = next.duplicateOf;
      if (duplicate == null || previous?.duplicateOf?.id == duplicate.id) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await DuplicateChallanDialog.show(context, duplicate);
        if (!mounted) return;
        ref.read(challanFlowControllerProvider.notifier).dismissDuplicate();
      });
    });
  }

  // ---------------------------------------------------------------------------
  // Layouts
  // ---------------------------------------------------------------------------

  Widget _mobileLayout(bool canAdd) {
    final state = ref.watch(challanFlowControllerProvider);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (canAdd) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ChallanStepIndicator(
              current: state.step,
              compact: true,
              onStepTapped: _goToStep,
            ),
          ),
          _activeStep(),
          const SizedBox(height: 24),
        ] else
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: PaddedHint(
              icon: Icons.lock_outline,
              message:
                  'You can view challans but not add them. Ask an owner or '
                  'manager for access.',
            ),
          ),
        const _ListHeader(),
        const SizedBox(height: 12),
        ChallanList(
          shrinkWrap: true,
          onAddChallan: canAdd ? _restart : null,
          selectedChallanIds: _selectedChallanIds,
          onToggleSelection: _toggleChallanSelection,
          onClearSelection: _clearChallanSelection,
        ),
      ],
    );
  }

  Widget _tabletLayout(bool canAdd) {
    final state = ref.watch(challanFlowControllerProvider);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        if (canAdd) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: ChallanStepIndicator(
              current: state.step,
              onStepTapped: _goToStep,
            ),
          ),
          _activeStep(),
          const SizedBox(height: 28),
        ],
        const _ListHeader(),
        const SizedBox(height: 12),
        ChallanList(
          shrinkWrap: true,
          onAddChallan: canAdd ? _restart : null,
          selectedChallanIds: _selectedChallanIds,
          onToggleSelection: _toggleChallanSelection,
          onClearSelection: _clearChallanSelection,
        ),
      ],
    );
  }

  Widget _desktopLayout(bool canAdd) {
    final state = ref.watch(challanFlowControllerProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              if (canAdd) ...[
                ChallanStepIndicator(
                  current: state.step,
                  onStepTapped: _goToStep,
                ),
                const SizedBox(height: 20),
                _activeStep(),
                const SizedBox(height: 20),
                _StepOverviewCards(current: state.step),
              ] else
                const PaddedHint(
                  icon: Icons.lock_outline,
                  message:
                      'You can view challans but not add them. Ask an owner or '
                      'manager for access.',
                ),
            ],
          ),
        ),
        const VerticalDivider(width: 1, color: InfraColors.border),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ListHeader(),
                const SizedBox(height: 12),
                Expanded(
                  child: ChallanList(
                    onAddChallan: canAdd ? _restart : null,
                    selectedChallanIds: _selectedChallanIds,
                    onToggleSelection: _toggleChallanSelection,
                    onClearSelection: _clearChallanSelection,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Renders whichever step is active.
  Widget _activeStep() {
    final state = ref.watch(challanFlowControllerProvider);

    return switch (state.step) {
      ChallanFlowStep.selection => MaterialSelectionStep(
        onContinue: _continueFromSelection,
      ),
      ChallanFlowStep.portal => GovernmentPortalStep(
        onOpenPortal: _openPortal,
        onManualEntry: _startManualEntry,
        onBack: () =>
            ref.read(challanFlowControllerProvider.notifier).backToSelection(),
      ),
      ChallanFlowStep.verification => ChallanVerificationStep(
        onRetry: _openPortal,
        onBackToPortal: () =>
            ref.read(challanFlowControllerProvider.notifier).backToPortal(),
        onManualEntry: _startManualEntry,
      ),
      ChallanFlowStep.preview => ChallanPreviewStep(
        onConfirm: _save,
        onRetry: _openPortal,
        onBackToPortal: () =>
            ref.read(challanFlowControllerProvider.notifier).backToPortal(),
        onCancel: _restart,
      ),
      ChallanFlowStep.save => ChallanSaveStep(
        onAddAnother: () =>
            ref.read(challanFlowControllerProvider.notifier).startAnother(),
        onDone: _restart,
      ),
    };
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _continueFromSelection() async {
    await ref
        .read(challanFlowControllerProvider.notifier)
        .continueFromSelection();
  }

  void _goToStep(ChallanFlowStep step) {
    final controller = ref.read(challanFlowControllerProvider.notifier);
    switch (step) {
      case ChallanFlowStep.selection:
        controller.backToSelection();
      case ChallanFlowStep.portal:
        controller.backToPortal();
      case ChallanFlowStep.verification:
      case ChallanFlowStep.preview:
      case ChallanFlowStep.save:
        break;
    }
  }

  /// Opens the government portal WebView as a top-level route.
  Future<void> _openPortal() async {
    final state = ref.read(challanFlowControllerProvider);
    if (!ChallanPortalSupport.supportsInAppWebView()) return;

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChallanPortalScreen(
          portal: state.portal,
          challanNumber: state.challanNumber,
          financialYear: state.financialYear,
        ),
        fullscreenDialog: true,
      ),
    );
    // The flow controller already holds the capture outcome, so the step the
    // user lands on (preview or the verification error) is driven by state.
  }

  /// Starts a manual, explicitly unverified entry.
  Future<void> _startManualEntry() async {
    final state = ref.read(challanFlowControllerProvider);
    final payload = await showDialog<CapturedPortalPayload>(
      context: context,
      builder: (context) =>
          _ManualEntryDialog(challanNumber: state.challanNumber),
    );
    if (payload == null || !mounted) return;
    ref.read(challanFlowControllerProvider.notifier).setManualPayload(payload);
  }

  /// Exports the selected challans, or all currently visible challans when
  /// nothing is selected. The PDF places two challans on each A4 page.
  Future<void> _downloadListPdf() async {
    final messenger = ScaffoldMessenger.of(context);
    final visibleChallans =
        ref.read(challansProvider).value ?? const <EPassChallan>[];
    final challans = _selectedChallanIds.isEmpty
        ? visibleChallans
        : visibleChallans
              .where((challan) => _selectedChallanIds.contains(challan.id))
              .toList(growable: false);
    if (challans.isEmpty) {
      if (_selectedChallanIds.isNotEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No selected challans match the current filters.'),
          ),
        );
      }
      return;
    }

    try {
      final org = await ref.read(infraWorkspaceProvider.future);
      final projectIds = challans.map((c) => c.projectId).toSet();
      final project = projectIds.length == 1
          ? ref.read(projectByIdProvider(projectIds.first))
          : null;

      const service = InfraReportService();
      final file = await service.challansPdf(
        organizationName: org.name,
        project: project,
        subjectTitle: project?.name ??
            (projectIds.length == 1
                ? challans.first.projectName ?? 'Challans'
                : 'All Projects'),
        challans: challans,
      );
      await service.share(file, isPdf: true);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Challan PDF generated (${challans.length} challan(s)).'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not generate PDF: $error')),
      );
    }
  }

  void _toggleChallanSelection(String challanId) {
    setState(() {
      if (!_selectedChallanIds.add(challanId)) {
        _selectedChallanIds.remove(challanId);
      }
    });
  }

  void _clearChallanSelection() {
    if (_selectedChallanIds.isEmpty) return;
    setState(_selectedChallanIds.clear);
  }

  Future<void> _save() async {
    final saved = await ref.read(challanFlowControllerProvider.notifier).save();
    if (!mounted || saved == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Challan ${saved.challanNumber} saved')),
    );
  }

  void _restart() {
    ref.read(challanFlowControllerProvider.notifier).reset();
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.history, size: 18, color: InfraColors.textSecondary),
        SizedBox(width: 8),
        Text(
          'Recent challans',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ],
    );
  }
}

/// Desktop-only overview of the five sections, styled as premium cards.
class _StepOverviewCards extends StatelessWidget {
  const _StepOverviewCards({required this.current});

  final ChallanFlowStep current;

  static const _descriptions = <ChallanFlowStep, String>{
    ChallanFlowStep.selection:
        'Pick the project, material, financial year and challan number.',
    ChallanFlowStep.portal:
        'The Bihar Government portal opens securely inside LedgerPro.',
    ChallanFlowStep.verification:
        'You complete CAPTCHA and press Search; LedgerPro reads the result.',
    ChallanFlowStep.preview:
        'Review every captured field before anything is stored.',
    ChallanFlowStep.save:
        'Saved atomically with a server-side duplicate check and audit log.',
  };

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'How this works',
      icon: Icons.route_outlined,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final step in ChallanFlowStep.values)
            SizedBox(
              width: 220,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: step == current
                      ? InfraColors.royalBlue.withValues(alpha: 0.06)
                      : InfraColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: step == current
                        ? InfraColors.royalBlue.withValues(alpha: 0.35)
                        : InfraColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${step.stepNumber}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: InfraColors.royalBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _descriptions[step]!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: InfraColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Manual entry used offline, on platforms without a WebView, or when the user
/// needs to correct captured data. Always produces `manual_unverified`.
class _ManualEntryDialog extends StatefulWidget {
  const _ManualEntryDialog({required this.challanNumber});

  final String challanNumber;

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vehicle = TextEditingController();
  final _mineral = TextEditingController();
  final _quantity = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _vehicle.dispose();
    _mineral.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add manual entry'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This entry is not verified against the government portal. It '
                'will be saved as "Manual (unverified)".',
                style: TextStyle(
                  fontSize: 12,
                  color: InfraColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicle,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Vehicle number'),
                validator: (value) =>
                    ChallanText.normalizeToken(value ?? '').isEmpty
                    ? 'Required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mineral,
                decoration: const InputDecoration(labelText: 'Mineral name'),
                validator: (value) =>
                    (value ?? '').trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantity,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  suffixText: 'MT',
                ),
                validator: (value) {
                  final parsed = double.tryParse((value ?? '').trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a quantity greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Challan date'),
                child: InkWell(
                  onTap: _pickDate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${_date.day.toString().padLeft(2, '0')}/'
                      '${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Continue')),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 6),
      lastDate: DateTime(now.year + 1, 12, 31),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final quantityText = _quantity.text.trim();
    Navigator.of(context).pop(
      CapturedPortalPayload(
        challanNumber: widget.challanNumber,
        challanDate: _date.toUtc(),
        vehicleNumber: _vehicle.text.trim().toUpperCase(),
        mineralName: _mineral.text.trim(),
        quantity: double.tryParse(quantityText),
        quantityText: quantityText,
        quantityUnit: 'MT',
        rawFields: const {'entry_source': 'manual'},
        capturedAt: DateTime.now(),
      ),
    );
  }
}

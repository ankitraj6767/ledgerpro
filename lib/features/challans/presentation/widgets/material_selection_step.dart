import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/infra_theme.dart';
import '../../../../data/repositories/infra_repository.dart';
import '../../../../shared/components/infra_components.dart';
import '../../../../shared/models/infra_models.dart';
import '../../application/challan_flow_controller.dart';
import '../../application/challan_flow_state.dart';
import '../../application/challan_providers.dart';
import '../../domain/material_type.dart';

/// Step 1 — project, material, financial year and challan number.
class MaterialSelectionStep extends ConsumerStatefulWidget {
  const MaterialSelectionStep({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<MaterialSelectionStep> createState() =>
      _MaterialSelectionStepState();
}

class _MaterialSelectionStepState extends ConsumerState<MaterialSelectionStep> {
  late final TextEditingController _challanController;

  @override
  void initState() {
    super.initState();
    _challanController = TextEditingController(
      text: ref.read(challanFlowControllerProvider).challanNumber,
    );
  }

  @override
  void dispose() {
    _challanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challanFlowControllerProvider);
    final controller = ref.read(challanFlowControllerProvider.notifier);
    final projectsAsync = ref.watch(projectsProvider);
    final years = FinancialYear.options();

    return SectionCard(
      title: 'Project & Material',
      icon: Icons.inventory_2_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          projectsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SkeletonBox(height: 52),
            ),
            error: (error, _) => ErrorStateView(
              message: 'Could not load projects.',
              onRetry: () => ref.invalidate(projectsProvider),
            ),
            data: (projects) => _projectSelector(
              projects: projects,
              state: state,
              controller: controller,
            ),
          ),
          const SizedBox(height: 16),

          const _FieldLabel('Material type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final material in ChallanMaterialType.values)
                ChoiceChip(
                  label: Text(material.label),
                  selected: state.materialType == material,
                  onSelected: (selected) =>
                      controller.selectMaterial(selected ? material : null),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'The portal\'s own Mineral Name is always stored alongside your '
            'choice. A mismatch is flagged, never overwritten.',
            style: TextStyle(fontSize: 11, color: InfraColors.textSecondary),
          ),
          const SizedBox(height: 16),

          const _FieldLabel('Financial year'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: years.contains(state.financialYear)
                ? state.financialYear
                : FinancialYear.current(),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today_outlined),
            ),
            items: [
              for (final year in years)
                DropdownMenuItem(value: year, child: Text(year)),
            ],
            onChanged: (value) {
              if (value != null) controller.selectFinancialYear(value);
            },
          ),
          const SizedBox(height: 16),

          const _FieldLabel('Challan number'),
          const SizedBox(height: 8),
          TextField(
            controller: _challanController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            inputFormatters: [LengthLimitingTextInputFormatter(64)],
            decoration: const InputDecoration(
              hintText: 'e.g. BR2026001234',
              prefixIcon: Icon(Icons.confirmation_number_outlined),
            ),
            onChanged: (value) {
              controller.setChallanNumber(value);
              final tidied = ref
                  .read(challanFlowControllerProvider)
                  .challanNumber;
              if (tidied != value) {
                _challanController.value = TextEditingValue(
                  text: tidied,
                  selection: TextSelection.collapsed(offset: tidied.length),
                );
              }
            },
            onSubmitted: (_) => widget.onContinue(),
          ),

          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            _InlineError(message: state.errorMessage!),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.canContinueFromSelection && !state.isBusy
                  ? widget.onContinue
                  : null,
              icon: state.isCheckingDuplicate
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
              label: Text(state.isCheckingDuplicate ? 'Checking…' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _projectSelector({
    required List<InfraProject> projects,
    required ChallanFlowState state,
    required ChallanFlowController controller,
  }) {
    if (projects.isEmpty) {
      return const PaddedHint(
        icon: Icons.business_outlined,
        message:
            'Create a project first — every challan must belong to a project.',
      );
    }

    final selectedId = projects.any((p) => p.id == state.projectId)
        ? state.projectId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Project', required: true),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedId,
          isExpanded: true,
          decoration: const InputDecoration(
            hintText: 'Select a project',
            prefixIcon: Icon(Icons.business_outlined),
          ),
          items: [
            for (final project in projects)
              DropdownMenuItem(
                value: project.id,
                child: Text(project.name, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (value) => controller.selectProject(value),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
        if (required)
          const Text(' *', style: TextStyle(color: InfraColors.red)),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: InfraColors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 16, color: InfraColors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: InfraColors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small inline hint used when a prerequisite is missing.
class PaddedHint extends StatelessWidget {
  const PaddedHint({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InfraColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: InfraColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: InfraColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: InfraColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

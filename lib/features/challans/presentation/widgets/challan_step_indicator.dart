import 'package:flutter/material.dart';

import '../../../../app/theme/infra_theme.dart';
import '../../application/challan_flow_state.dart';

/// Five-step progress indicator.
///
/// Compact on mobile (numbered dots + the active step's title) and a full
/// labelled stepper from tablet width up, so no layout overflows horizontally.
class ChallanStepIndicator extends StatelessWidget {
  const ChallanStepIndicator({
    super.key,
    required this.current,
    this.compact = false,
    this.onStepTapped,
  });

  final ChallanFlowStep current;

  /// Forces the compact layout regardless of available width.
  final bool compact;

  /// Called when the user taps an already-completed step.
  final ValueChanged<ChallanFlowStep>? onStepTapped;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useCompact = compact || constraints.maxWidth < 560;
        return Semantics(
          label:
              'Step ${current.stepNumber} of ${ChallanFlowStep.values.length}: '
              '${current.title}',
          child: useCompact ? _buildCompact(context) : _buildFull(context),
        );
      },
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final step in ChallanFlowStep.values) ...[
              _Dot(step: step, current: current, onTap: _tapHandler(step)),
              if (step != ChallanFlowStep.values.last)
                Expanded(child: _Connector(done: step.index < current.index)),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Step ${current.stepNumber} of ${ChallanFlowStep.values.length} — '
          '${current.title}',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: InfraColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFull(BuildContext context) {
    return Row(
      children: [
        for (final step in ChallanFlowStep.values) ...[
          _Dot(step: step, current: current, onTap: _tapHandler(step)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              step.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: step == current ? FontWeight.w900 : FontWeight.w600,
                color: step == current
                    ? InfraColors.textPrimary
                    : InfraColors.textSecondary,
              ),
            ),
          ),
          if (step != ChallanFlowStep.values.last) ...[
            const SizedBox(width: 8),
            Expanded(child: _Connector(done: step.index < current.index)),
            const SizedBox(width: 8),
          ],
        ],
      ],
    );
  }

  VoidCallback? _tapHandler(ChallanFlowStep step) {
    final handler = onStepTapped;
    if (handler == null || step.index >= current.index) return null;
    return () => handler(step);
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.step, required this.current, this.onTap});

  final ChallanFlowStep step;
  final ChallanFlowStep current;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = step.index < current.index;
    final active = step == current;
    final color = done
        ? InfraColors.green
        : active
        ? InfraColors.royalBlue
        : InfraColors.border;

    return Tooltip(
      message: step.title,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done || active ? color : InfraColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: done
              ? const Icon(Icons.check, size: 15, color: Colors.white)
              : Text(
                  '${step.stepNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: active ? Colors.white : InfraColors.textSecondary,
                  ),
                ),
        ),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: done ? InfraColors.green : InfraColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

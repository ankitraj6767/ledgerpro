import 'package:flutter/material.dart';

import '../../../../app/theme/infra_theme.dart';
import '../../application/challan_flow_state.dart';
import 'challan_workspace_theme.dart';

/// Responsive progress panel. Completed steps retain their navigation targets.
class ChallanStepIndicator extends StatelessWidget {
  const ChallanStepIndicator({
    super.key,
    required this.current,
    this.compact = false,
    this.onStepTapped,
  });

  final ChallanFlowStep current;
  final bool compact;
  final ValueChanged<ChallanFlowStep>? onStepTapped;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useCompact =
            compact ||
            constraints.maxWidth < 620 ||
            MediaQuery.textScalerOf(context).scale(12) > 16;
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [InfraColors.navy, Color(0xFF143348)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF284254)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NEW CHALLAN',
                style: TextStyle(
                  color: ChallanWorkspaceTheme.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Step ${current.stepNumber} of ${ChallanFlowStep.values.length} — ${current.title}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final step in ChallanFlowStep.values)
                    Expanded(
                      child: _StepSegment(
                        step: step,
                        current: current,
                        showLabel: !useCompact,
                        onTap:
                            onStepTapped == null || step.index >= current.index
                            ? null
                            : () => onStepTapped!(step),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepSegment extends StatelessWidget {
  const _StepSegment({
    required this.step,
    required this.current,
    required this.showLabel,
    this.onTap,
  });

  final ChallanFlowStep step;
  final ChallanFlowStep current;
  final bool showLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = step.index < current.index;
    final active = step == current;
    final color = active
        ? ChallanWorkspaceTheme.gold
        : done
        ? const Color(0xFF8CCBB8)
        : const Color(0xFF92A4B4);
    return Semantics(
      selected: active,
      label: '${step.title}${done ? ', completed' : ''}',
      child: Tooltip(
        message: step.title,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(3, 10, 3, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: active || done ? color : const Color(0xFF3B5163),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  if (showLabel) ...[
                    const SizedBox(height: 10),
                    if (done)
                      Icon(Icons.check_rounded, size: 14, color: color)
                    else
                      Text(
                        '0${step.stepNumber}',
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Text(
                      step.title,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        height: 1.4,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

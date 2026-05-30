import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/infra_theme.dart';
import '../../core/money/money.dart';

class DonutSlice {
  const DonutSlice({
    required this.label,
    required this.amountPaise,
    required this.color,
  });

  final String label;
  final int amountPaise;
  final Color color;
}

/// Donut chart + legend for expense category breakdown.
class DonutExpenseChart extends StatelessWidget {
  const DonutExpenseChart({super.key, required this.slices});

  final List<DonutSlice> slices;

  static const palette = <Color>[
    InfraColors.royalBlue,
    InfraColors.gold,
    InfraColors.green,
    InfraColors.orange,
    Color(0xFF7C3AED),
    Color(0xFF0EA5E9),
    Color(0xFFEC4899),
    Color(0xFF64748B),
  ];

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<int>(0, (sum, s) => sum + s.amountPaise);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _DonutPainter(slices: slices, total: total),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 10,
                      color: InfraColors.textSecondary,
                    ),
                  ),
                  Text(
                    Money.fromPaise(total).formatCompactInr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: slices.map((s) {
              final pct = total == 0
                  ? 0.0
                  : (s.amountPaise / total * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: s.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.total});

  final List<DonutSlice> slices;
  final int total;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height) / 2;
    const stroke = 18.0;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = InfraColors.border;
    canvas.drawCircle(center, radius - stroke / 2, bgPaint);

    if (total <= 0) return;

    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.amountPaise / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..color = slice.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - stroke / 2),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.slices != slices || oldDelegate.total != total;
}

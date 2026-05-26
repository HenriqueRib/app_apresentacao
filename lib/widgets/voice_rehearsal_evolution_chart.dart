import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/voice_rehearsal_attempt.dart';

enum EvolutionMetric { score, fillers, wpm }

/// Gráfico leve de evolução dos últimos ensaios.
class VoiceRehearsalEvolutionChart extends StatefulWidget {
  final List<VoiceRehearsalAttempt> attempts;

  const VoiceRehearsalEvolutionChart({
    super.key,
    required this.attempts,
  });

  @override
  State<VoiceRehearsalEvolutionChart> createState() =>
      _VoiceRehearsalEvolutionChartState();
}

class _VoiceRehearsalEvolutionChartState
    extends State<VoiceRehearsalEvolutionChart> {
  EvolutionMetric _metric = EvolutionMetric.score;

  @override
  Widget build(BuildContext context) {
    final chronological = widget.attempts.reversed.take(10).toList();
    if (chronological.length < 2) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Faça mais ensaios para ver a evolução (mínimo 2).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolução',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<EvolutionMetric>(
              segments: const [
                ButtonSegment(
                  value: EvolutionMetric.score,
                  label: Text('Nota', style: TextStyle(fontSize: 11)),
                ),
                ButtonSegment(
                  value: EvolutionMetric.fillers,
                  label: Text('Muletas', style: TextStyle(fontSize: 11)),
                ),
                ButtonSegment(
                  value: EvolutionMetric.wpm,
                  label: Text('WPM', style: TextStyle(fontSize: 11)),
                ),
              ],
              selected: {_metric},
              onSelectionChanged: (s) => setState(() => _metric = s.first),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              width: double.infinity,
              child: _metric == EvolutionMetric.score
                  ? CustomPaint(
                      painter: _LineChartPainter(
                        values: chronological
                            .map((a) => a.finalScore)
                            .toList(),
                        maxY: 10,
                        color: AppTheme.primaryColor,
                      ),
                      child: Container(),
                    )
                  : CustomPaint(
                      painter: _BarChartPainter(
                        values: chronological.map((a) {
                          switch (_metric) {
                            case EvolutionMetric.fillers:
                              return a.summary.metrics.fillerCount.toDouble();
                            case EvolutionMetric.wpm:
                              return a.summary.metrics.wpm;
                            case EvolutionMetric.score:
                              return a.finalScore;
                          }
                        }).toList(),
                        maxY: _metric == EvolutionMetric.wpm ? 200 : null,
                        color: _metric == EvolutionMetric.fillers
                            ? AppTheme.warningColor
                            : Colors.teal,
                      ),
                      child: Container(),
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: chronological.map((a) {
                return Text(
                  '${a.createdAt.day}/${a.createdAt.month}',
                  style: const TextStyle(fontSize: 9),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double maxY;
  final Color color;

  _LineChartPainter({
    required this.values,
    required this.maxY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - (values[i] / maxY).clamp(0.0, 1.0) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - (values[i] / maxY).clamp(0.0, 1.0) * size.height;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final double? maxY;
  final Color color;

  _BarChartPainter({
    required this.values,
    required this.maxY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final max = maxY ?? values.reduce((a, b) => a > b ? a : b);
    if (max <= 0) return;

    final barWidth = size.width / values.length * 0.6;
    final gap = size.width / values.length;

    final paint = Paint()..color = color.withValues(alpha: 0.85);
    for (var i = 0; i < values.length; i++) {
      final h = (values[i] / max).clamp(0.0, 1.0) * size.height;
      final x = i * gap + (gap - barWidth) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, barWidth, h),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

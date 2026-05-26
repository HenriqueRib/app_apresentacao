import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/voice_rehearsal.dart';
import '../services/voice_analysis_engine.dart';
import '../utils/voice_rehearsal_ui.dart';

/// Faixa compacta: nota · tempo · WPM · palavras · volume.
class VoiceRehearsalCompactMetrics extends StatelessWidget {
  final double score;
  final int elapsedSeconds;
  final VoiceRehearsalMetrics metrics;
  final bool isRecording;
  final String? scoreDeltaLabel;
  final Color? scoreDeltaColor;
  final bool minimalStyle;

  const VoiceRehearsalCompactMetrics({
    super.key,
    required this.score,
    required this.elapsedSeconds,
    required this.metrics,
    this.isRecording = false,
    this.scoreDeltaLabel,
    this.scoreDeltaColor,
    this.minimalStyle = false,
  });

  static String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _volumeColor(double db) {
    if (db == 0) return Colors.grey;
    if (db < VoiceAnalysisThresholds.volumeLowDb) return AppTheme.warningColor;
    if (db > VoiceAnalysisThresholds.volumeHighDb) return AppTheme.errorColor;
    return AppTheme.accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = voiceRehearsalScoreColor(score);
    final wpmText =
        metrics.wpm > 0 ? '${metrics.wpm.toStringAsFixed(0)} WPM' : '— WPM';
    final db = metrics.avgAmplitudeDb;
    final volColor = _volumeColor(db);
    final volFill = isRecording ? ((db + 60) / 50).clamp(0.0, 1.0) : 0.0;

    return Material(
      color: minimalStyle ? AppTheme.backgroundColor : Colors.grey.shade50,
      elevation: minimalStyle ? 0 : 1,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: minimalStyle ? 8 : 6,
        ),
        child: Row(
          children: [
            Text(
              '${score.toStringAsFixed(1)}/10',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            _dot(),
            Text(
              formatTime(elapsedSeconds),
              style: _metricStyle(),
            ),
            _dot(),
            Text(wpmText, style: _metricStyle()),
            _dot(),
            Text('${metrics.wordCount} pal', style: _metricStyle()),
            const SizedBox(width: 6),
            SizedBox(
              width: 24,
              height: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: ColoredBox(
                  color: Colors.grey.shade300,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: volFill > 0 ? volFill : 0.01,
                    child: ColoredBox(color: volColor),
                  ),
                ),
              ),
            ),
            if (scoreDeltaLabel != null) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (scoreDeltaColor ?? AppTheme.textSecondary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  scoreDeltaLabel!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: scoreDeltaColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dot() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text('·', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
      );

  TextStyle _metricStyle() => TextStyle(
        fontSize: 11,
        color: AppTheme.textSecondary,
      );
}

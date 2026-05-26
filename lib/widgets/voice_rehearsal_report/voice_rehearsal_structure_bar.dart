import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/voice_speech_structure_analyzer.dart';

class VoiceRehearsalStructureBar extends StatelessWidget {
  final Map<String, dynamic>? structureJson;

  const VoiceRehearsalStructureBar({
    super.key,
    this.structureJson,
  });

  @override
  Widget build(BuildContext context) {
    if (structureJson == null) {
      return Text(
        'Estrutura não detectada neste ensaio.',
        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      );
    }

    final structure = SpeechStructureAnalysis.fromJson(structureJson!);
    final introPct = structure.intro.pctOfTotal.clamp(0, 100);
    final conclPct = structure.conclusion.pctOfTotal.clamp(0, 100);
    final bodyPct = (100 - introPct - conclPct).clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                if (introPct > 0)
                  Expanded(
                    flex: introPct.round().clamp(1, 100),
                    child: Container(color: AppTheme.primaryColor),
                  ),
                if (bodyPct > 0)
                  Expanded(
                    flex: bodyPct.round().clamp(1, 100),
                    child: Container(color: AppTheme.shellAccentTeal),
                  ),
                if (conclPct > 0)
                  Expanded(
                    flex: conclPct.round().clamp(1, 100),
                    child: Container(color: AppTheme.secondaryColor),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _LegendDot(
              color: AppTheme.primaryColor,
              label: 'Intro ${introPct.toStringAsFixed(0)}%',
            ),
            _LegendDot(
              color: AppTheme.shellAccentTeal,
              label: 'Corpo ${bodyPct.toStringAsFixed(0)}%',
            ),
            _LegendDot(
              color: AppTheme.secondaryColor,
              label: 'Conclusão ${conclPct.toStringAsFixed(0)}%',
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

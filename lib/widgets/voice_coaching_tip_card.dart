import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/voice_rehearsal.dart';
import '../../../screens/tools/bet_guide/characteristic_detail_screen.dart';
import '../../../screens/tools/bet_guide/self_assessment_screen.dart';
import '../../../services/characteristics_service.dart';

Color categoryAccentColor(String category) {
  switch (category) {
    case 'muleta':
    case 'repeticao':
    case 'vaga':
      return AppTheme.warningColor;
    case 'ritmo':
    case 'pausas':
      return Colors.blue;
    case 'volume':
    case 'modulacao':
      return Colors.purple;
    case 'articulacao':
      return Colors.teal;
    default:
      return AppTheme.primaryColor;
  }
}

/// Card de coaching: observado / evite / faça assim.
class VoiceCoachingTipCard extends StatelessWidget {
  final VoiceImprovementInsight insight;
  final bool compact;
  final bool showActions;

  const VoiceCoachingTipCard({
    super.key,
    required this.insight,
    this.compact = false,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final charId = insight.characteristicId;
    final char = charId != null
        ? CharacteristicsService.instance.getCharacteristicById(charId)
        : null;
    final title = char != null ? '#${char.id} ${char.title}' : insight.message;
    final accent = categoryAccentColor(insight.category);
    final showFullActions = showActions || !compact;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: char != null
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CharacteristicDetailScreen(characteristic: char),
                  ),
                )
            : null,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (insight.severityRank >= 3)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Alto impacto',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.errorColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (!compact && insight.observed != null) ...[
                        const SizedBox(height: 8),
                        _CoachingBlock(
                          label: 'O que detectamos',
                          text: insight.observed!,
                          color: AppTheme.textSecondary,
                          icon: Icons.visibility_outlined,
                        ),
                      ] else if (compact && insight.observed != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          insight.observed!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            height: 1.35,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (!compact &&
                          insight.beforeExample != null &&
                          insight.afterExample != null) ...[
                        const SizedBox(height: 8),
                        _CoachingBlock(
                          label: 'Antes',
                          text: insight.beforeExample!,
                          color: Colors.grey.shade700,
                          icon: Icons.record_voice_over_outlined,
                        ),
                        const SizedBox(height: 8),
                        _CoachingBlock(
                          label: 'Depois',
                          text: insight.afterExample!,
                          color: AppTheme.successColor.withValues(alpha: 0.9),
                          icon: Icons.check,
                          background: AppTheme.successColor.withValues(alpha: 0.08),
                        ),
                      ],
                      if (!compact && insight.avoid != null) ...[
                        const SizedBox(height: 8),
                        _CoachingBlock(
                          label: 'Evite',
                          text: insight.avoid!,
                          color: AppTheme.errorColor.withValues(alpha: 0.85),
                          icon: Icons.block,
                          background: AppTheme.errorColor.withValues(alpha: 0.06),
                        ),
                      ],
                      if (insight.tryInstead != null) ...[
                        SizedBox(height: compact ? 6 : 8),
                        _CoachingBlock(
                          label: 'Faça assim',
                          text: insight.tryInstead!,
                          color: AppTheme.successColor.withValues(alpha: 0.9),
                          icon: Icons.check_circle_outline,
                          background:
                              AppTheme.successColor.withValues(alpha: 0.08),
                        ),
                      ] else if (insight.suggestion.isNotEmpty) ...[
                        SizedBox(height: compact ? 6 : 8),
                        _CoachingBlock(
                          label: 'Faça assim',
                          text: insight.suggestion,
                          color: AppTheme.successColor.withValues(alpha: 0.9),
                          icon: Icons.check_circle_outline,
                          background:
                              AppTheme.successColor.withValues(alpha: 0.08),
                        ),
                      ],
                      if (char != null && showFullActions)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SelfAssessmentScreen(
                                    focusCharacteristicId: char.id,
                                  ),
                                ),
                              ),
                              child: const Text('Autoavaliar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CharacteristicDetailScreen(
                                    characteristic: char,
                                  ),
                                ),
                              ),
                              child: const Text('Ver be-T'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachingBlock extends StatelessWidget {
  final String label;
  final String text;
  final Color color;
  final IconData icon;
  final Color? background;

  const _CoachingBlock({
    required this.label,
    required this.text,
    required this.color,
    required this.icon,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

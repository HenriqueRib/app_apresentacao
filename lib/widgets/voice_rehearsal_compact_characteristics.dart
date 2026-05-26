import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/voice_rehearsal.dart';
import '../services/characteristics_service.dart';
import '../utils/voice_rehearsal_ui.dart';

/// Faixa compacta com características be-T identificadas na sessão.
class VoiceRehearsalCompactCharacteristics extends StatelessWidget {
  final List<VoiceFeedbackEvent> events;
  final VoiceRehearsalSummary? summary;
  final bool minimalStyle;

  const VoiceRehearsalCompactCharacteristics({
    super.key,
    required this.events,
    this.summary,
    this.minimalStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = buildCharacteristicStripItems(
      events: events,
      summary: summary,
      resolveTitle: (id) =>
          CharacteristicsService.instance.getCharacteristicById(id)?.title,
    );

    if (items.isEmpty) {
      return Material(
        color: minimalStyle ? AppTheme.backgroundColor : Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Text(
            'Características: aguardando análise…',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return Material(
      color: minimalStyle ? AppTheme.backgroundColor : Colors.grey.shade50,
      child: SizedBox(
        height: 28,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          itemCount: items.length,
          separatorBuilder: (_, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '·',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final color = characteristicScoreColor(item.score);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '#${item.id} ${item.title}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  characteristicScoreShortLabel(item.score),
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withValues(alpha: 0.85),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

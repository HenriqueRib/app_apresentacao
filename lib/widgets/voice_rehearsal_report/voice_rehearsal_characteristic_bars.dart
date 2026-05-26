import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../utils/voice_rehearsal_ui.dart';

class VoiceRehearsalCharacteristicBars extends StatelessWidget {
  final List<CharacteristicStripItem> items;
  final int maxItems;

  const VoiceRehearsalCharacteristicBars({
    super.key,
    required this.items,
    this.maxItems = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'Nenhuma característica be-T destacada neste ensaio.',
        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      );
    }

    final shown = items.take(maxItems).toList();
    return Column(
      children: shown.map((item) {
        final color = characteristicScoreColor(item.score);
        final fill = (item.score + 1) / 4;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    characteristicScoreShortLabel(item.score),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fill.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: color.withValues(alpha: 0.12),
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

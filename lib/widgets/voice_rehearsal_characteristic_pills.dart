import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../utils/voice_rehearsal_ui.dart';

/// Até 3 características be-T em pills; o restante em “+N”.
class VoiceRehearsalCharacteristicPills extends StatelessWidget {
  final List<CharacteristicStripItem> items;
  final VoidCallback? onShowAll;

  const VoiceRehearsalCharacteristicPills({
    super.key,
    required this.items,
    this.onShowAll,
  });

  static const int _visibleCount = 3;

  static void showAllBottomSheet(
    BuildContext context, {
    required List<CharacteristicStripItem> items,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              'Características be-T',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    '#${item.id}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                title: Text(item.title, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          'Características: aguardando análise…',
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      );
    }

    final visible = items.take(_visibleCount).toList();
    final extra = items.length - visible.length;

    return Material(
      color: AppTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...visible.map((item) => _Pill(item: item)),
            if (extra > 0)
              ActionChip(
                label: Text('+$extra'),
                onPressed: onShowAll,
                visualDensity: VisualDensity.compact,
                labelStyle: const TextStyle(fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final CharacteristicStripItem item;

  const _Pill({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = characteristicScoreColor(item.score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '#${item.id}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              item.title,
              style: const TextStyle(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

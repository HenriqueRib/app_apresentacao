import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/voice_rehearsal.dart';

/// Banner sticky com a dica prioritária para ação imediata.
class VoiceCoachingFocusBanner extends StatelessWidget {
  final VoiceImprovementInsight? topInsight;
  final String? carryOverLabel;
  final VoidCallback? onTap;

  const VoiceCoachingFocusBanner({
    super.key,
    required this.topInsight,
    this.carryOverLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final insight = topInsight;
    if (insight == null) return const SizedBox.shrink();

    final actionText = insight.tryInstead ?? insight.suggestion;
    if (actionText.isEmpty) return const SizedBox.shrink();

    final highPriority = insight.severityRank >= 3;

    return Semantics(
      header: true,
      label: 'Foco agora: $actionText',
      child: Material(
      color: AppTheme.warningColor.withValues(alpha: 0.1),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: highPriority
                    ? AppTheme.warningColor
                    : AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Foco agora',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: highPriority
                                ? AppTheme.warningColor
                                : AppTheme.primaryColor,
                          ),
                        ),
                        if (carryOverLabel != null &&
                            carryOverLabel!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Chip(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            label: Text(
                              carryOverLabel!,
                              style: const TextStyle(fontSize: 9),
                            ),
                          ),
                        ],
                        if (highPriority) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withValues(alpha: 0.12),
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
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      actionText,
                      style: const TextStyle(fontSize: 12, height: 1.35),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.expand_more, size: 18, color: AppTheme.textLight),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

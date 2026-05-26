import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/voice_rehearsal_provider.dart';

class VoiceRehearsalWarmupBanner extends StatelessWidget {
  const VoiceRehearsalWarmupBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceRehearsalProvider>(
      builder: (context, provider, _) {
        if (!provider.isWarmupPhase) return const SizedBox.shrink();

        return Material(
          color: AppTheme.secondaryColor.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.self_improvement,
                    size: 20, color: AppTheme.secondaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aquecimento',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Nota desligada — aqueça a voz. Toque quando quiser começar valendo.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => provider.endWarmupAndStartMain(),
                  child: const Text('Começar valendo'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

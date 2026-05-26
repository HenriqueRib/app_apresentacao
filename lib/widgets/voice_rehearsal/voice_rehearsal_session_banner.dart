import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/voice_rehearsal_provider.dart';

/// Marcos de tempo, pausa inteligente e avisos da sessão.
class VoiceRehearsalSessionBanner extends StatelessWidget {
  const VoiceRehearsalSessionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceRehearsalProvider>(
      builder: (context, provider, _) {
        final milestone = provider.sessionMilestoneBanner;
        final smartPause = provider.smartPauseBanner;

        if (milestone == null && smartPause == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (milestone != null)
              _BannerTile(
                message: milestone,
                icon: Icons.flag_outlined,
                color: AppTheme.primaryColor,
                onDismiss: null,
              ),
            if (smartPause != null)
              _BannerTile(
                message: smartPause,
                icon: Icons.spa_outlined,
                color: AppTheme.warningColor,
                onDismiss: provider.dismissSmartPauseBanner,
              ),
          ],
        );
      },
    );
  }
}

class _BannerTile extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onDismiss;

  const _BannerTile({
    required this.message,
    required this.icon,
    required this.color,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 12, color: color),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}

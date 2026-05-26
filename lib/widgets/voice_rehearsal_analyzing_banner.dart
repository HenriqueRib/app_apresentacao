import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Feedback enquanto a gravação é transcrita após o ensaio.
class VoiceRehearsalAnalyzingBanner extends StatelessWidget {
  const VoiceRehearsalAnalyzingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primaryColor.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Transcrevendo gravação…',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: const LinearProgressIndicator(minHeight: 3),
            ),
            const SizedBox(height: 4),
            Text(
              'O relatório será atualizado em instantes. Você pode aguardar na tela.',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

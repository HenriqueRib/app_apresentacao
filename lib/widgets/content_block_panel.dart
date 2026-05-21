import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';
import 'text_viewer_sheet.dart';

/// Painel de bloco de conteúdo (Gerar / Visualizar / Copiar / Melhorar) — espelha o painel web.
class ContentBlockPanel extends StatelessWidget {
  final String title;
  final String? content;
  final Color accentColor;
  final bool isLoading;
  final bool canGenerate;
  final String generateLabel;
  final VoidCallback? onGenerate;
  final VoidCallback? onImprove;
  final VoidCallback? onCopy;

  const ContentBlockPanel({
    super.key,
    required this.title,
    this.content,
    this.accentColor = AppTheme.primaryColor,
    this.isLoading = false,
    this.canGenerate = true,
    this.generateLabel = 'Gerar',
    this.onGenerate,
    this.onImprove,
    this.onCopy,
  });

  bool get _hasContent => content != null && content!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        color: accentColor.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: accentColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (!_hasContent)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canGenerate && onGenerate != null)
                  FilledButton.icon(
                    onPressed: onGenerate,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: Text(generateLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                OutlinedButton.icon(
                  onPressed: () => showTextViewerSheet(
                    context,
                    title: title,
                    content: content!,
                    onImprove: onImprove,
                  ),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Visualizar'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copiado!')),
                    );
                    onCopy?.call();
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copiar'),
                ),
                if (onImprove != null)
                  OutlinedButton.icon(
                    onPressed: onImprove,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Melhorar'),
                  ),
                if (canGenerate && onGenerate != null)
                  TextButton.icon(
                    onPressed: onGenerate,
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('Regenerar'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

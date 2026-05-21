import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showTextViewerSheet(
  BuildContext context, {
  required String title,
  required String content,
  VoidCallback? onImprove,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: SelectableText(
                  content.isEmpty ? '(vazio)' : content,
                  style: const TextStyle(height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (onImprove != null)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onImprove();
                    },
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Melhorar'),
                  ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copiado!')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/parte.dart';
import '../../../providers/parte_provider.dart';
import '../../../widgets/content_block_panel.dart';
import 'parte_esboco_editor_screen.dart';
import 'parte_form_screen.dart';
import 'parte_presentation_screen.dart';

class ParteDetailScreen extends StatelessWidget {
  final String parteId;

  const ParteDetailScreen({super.key, required this.parteId});

  Parte? _find(ParteProvider p) => p.getParteById(parteId);

  void _improveDialog(BuildContext context, Parte parte) {
    final instr = TextEditingController();
    final esboco = TextEditingController(text: parte.esbocoManuscrito ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Melhorar esboço (IA)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: instr,
              decoration: const InputDecoration(labelText: 'Instrução *'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: esboco,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Esboço atual'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ParteProvider>().improveEsboco(
                    parte.id,
                    instr.text.trim(),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Melhorar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParteProvider>(
      builder: (context, provider, _) {
        final parte = _find(provider);
        if (parte == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Parte')),
            body: const Center(child: Text('Parte não encontrada.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(parte.tema),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ParteFormScreen(existing: parte),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  provider.deleteParte(parte.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Tópicos', style: Theme.of(context).textTheme.titleSmall),
              ...parte.topicos.map(
                (t) => ListTile(
                  dense: true,
                  title: Text(t.descricao),
                  subtitle: Text(
                    [
                      if (t.texto != null && t.texto!.isNotEmpty) t.texto,
                      if (t.fonte != null && t.fonte!.isNotEmpty) t.fonte,
                    ].join(' · '),
                  ),
                ),
              ),
              if (parte.conteudoOriginal != null &&
                  parte.conteudoOriginal!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  parte.conteudoOriginal!.length > 200
                      ? '${parte.conteudoOriginal!.substring(0, 200)}...'
                      : parte.conteudoOriginal!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 16),
              ContentBlockPanel(
                title: 'Esboço manuscrito',
                content: parte.esbocoManuscrito,
                isLoading: provider.isLoading,
                generateLabel: 'Gerar esboço',
                onGenerate: () => provider.generateEsboco(parte.id),
                onImprove: parte.esbocoManuscrito != null &&
                        parte.esbocoManuscrito!.isNotEmpty
                    ? () => _improveDialog(context, parte)
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: parte.esbocoManuscrito == null
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ParteEsbocoEditorScreen(parteId: parte.id),
                                ),
                              ),
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Editar esboço'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: parte.esbocoManuscrito == null ||
                              parte.esbocoManuscrito!.isEmpty
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PartePresentationScreen(
                                    parteId: parte.id,
                                  ),
                                ),
                              ),
                      icon: const Icon(Icons.record_voice_over),
                      label: const Text('Apresentar 10min'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

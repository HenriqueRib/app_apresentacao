import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/resposta_gerada.dart';
import '../../../providers/meeting_hub_provider.dart';
import '../../../widgets/text_viewer_sheet.dart';

class MeetingRespostasTab extends StatelessWidget {
  const MeetingRespostasTab({super.key});

  void _showNovaRespostaDialog(BuildContext context) {
    final perguntaCtrl = TextEditingController();
    final textoCtrl = TextEditingController();
    final fonteCtrl = TextEditingController();
    final promptCtrl = TextEditingController(text: 'Resposta simples e objetiva');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gerar resposta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: perguntaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Pergunta (opcional)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textoCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Texto base *',
                  hintText: 'Cole o texto de base...',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fonteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Fonte de pesquisa *',
                  hintText: 'Ex: w23.01 pág. 5 par. 3',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: promptCtrl,
                decoration: const InputDecoration(
                  labelText: 'Instrução específica',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textoCtrl.text.trim().isEmpty ||
                  fonteCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preencha texto base e fonte.'),
                  ),
                );
                return;
              }
              context.read<MeetingHubProvider>().addResposta(
                    pergunta: perguntaCtrl.text.trim().isEmpty
                        ? null
                        : perguntaCtrl.text.trim(),
                    textoBase: textoCtrl.text.trim(),
                    fontePesquisa: fonteCtrl.text.trim(),
                    promptEspecifico: promptCtrl.text.trim(),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Gerar'),
          ),
        ],
      ),
    );
  }

  void _showImproveDialog(BuildContext context, RespostaGerada item) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Melhorar resposta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.respostaGerada.length > 200
                  ? '${item.respostaGerada.substring(0, 200)}...'
                  : item.respostaGerada,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Instrução de melhoria *',
                hintText: 'Ex: Torne mais curto e direto',
              ),
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
              if (ctrl.text.trim().isEmpty) return;
              context
                  .read<MeetingHubProvider>()
                  .improveResposta(item.id, ctrl.text.trim());
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
    return Consumer<MeetingHubProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingRespostas && provider.respostas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = provider.respostas;

        return Stack(
          children: [
            if (list.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.question_answer_outlined, size: 48),
                      const SizedBox(height: 12),
                      const Text('Nenhuma resposta gerada ainda.'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showNovaRespostaDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Nova resposta'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final item = list[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.pergunta != null &&
                              item.pergunta!.isNotEmpty)
                            Text(
                              'Pergunta: ${item.pergunta}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          Text(
                            'Fonte: ${item.fontePesquisa}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.respostaGerada.length > 120
                                ? '${item.respostaGerada.substring(0, 120)}...'
                                : item.respostaGerada,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => showTextViewerSheet(
                                  context,
                                  title: 'Resposta',
                                  content: item.respostaGerada,
                                  onImprove: () =>
                                      _showImproveDialog(context, item),
                                ),
                                icon: const Icon(Icons.visibility, size: 16),
                                label: const Text('Visualizar'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showImproveDialog(context, item),
                                icon: const Icon(Icons.auto_fix_high, size: 16),
                                label: const Text('Melhorar'),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: item.respostaGerada),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Copiado!')),
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 16),
                                label: const Text('Copiar'),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppTheme.errorColor,
                                ),
                                onPressed: () =>
                                    provider.deleteResposta(item.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            if (provider.isLoadingRespostas)
              const Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(),
              ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: provider.isLoadingRespostas
                    ? null
                    : () => _showNovaRespostaDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Nova resposta'),
              ),
            ),
          ],
        );
      },
    );
  }
}

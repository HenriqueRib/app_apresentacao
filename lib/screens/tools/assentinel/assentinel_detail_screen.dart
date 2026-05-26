import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/assentinel_provider.dart';
import '../../../widgets/content_block_panel.dart';
import '../../../widgets/text_viewer_sheet.dart';

class AssentinelDetailScreen extends StatefulWidget {
  final String studyId;

  const AssentinelDetailScreen({super.key, required this.studyId});

  @override
  State<AssentinelDetailScreen> createState() => _AssentinelDetailScreenState();
}

class _AssentinelDetailScreenState extends State<AssentinelDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AssentinelProvider>(
      builder: (context, provider, _) {
        final study = provider.getStudyById(widget.studyId);
        if (study == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Estudo')),
            body: const Center(child: Text('Estudo não encontrado.')),
          );
        }

        final loading = provider.isLoading;
        final hasValidId = study.id.trim().isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              hasValidId ? 'Estudo #${study.id}' : 'Estudo (sem ID)',
            ),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!hasValidId)
                MaterialBanner(
                  content: const Text(
                    'Este estudo perdeu o identificador. Exclua e importe o texto novamente.',
                  ),
                  leading: const Icon(Icons.warning_amber),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              if (provider.syncError != null)
                MaterialBanner(
                  content: Text(
                    provider.syncError!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  leading: const Icon(Icons.cloud_off),
                  actions: [
                    TextButton(
                      onPressed: () => provider.load(),
                      child: const Text('Tentar de novo'),
                    ),
                  ],
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conteúdo do estudo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(study.conteudoEstudo),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => showTextViewerSheet(
                          context,
                          title: 'Conteúdo bruto',
                          content: study.conteudoEstudo,
                        ),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Visualizar completo'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ContentBlockPanel(
                title: 'Comentário inicial',
                content: study.comentarioInicial,
                accentColor: Colors.blue,
                isLoading: loading,
                generateLabel: 'Gerar inicial',
                onGenerate: hasValidId
                    ? () => provider.generateComment(
                          study.id,
                          'comentario-inicial',
                        )
                    : null,
                onImprove: hasValidId && study.comentarioInicial != null
                    ? () => provider.generateComment(
                          study.id,
                          'comentario-inicial',
                        )
                    : null,
              ),
              const SizedBox(height: 12),
              ContentBlockPanel(
                title: 'Comentário final',
                content: study.comentarioFinal,
                accentColor: AppTheme.warningColor,
                isLoading: loading,
                generateLabel: 'Gerar final',
                onGenerate: hasValidId
                    ? () => provider.generateComment(
                          study.id,
                          'comentario-final',
                        )
                    : null,
                onImprove: hasValidId && study.comentarioFinal != null
                    ? () => provider.generateComment(
                          study.id,
                          'comentario-final',
                        )
                    : null,
              ),
              const SizedBox(height: 12),
              ContentBlockPanel(
                title: 'Resumo-ponte',
                content: study.resumoComentarios,
                accentColor: AppTheme.accentColor,
                isLoading: loading,
                canGenerate:
                    study.comentarioInicial != null &&
                    study.comentarioFinal != null,
                generateLabel: 'Gerar resumo',
                onGenerate: hasValidId &&
                        study.comentarioInicial != null &&
                        study.comentarioFinal != null
                    ? () => provider.generateComment(study.id, 'resumo')
                    : null,
                onImprove: hasValidId && study.resumoComentarios != null
                    ? () => provider.generateComment(study.id, 'resumo')
                    : null,
              ),
              if (study.comentarioInicial == null ||
                  study.comentarioFinal == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Gere inicial e final antes do resumo-ponte.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

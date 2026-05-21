import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/assentinel_provider.dart';
import 'assentinel_detail_screen.dart';

class AssentinelScreen extends StatefulWidget {
  const AssentinelScreen({super.key});

  @override
  State<AssentinelScreen> createState() => _AssentinelScreenState();
}

class _AssentinelScreenState extends State<AssentinelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssentinelProvider>().load();
    });
  }

  void _showAddStudyDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_stories, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('Importar Artigo / Texto'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cole o conteúdo dos parágrafos ou pontos que deseja estudar e comentar:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Cole o texto do estudo aqui...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                context.read<AssentinelProvider>().addStudy(text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Estudo criado com sucesso!')),
                );
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, AssentinelProvider provider) {
    final inicialController = TextEditingController(text: provider.settings['prompt_inicial']);
    final finalController = TextEditingController(text: provider.settings['prompt_final']);
    final resumoController = TextEditingController(text: provider.settings['prompt_resumo']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('Diretrizes de IA (Prompts)'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Personalize as instruções enviadas para a IA:'),
              const SizedBox(height: 12),
              _buildPromptField('Comentário Inicial', inicialController),
              const SizedBox(height: 12),
              _buildPromptField('Comentário Final', finalController),
              const SizedBox(height: 12),
              _buildPromptField('Resumo/Ponte', resumoController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              provider.saveSettings({
                'prompt_inicial': inicialController.text.trim(),
                'prompt_final': finalController.text.trim(),
                'prompt_resumo': resumoController.text.trim(),
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Diretrizes salvas com sucesso!')),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Ex: Seja direto, cite a aplicação prática...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Estudo de A Sentinela'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<AssentinelProvider>(
            builder: (context, provider, _) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                await provider.refreshSettings();
                if (!context.mounted) return;
                _showSettingsDialog(context, provider);
              },
              tooltip: 'Configurar Prompts',
            ),
          ),
        ],
      ),
      body: Consumer<AssentinelProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.studies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final studies = provider.studies;
          final syncError = provider.syncError;

          if (studies.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_stories_outlined,
                        size: 64,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Nenhum artigo cadastrado',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adicione parágrafos ou o tema da lição semanal para gerar seus comentários da Sentinela com ajuda de Inteligência Artificial.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _showAddStudyDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Importar Novo Texto'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              if (syncError != null)
                MaterialBanner(
                  content: Text(syncError, style: const TextStyle(fontSize: 12)),
                  leading: const Icon(Icons.cloud_off),
                  actions: [
                    TextButton(
                      onPressed: () => provider.load(),
                      child: const Text('Tentar de novo'),
                    ),
                  ],
                ),
              Expanded(
                child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: studies.length,
            itemBuilder: (context, index) {
              final study = studies[index];
              final dateString = '${study.createdAt.day}/${study.createdAt.month}/${study.createdAt.year}';
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssentinelDetailScreen(studyId: study.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.menu_book, color: AppTheme.primaryColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Estudo #$index',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Excluir Estudo?'),
                                    content: const Text('Isso removerá este estudo e todos os comentários gerados permanentemente.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          provider.deleteStudy(study.id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Excluir', style: TextStyle(color: AppTheme.errorColor)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          study.conteudoEstudo,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  study.comentarioInicial != null ? Icons.check_circle : Icons.circle_outlined,
                                  size: 14,
                                  color: study.comentarioInicial != null ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                const Text('Ini', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(width: 12),
                                Icon(
                                  study.comentarioFinal != null ? Icons.check_circle : Icons.circle_outlined,
                                  size: 14,
                                  color: study.comentarioFinal != null ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                const Text('Fim', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                const SizedBox(width: 12),
                                Icon(
                                  study.resumoComentarios != null ? Icons.check_circle : Icons.circle_outlined,
                                  size: 14,
                                  color: study.resumoComentarios != null ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                const Text('Ponte', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            Text(
                              dateString,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudyDialog(context),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Importar Artigo'),
      ),
    );
  }
}

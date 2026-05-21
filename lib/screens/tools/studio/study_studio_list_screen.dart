import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/study_studio_provider.dart';
import 'study_studio_editor_screen.dart';
import 'flashcard_study_screen.dart';

class StudyStudioListScreen extends StatefulWidget {
  const StudyStudioListScreen({super.key});

  @override
  State<StudyStudioListScreen> createState() => _StudyStudioListScreenState();
}

class _StudyStudioListScreenState extends State<StudyStudioListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudyStudioProvider>().load();
    });
  }

  Future<void> _createOutline() async {
    final titleController = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo esboço'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Título',
            hintText: 'Ex: Parte de sábado',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, titleController.text),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    if (title == null || !mounted) return;
    final outline =
        await context.read<StudyStudioProvider>().createOutline(title);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudyStudioEditorScreen(outlineId: outline.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Estúdio de Esboços'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createOutline,
        icon: const Icon(Icons.add),
        label: const Text('Novo esboço'),
      ),
      body: Consumer<StudyStudioProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.outlines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.style, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Crie tópicos curtos e treine com flashcards',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Diferente de "Criar Esboço" na barra inferior, aqui você escreve suas próprias ideias.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.outlines.length,
            itemBuilder: (context, index) {
              final outline = provider.outlines[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    child: Text('${outline.topics.length}'),
                  ),
                  title: Text(outline.title),
                  subtitle: Text(
                    '${outline.topics.length} tópico(s) · '
                    '${_formatDate(outline.updatedAt)}',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                StudyStudioEditorScreen(outlineId: outline.id),
                          ),
                        );
                      } else if (value == 'flashcards' && outline.topics.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                FlashcardStudyScreen(outlineId: outline.id),
                          ),
                        );
                      } else if (value == 'delete') {
                        await provider.deleteOutline(outline.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Editar tópicos'),
                      ),
                      const PopupMenuItem(
                        value: 'flashcards',
                        child: Text('Modo memorização'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Excluir'),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          StudyStudioEditorScreen(outlineId: outline.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

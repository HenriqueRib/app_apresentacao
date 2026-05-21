import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../models/study_outline.dart';
import '../../../providers/study_studio_provider.dart';
import '../../../services/api_service.dart';
import 'flashcard_study_screen.dart';

class StudyStudioEditorScreen extends StatefulWidget {
  final String outlineId;

  const StudyStudioEditorScreen({super.key, required this.outlineId});

  @override
  State<StudyStudioEditorScreen> createState() =>
      _StudyStudioEditorScreenState();
}

class _StudyStudioEditorScreenState extends State<StudyStudioEditorScreen> {
  final _uuid = const Uuid();
  bool _isImproving = false;

  Future<void> _addTopic(StudyOutline outline) async {
    final ideaController = TextEditingController();
    final bibleController = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo tópico'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ideaController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ideia curta',
                  hintText: 'Máx. ~200 caracteres recomendado',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bibleController,
                decoration: const InputDecoration(
                  labelText: 'Referência bíblica',
                  hintText: 'Ex: Salmo 37:5',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    if (saved != true || ideaController.text.trim().isEmpty || !mounted) {
      return;
    }
    final topic = StudyTopic(
      id: _uuid.v4(),
      shortIdea: ideaController.text.trim(),
      bibleReference: bibleController.text.trim(),
    );
    final updated = outline.copyWith(
      topics: [...outline.topics, topic],
      updatedAt: DateTime.now(),
    );
    await context.read<StudyStudioProvider>().updateOutline(updated);
  }

  Future<void> _improveTopic(StudyTopic topic, StudyOutline outline) async {
    if (topic.shortIdea.trim().isEmpty) return;
    setState(() => _isImproving = true);
    try {
      final improved = await ApiService().improveText(topic.shortIdea);
      final updatedTopics = outline.topics.map((t) {
        if (t.id == topic.id) {
          return t.copyWith(shortIdea: improved);
        }
        return t;
      }).toList();
      await context.read<StudyStudioProvider>().updateOutline(
            outline.copyWith(topics: updatedTopics, updatedAt: DateTime.now()),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tópico refinado pela IA.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Não foi possível refinar agora. Verifique a conexão.\n$e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isImproving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyStudioProvider>(
      builder: (context, provider, _) {
        final outline = provider.getById(widget.outlineId);
        if (outline == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Estúdio')),
            body: const Center(child: Text('Esboço não encontrado.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(outline.title),
            actions: [
              if (outline.topics.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.style),
                  tooltip: 'Flashcards',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          FlashcardStudyScreen(outlineId: outline.id),
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addTopic(outline),
            icon: const Icon(Icons.add),
            label: const Text('Tópico'),
          ),
          body: outline.topics.isEmpty
              ? const Center(
                  child: Text('Adicione tópicos curtos para começar.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: outline.topics.length,
                  itemBuilder: (context, index) {
                    final topic = outline.topics[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.shortIdea,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (topic.bibleReference.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.menu_book, size: 16),
                                  const SizedBox(width: 6),
                                  Text(topic.bibleReference),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: _isImproving
                                      ? null
                                      : () => _improveTopic(topic, outline),
                                  icon: _isImproving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.auto_fix_high),
                                  label: const Text('Melhorar este tópico'),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    final updated = outline.copyWith(
                                      topics: outline.topics
                                          .where((t) => t.id != topic.id)
                                          .toList(),
                                      updatedAt: DateTime.now(),
                                    );
                                    await provider.updateOutline(updated);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

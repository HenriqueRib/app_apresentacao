import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/study_studio_provider.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final String outlineId;

  const FlashcardStudyScreen({super.key, required this.outlineId});

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  int _currentIndex = 0;
  bool _showBack = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyStudioProvider>(
      builder: (context, provider, _) {
        final outline = provider.getById(widget.outlineId);
        if (outline == null || outline.topics.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Memorização')),
            body: const Center(child: Text('Nenhum tópico para estudar.')),
          );
        }

        final topics = outline.topics;
        final topic = topics[_currentIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text('${_currentIndex + 1} / ${topics.length}'),
          ),
          body: GestureDetector(
            onTap: () => setState(() => _showBack = !_showBack),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 4,
                      color: _showBack
                          ? AppTheme.primaryColor.withValues(alpha: 0.08)
                          : Colors.white,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _showBack ? Icons.menu_book : Icons.lightbulb,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _showBack ? 'Verso' : 'Frente',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: AppTheme.textLight),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _showBack
                                    ? (topic.bibleReference.isNotEmpty
                                        ? topic.bibleReference
                                        : topic.optionalNote.isNotEmpty
                                            ? topic.optionalNote
                                            : 'Sem referência — toque para voltar')
                                    : topic.shortIdea,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no cartão para virar',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filled(
                        onPressed: _currentIndex > 0
                            ? () => setState(() {
                                  _currentIndex--;
                                  _showBack = false;
                                })
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton.filled(
                        onPressed: _currentIndex < topics.length - 1
                            ? () => setState(() {
                                  _currentIndex++;
                                  _showBack = false;
                                })
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

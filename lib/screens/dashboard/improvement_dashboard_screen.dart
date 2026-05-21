import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/speech.dart';
import '../../providers/speech_provider.dart';
import '../../services/characteristics_service.dart';

class ImprovementDashboardScreen extends StatefulWidget {
  final Speech? initialSpeech;

  const ImprovementDashboardScreen({super.key, this.initialSpeech});

  @override
  State<ImprovementDashboardScreen> createState() =>
      _ImprovementDashboardScreenState();
}

class _ImprovementDashboardScreenState
    extends State<ImprovementDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprimoramento'),
      ),
      body: Consumer<SpeechProvider>(
        builder: (context, provider, _) {
          final stats = provider.getProgressStats();
          final executed = provider.speeches
              .where((s) => s.status == SpeechStatus.executed)
              .toList();
          final focusedSpeech = widget.initialSpeech ?? provider.currentSpeech;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildOverviewCard(stats),
              if (focusedSpeech != null) ...[
                const SizedBox(height: 24),
                _buildFocusedSpeechNotesCard(focusedSpeech),
              ],
              const SizedBox(height: 24),
              _buildCompetenciesCard(),
              const SizedBox(height: 24),
              _buildExecutedSpeechesList(executed),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visão Geral do Progresso',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    icon: Icons.assignment,
                    label: 'Discursos',
                    value: '${stats['totalSpeeches']}',
                    color: AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    icon: Icons.check_circle,
                    label: 'Executados',
                    value: '${stats['executedCount']}',
                    color: AppTheme.successColor,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    icon: Icons.trending_up,
                    label: 'Taxa Sucesso',
                    value: '${stats['successRate']}%',
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'O sucesso é proporcional ao número de pessoas que você ajuda.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusedSpeechNotesCard(Speech speech) {
    final hasFeedback = speech.feedbackRecord != null;
    final notesPreview = hasFeedback && speech.feedbackRecord!.lessonsLearned.isNotEmpty
        ? speech.feedbackRecord!.lessonsLearned
        : 'Nenhuma observação registrada ainda.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aprimorar Discurso em Foco',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              speech.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Objetivo: ${speech.centralObjective}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                notesPreview,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showQuickNotesDialog(speech),
                icon: const Icon(Icons.edit_note),
                label: Text(hasFeedback ? 'Editar Observações' : 'Adicionar Observações'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetenciesCard() {
    final competencies = CharacteristicsService.instance.allCompetencies;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Competências de Avaliação',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Baseado na pesquisa do Wall Street Journal',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...competencies.map((comp) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(comp.name),
                        Text(
                          '${comp.weight.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: comp.weight / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      comp.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutedSpeechesList(List<Speech> executed) {
    if (executed.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.assignment_outlined,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Nenhum discurso executado ainda',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Execute seus discursos para ver análises de desempenho.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discursos Executados',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...executed.map((speech) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.successColor.withValues(alpha: 0.1),
                child: const Icon(Icons.done, color: AppTheme.successColor),
              ),
              title: Text(speech.title),
              subtitle: Text(
                speech.feedbackRecord != null
                    ? 'Feedback registrado'
                    : 'Adicionar feedback',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showFeedbackDialog(speech),
            ),
          );
        }),
      ],
    );
  }

  void _showFeedbackDialog(Speech speech) {
    final strengthsController = TextEditingController();
    final improvementsController = TextEditingController();
    final lessonsController = TextEditingController();
    bool objectiveAchieved = speech.feedbackRecord?.objectiveAchieved ?? false;
    int engagement = speech.feedbackRecord?.audienceEngagement ?? 3;

    if (speech.feedbackRecord != null) {
      strengthsController.text = speech.feedbackRecord!.strengths.join('\n');
      improvementsController.text =
          speech.feedbackRecord!.improvements.join('\n');
      lessonsController.text = speech.feedbackRecord!.lessonsLearned;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Feedback: ${speech.title}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Objetivo: ${speech.centralObjective}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: const Text('Objetivo alcançado?'),
                      value: objectiveAchieved,
                      onChanged: (value) {
                        setModalState(() {
                          objectiveAchieved = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Engajamento da audiência',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Slider(
                      value: engagement.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '$engagement/5',
                      onChanged: (value) {
                        setModalState(() {
                          engagement = value.toInt();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: strengthsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Pontos fortes',
                        hintText: 'O que deu certo?',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: improvementsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Pontos a melhorar',
                        hintText: 'O que pode ser melhorado?',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: lessonsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Lições aprendidas',
                        hintText: 'O que você aprendeu?',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        final feedback = FeedbackRecord(
                          objectiveAchieved: objectiveAchieved,
                          audienceEngagement: engagement,
                          strengths: strengthsController.text
                              .split('\n')
                              .where((s) => s.isNotEmpty)
                              .toList(),
                          improvements: improvementsController.text
                              .split('\n')
                              .where((s) => s.isNotEmpty)
                              .toList(),
                          lessonsLearned: lessonsController.text,
                        );

                        final provider = context.read<SpeechProvider>();
                        await provider.addFeedback(speech.id, feedback);

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Feedback salvo!'),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        }
                      },
                      child: const Text('Salvar Feedback'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showQuickNotesDialog(Speech speech) {
    final notesController = TextEditingController(
      text: speech.feedbackRecord?.lessonsLearned ?? '',
    );
    final improvementsController = TextEditingController(
      text: speech.feedbackRecord?.improvements.join('\n') ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Observações: ${speech.title}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Lições aprendidas',
                    hintText: 'O que funcionou e o que ajustar no próximo discurso?',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: improvementsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Pontos de melhoria (um por linha)',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final current = speech.feedbackRecord;
                      final feedback = FeedbackRecord(
                        competencyRatings: current?.competencyRatings ?? const {},
                        strengths: current?.strengths ?? const [],
                        improvements: improvementsController.text
                            .split('\n')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList(),
                        lessonsLearned: notesController.text.trim(),
                        objectiveAchieved: current?.objectiveAchieved ?? false,
                        audienceEngagement: current?.audienceEngagement ?? 0,
                      );

                      final provider = context.read<SpeechProvider>();
                      await provider.addFeedback(speech.id, feedback);

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Observações salvas com sucesso!'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      }
                    },
                    child: const Text('Salvar Observações'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

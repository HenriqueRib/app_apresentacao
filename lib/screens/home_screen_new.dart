import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/speech_provider.dart';
import '../models/speech.dart';
import '../services/characteristics_service.dart';
import 'planning/speech_planning_screen.dart';
import 'preparation/outline_editor_screen.dart';
import 'training/training_module_screen.dart';
import 'execution/stage_mode_new_screen.dart';
import 'dashboard/improvement_dashboard_screen.dart';
import 'characteristics/characteristics_library_screen.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await CharacteristicsService.instance.loadData();
    if (mounted) {
      await context.read<SpeechProvider>().loadSpeeches();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          CharacteristicsLibraryScreen(),
          ImprovementDashboardScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '53 Lições',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progresso',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SpeechPlanningScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Novo Discurso'),
            )
          : null,
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Poder de Convencer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Método Shinyashiki + 53 Características',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMethodCycle(context),
                const SizedBox(height: 24),
                _buildSpeechesList(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCycle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ciclo de Performance',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CycleStepCard(
                step: 1,
                title: 'Planejar',
                icon: Icons.track_changes,
                color: Colors.blue,
                description: 'Defina objetivo e analise assistência',
              ),
              _CycleStepCard(
                step: 2,
                title: 'Preparar',
                icon: Icons.edit_note,
                color: Colors.orange,
                description: 'Construa esboço com método L.E.I.A.',
              ),
              _CycleStepCard(
                step: 3,
                title: 'Treinar',
                icon: Icons.fitness_center,
                color: Colors.purple,
                description: 'Ensaie com foco nas características',
              ),
              _CycleStepCard(
                step: 4,
                title: 'Executar',
                icon: Icons.record_voice_over,
                color: AppTheme.accentColor,
                description: 'Modo Palco com teleprompter',
              ),
              _CycleStepCard(
                step: 5,
                title: 'Aprimorar',
                icon: Icons.trending_up,
                color: AppTheme.secondaryColor,
                description: 'Feedback e melhoria contínua',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeechesList(BuildContext context) {
    return Consumer<SpeechProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.speeches.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seus Discursos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.activeSpeechesSorted.length,
              itemBuilder: (context, index) {
                final speech = provider.activeSpeechesSorted[index];
                return _SpeechCard(
                  speech: speech,
                  isSelected: provider.currentSpeech?.id == speech.id,
                  onTap: () => provider.setCurrentSpeech(speech),
                  onAction: () => _navigateToNextStep(context, speech),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.record_voice_over,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum discurso ainda',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Crie seu primeiro discurso e comece a desenvolver suas habilidades de oratória.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _navigateToNextStep(BuildContext context, Speech speech) {
    Widget destination;

    switch (speech.status) {
      case SpeechStatus.planning:
        destination = OutlineEditorScreen(speech: speech);
      case SpeechStatus.preparing:
        destination = OutlineEditorScreen(speech: speech);
      case SpeechStatus.training:
        destination = TrainingModuleScreen(speech: speech);
      case SpeechStatus.ready:
        destination = StageModeNewScreen(speech: speech);
      case SpeechStatus.executed:
        destination = ImprovementDashboardScreen(initialSpeech: speech);
      case SpeechStatus.archived:
        destination = ImprovementDashboardScreen(initialSpeech: speech);
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination),
    );
  }
}

class _CycleStepCard extends StatelessWidget {
  final int step;
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const _CycleStepCard({
    required this.step,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$step. $title',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeechCard extends StatelessWidget {
  final Speech speech;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onAction;

  const _SpeechCard({
    required this.speech,
    required this.isSelected,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? const BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _getStatusColor(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      speech.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(),
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStatusColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          speech.type == SpeechType.student10min
                              ? '10 min'
                              : '30 min',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getStatusColor(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(_getActionText()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (speech.status) {
      case SpeechStatus.planning:
        return Colors.blue;
      case SpeechStatus.preparing:
        return Colors.orange;
      case SpeechStatus.training:
        return Colors.purple;
      case SpeechStatus.ready:
        return AppTheme.accentColor;
      case SpeechStatus.executed:
        return AppTheme.successColor;
      case SpeechStatus.archived:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (speech.status) {
      case SpeechStatus.planning:
        return Icons.track_changes;
      case SpeechStatus.preparing:
        return Icons.edit_note;
      case SpeechStatus.training:
        return Icons.fitness_center;
      case SpeechStatus.ready:
        return Icons.check_circle;
      case SpeechStatus.executed:
        return Icons.done_all;
      case SpeechStatus.archived:
        return Icons.archive;
    }
  }

  String _getStatusText() {
    switch (speech.status) {
      case SpeechStatus.planning:
        return 'Planejando';
      case SpeechStatus.preparing:
        return 'Preparando';
      case SpeechStatus.training:
        return 'Treinando';
      case SpeechStatus.ready:
        return 'Pronto';
      case SpeechStatus.executed:
        return 'Executado';
      case SpeechStatus.archived:
        return 'Arquivado';
    }
  }

  String _getActionText() {
    switch (speech.status) {
      case SpeechStatus.planning:
        return 'Preparar';
      case SpeechStatus.preparing:
        return 'Editar';
      case SpeechStatus.training:
        return 'Treinar';
      case SpeechStatus.ready:
        return 'Executar';
      case SpeechStatus.executed:
        return 'Ver';
      case SpeechStatus.archived:
        return 'Ver';
    }
  }
}

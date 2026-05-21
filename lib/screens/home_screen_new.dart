import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/speech_provider.dart';
import '../models/speech.dart';
import '../services/characteristics_service.dart';
import '../services/api_service.dart';
import 'planning/speech_planning_screen.dart';
import 'planning/create_outline_screen.dart';
import 'planning/speech_planning_details_screen.dart';
import 'preparation/outline_editor_screen.dart';
import 'training/training_module_screen.dart';
import 'execution/stage_mode_new_screen.dart';
import 'dashboard/improvement_dashboard_screen.dart';
import 'characteristics/characteristics_library_screen.dart';
import 'tools/tools_hub_section.dart';
import 'tools/meeting/meeting_hub_screen.dart';

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
          CreateOutlineScreen(),
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
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Criar Esboço',
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
                const ToolsHubSection(),
                const SizedBox(height: 16),
                _buildWeeklyCommentsCard(context),
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
    return Consumer<SpeechProvider>(
      builder: (context, provider, _) {
        final currentSpeech = provider.currentSpeech;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ciclo de Performance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              currentSpeech == null
                  ? 'Selecione um discurso para usar as etapas.'
                  : 'Discurso em foco: ${currentSpeech.title}',
              style: Theme.of(context).textTheme.bodySmall,
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
                    description: 'Edite objetivo e estrutura do discurso',
                    onTap: () => _openCycleStep(context, 1, currentSpeech),
                  ),
                  _CycleStepCard(
                    step: 2,
                    title: 'Preparar',
                    icon: Icons.edit_note,
                    color: Colors.orange,
                    description: 'Construa esboço com método L.E.I.A.',
                    onTap: () => _openCycleStep(context, 2, currentSpeech),
                  ),
                  _CycleStepCard(
                    step: 3,
                    title: 'Treinar',
                    icon: Icons.fitness_center,
                    color: Colors.purple,
                    description: 'Ensaie com temporizador e checklist',
                    onTap: () => _openCycleStep(context, 3, currentSpeech),
                  ),
                  _CycleStepCard(
                    step: 4,
                    title: 'Executar',
                    icon: Icons.record_voice_over,
                    color: AppTheme.accentColor,
                    description: 'Modo Palco com teleprompter',
                    onTap: () => _openCycleStep(context, 4, currentSpeech),
                  ),
                  _CycleStepCard(
                    step: 5,
                    title: 'Aprimorar',
                    icon: Icons.trending_up,
                    color: AppTheme.secondaryColor,
                    description: 'Notas e observações do discurso',
                    onTap: () => _openCycleStep(context, 5, currentSpeech),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _openCycleStep(BuildContext context, int step, Speech? speech) {
    if (speech == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um discurso para abrir esta etapa.'),
        ),
      );
      return;
    }

    Widget destination;
    switch (step) {
      case 1:
        destination = SpeechPlanningDetailsScreen(speech: speech);
        break;
      case 2:
        destination = OutlineEditorScreen(speech: speech);
        break;
      case 3:
        destination = TrainingModuleScreen(speech: speech);
        break;
      case 4:
        destination = StageModeNewScreen(speech: speech);
        break;
      case 5:
        destination = ImprovementDashboardScreen(initialSpeech: speech);
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination),
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

  Widget _buildWeeklyCommentsCard(BuildContext context) {
    return FutureBuilder<WeeklyCommentsResponse>(
      future: ApiService().getWeeklyComments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Carregando comentarios da semana...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comentarios da semana',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nao foi possivel carregar agora. Verifique a conexao com o backend.',
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return const SizedBox.shrink();
        }

        final preview = data.comentarioTexts.take(2).toList();
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MeetingHubScreen()),
            ),
            child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Comentarios da semana',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  data.semana,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (data.textoJoiaEspiritual.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Joia espiritual: ${data.textoJoiaEspiritual}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 10),
                if (preview.isEmpty)
                  Text(
                    'Sem comentarios cadastrados para esta semana.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  ...preview.map(
                    (comment) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('- $comment'),
                    ),
                  ),
                if (data.comentarioTexts.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Toque para ver todos (${data.comentarioTexts.length})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          ),
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
  final VoidCallback onTap;

  const _CycleStepCard({
    required this.step,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
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

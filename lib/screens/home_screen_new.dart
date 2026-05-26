import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/speech_provider.dart';
import '../models/speech.dart';
import '../services/characteristics_service.dart';
import '../widgets/shell/custom_bottom_nav.dart';
import '../widgets/shell/gradient_background.dart';
import '../widgets/shell/gradient_primary_button.dart';
import '../widgets/shell/home_header.dart';
import '../widgets/shell/performance_cycle_card.dart';
import '../widgets/shell/promo_carousel.dart';
import '../widgets/shell/quick_tools_grid.dart';
import '../widgets/shell/staggered_entrance.dart';
import 'planning/speech_planning_screen.dart';
import 'planning/create_outline_screen.dart';
import 'planning/speech_planning_details_screen.dart';
import 'preparation/outline_editor_screen.dart';
import 'training/training_module_screen.dart';
import 'execution/stage_mode_new_screen.dart';
import 'dashboard/improvement_dashboard_screen.dart';
import 'tools/bet_guide/voice_rehearsal_screen.dart';
import '../widgets/voice_rehearsal_weekly_progress_card.dart';
import 'characteristics/characteristics_library_screen.dart';
import 'tools/discursos/discursos_admin_screen.dart';

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
    return Theme(
      data: AppTheme.shellTheme,
      child: GradientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          drawer: _buildDrawer(context),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: IndexedStack(
              key: ValueKey<int>(_currentIndex),
              index: _currentIndex,
              children: const [
                _HomeTab(),
                CharacteristicsLibraryScreen(),
                ImprovementDashboardScreen(),
                CreateOutlineScreen(),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNav(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.shellSurfaceDark,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: AppTheme.shellBackgroundGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Poder de Convencer',
                    style: TextStyle(
                      color: AppTheme.shellTextPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Método Shinyashiki',
                    style: TextStyle(color: AppTheme.shellTextSecondary),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.record_voice_over,
                  color: AppTheme.shellAccentTeal),
              title: const Text('Discursos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DiscursosAdminScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline,
                  color: AppTheme.shellAccentTeal),
              title: const Text('Sobre'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Poder de Convencer',
                  applicationVersion: '1.0.0',
                  children: const [
                    Text(
                      'App de treinamento em oratória com o método Shinyashiki e as 53 características.',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: StaggeredEntrance(
              index: 0,
              child: const HomeHeader(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StaggeredEntrance(
                    index: 1,
                    child: _buildMethodCycle(context),
                  ),
                  const StaggeredEntrance(
                    index: 2,
                    child: VoiceRehearsalWeeklyProgressCard(),
                  ),
                  const SizedBox(height: 24),
                  const StaggeredEntrance(
                    index: 3,
                    child: QuickToolsGrid(),
                  ),
                  const SizedBox(height: 20),
                  const StaggeredEntrance(
                    index: 4,
                    child: PromoCarousel(),
                  ),
                  const SizedBox(height: 20),
                  StaggeredEntrance(
                    index: 5,
                    child: GradientPrimaryButton(
                      label: 'Novo Discurso',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SpeechPlanningScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  StaggeredEntrance(
                    index: 6,
                    child: _buildSpeechesList(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCycle(BuildContext context) {
    return Consumer<SpeechProvider>(
      builder: (context, provider, _) {
        final currentSpeech = provider.currentSpeech;
        final activeStep = PerformanceCycleCard.activeStepFromStatus(
          currentSpeech?.status,
        );

        final steps = [
          CycleStepData(
            step: 1,
            title: 'Planejar',
            description: 'Defina objetivo e estrutura do discurso',
            onTap: () => _openCycleStep(context, 1, currentSpeech),
          ),
          CycleStepData(
            step: 2,
            title: 'Preparar',
            description: 'Construa esboço com método L.E.I.A.',
            onTap: () => _openCycleStep(context, 2, currentSpeech),
          ),
          CycleStepData(
            step: 3,
            title: 'Treinar',
            description: 'Ensaie com temporizador e checklist',
            onTap: () => _openCycleStep(context, 3, currentSpeech),
          ),
          CycleStepData(
            step: 4,
            title: 'Executar',
            description: 'Modo Palco com teleprompter',
            onTap: () => _openCycleStep(context, 4, currentSpeech),
          ),
          CycleStepData(
            step: 5,
            title: 'Aprimorar',
            description: 'Notas e observações do discurso',
            onTap: () => _openCycleStep(context, 5, currentSpeech),
          ),
        ];

        return PerformanceCycleCard(
          steps: steps,
          activeStep: activeStep,
          focusSpeechTitle: currentSpeech?.title,
          onViewAllSteps: () {
            if (currentSpeech == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selecione um discurso para ver as etapas.'),
                ),
              );
              return;
            }
            _openCycleStep(context, activeStep, currentSpeech);
          },
        );
      },
    );
  }

  void _showTrainingChoice(BuildContext context, Speech speech) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Ensaio be-T'),
              subtitle: const Text('Coach vocal em tempo real'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        VoiceRehearsalScreen(initialSpeech: speech),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Módulo de treino'),
              subtitle: const Text('Temporizador e checklist'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TrainingModuleScreen(speech: speech),
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
        _showTrainingChoice(context, speech);
        return;
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
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.shellAccentTeal),
          );
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
        color: AppTheme.shellSurfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.shellAccentTeal.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.record_voice_over,
            size: 64,
            color: AppTheme.shellTextSecondary.withValues(alpha: 0.6),
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
    final statusColor = _getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.shellSurfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppTheme.shellAccentTeal
              : AppTheme.shellAccentTeal.withValues(alpha: 0.1),
          width: isSelected ? 2 : 1,
        ),
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
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getStatusIcon(), color: statusColor),
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
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(),
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
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
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: statusColor,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
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
        return AppTheme.shellAccentTeal;
      case SpeechStatus.executed:
        return AppTheme.shellAccentGreen;
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

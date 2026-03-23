import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../providers/presentation_provider.dart';
import '../providers/resource_provider.dart';
import '../models/presentation.dart';
import 'planning/planning_wizard_screen.dart';
import 'preparation/message_architecture_screen.dart';
import 'resources/resources_screen.dart';
import 'training/training_screen.dart';
import 'execution/stage_mode_screen.dart';
import 'dashboard/performance_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final presentationProvider = context.read<PresentationProvider>();
    final resourceProvider = context.read<ResourceProvider>();
    await Future.wait([
      presentationProvider.loadPresentations(),
      resourceProvider.loadResources(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _HomeTab(),
          ResourcesScreen(),
          PerformanceDashboardScreen(),
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
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Recursos',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Métricas',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PlanningWizardScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nova Palestra'),
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
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                AppConstants.appTagline,
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
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildPresentationsList(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acesso Rápido',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.play_circle_outline,
                title: 'Treinar',
                color: AppTheme.accentColor,
                onTap: () {
                  final provider = context.read<PresentationProvider>();
                  if (provider.currentPresentation != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TrainingScreen(
                          presentation: provider.currentPresentation!,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selecione uma palestra primeiro'),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.stadium,
                title: 'Modo Palco',
                color: AppTheme.secondaryColor,
                onTap: () {
                  final provider = context.read<PresentationProvider>();
                  if (provider.currentPresentation != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StageModeScreen(
                          presentation: provider.currentPresentation!,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selecione uma palestra primeiro'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresentationsList(BuildContext context) {
    return Consumer<PresentationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.presentations.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suas Palestras',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.presentations.length,
              itemBuilder: (context, index) {
                final presentation = provider.presentations[index];
                return _PresentationCard(
                  presentation: presentation,
                  isSelected:
                      provider.currentPresentation?.id == presentation.id,
                  onTap: () {
                    provider.setCurrentPresentation(presentation);
                  },
                  onEdit: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MessageArchitectureScreen(
                          presentation: presentation,
                        ),
                      ),
                    );
                  },
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
            Icons.mic_none,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma palestra ainda',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Crie sua primeira palestra e comece a transformar sua comunicação em missão.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresentationCard extends StatelessWidget {
  final Presentation presentation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _PresentationCard({
    required this.presentation,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
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
                      presentation.title,
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
                        if (presentation.messageArchitecture != null)
                          Text(
                            '${(presentation.messageArchitecture!.completionPercentage * 100).toInt()}% completo',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (presentation.status) {
      case PresentationStatus.draft:
        return Colors.grey;
      case PresentationStatus.planning:
        return Colors.blue;
      case PresentationStatus.preparing:
        return Colors.orange;
      case PresentationStatus.training:
        return Colors.purple;
      case PresentationStatus.ready:
        return AppTheme.accentColor;
      case PresentationStatus.executed:
        return AppTheme.successColor;
      case PresentationStatus.archived:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (presentation.status) {
      case PresentationStatus.draft:
        return Icons.edit_note;
      case PresentationStatus.planning:
        return Icons.track_changes;
      case PresentationStatus.preparing:
        return Icons.architecture;
      case PresentationStatus.training:
        return Icons.fitness_center;
      case PresentationStatus.ready:
        return Icons.check_circle;
      case PresentationStatus.executed:
        return Icons.done_all;
      case PresentationStatus.archived:
        return Icons.archive;
    }
  }

  String _getStatusText() {
    switch (presentation.status) {
      case PresentationStatus.draft:
        return 'Rascunho';
      case PresentationStatus.planning:
        return 'Planejando';
      case PresentationStatus.preparing:
        return 'Preparando';
      case PresentationStatus.training:
        return 'Treinando';
      case PresentationStatus.ready:
        return 'Pronta';
      case PresentationStatus.executed:
        return 'Executada';
      case PresentationStatus.archived:
        return 'Arquivada';
    }
  }
}

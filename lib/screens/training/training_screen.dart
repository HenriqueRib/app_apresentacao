import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/presentation.dart';
import '../../providers/presentation_provider.dart';

class TrainingScreen extends StatefulWidget {
  final Presentation presentation;

  const TrainingScreen({
    super.key,
    required this.presentation,
  });

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isTimerRunning = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  final Map<String, bool> _stageChecklist = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initChecklist();
  }

  void _initChecklist() {
    for (final item in AppConstants.stageChecklistItems) {
      _stageChecklist[item] = widget.presentation.trainingData
              ?.stageChecklist[item] ??
          false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinamento'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.self_improvement), text: 'Concentração'),
            Tab(icon: Icon(Icons.timer), text: 'Ensaio'),
            Tab(icon: Icon(Icons.checklist), text: 'Checklist'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConcentrationTab(),
          _buildRehearsalTab(),
          _buildChecklistTab(),
        ],
      ),
    );
  }

  Widget _buildConcentrationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.self_improvement,
              size: 100,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Ritual de Concentração',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Antes de treinar, dedique alguns minutos para se concentrar. '
            'Foque no controle do medo e na sua missão.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          _buildMeditationCard(
            title: 'Respiração 4-7-8',
            description: 'Inspire por 4s, segure por 7s, expire por 8s.',
            duration: '3 minutos',
            icon: Icons.air,
          ),
          const SizedBox(height: 16),
          _buildMeditationCard(
            title: 'Visualização de Sucesso',
            description: 'Visualize sua apresentação sendo um sucesso.',
            duration: '5 minutos',
            icon: Icons.visibility,
          ),
          const SizedBox(height: 16),
          _buildMeditationCard(
            title: 'Afirmações de Poder',
            description: 'Repita afirmações positivas sobre sua capacidade.',
            duration: '2 minutos',
            icon: Icons.record_voice_over,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: AppTheme.accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lembre-se: Sua missão é provocar uma ação imediata '
                    'na audiência que resulte em mudança de vida.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationCard({
    required String title,
    required String description,
    required String duration,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            duration,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Iniciando: $title')),
          );
        },
      ),
    );
  }

  Widget _buildRehearsalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTimerDisplay(),
          const SizedBox(height: 32),
          _buildTimerControls(),
          const SizedBox(height: 32),
          _buildEnergyIndicator(),
          const SizedBox(height: 32),
          _buildQuickNotes(),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay() {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    final isOvertime = minutes >= AppConstants.quickPitchDurationMinutes;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isOvertime
            ? AppTheme.warningColor.withValues(alpha: 0.1)
            : AppTheme.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isOvertime ? AppTheme.warningColor : AppTheme.primaryColor,
                ),
          ),
          if (isOvertime)
            Text(
              'Tempo excedido!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningColor,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: _resetTimer,
          icon: const Icon(Icons.refresh),
          iconSize: 32,
        ),
        const SizedBox(width: 24),
        IconButton.filled(
          onPressed: _toggleTimer,
          icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
          iconSize: 48,
          style: IconButton.styleFrom(
            backgroundColor: _isTimerRunning
                ? AppTheme.warningColor
                : AppTheme.accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(20),
          ),
        ),
        const SizedBox(width: 24),
        IconButton.filled(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gravação não disponível')),
            );
          },
          icon: const Icon(Icons.videocam),
          iconSize: 32,
        ),
      ],
    );
  }

  Widget _buildEnergyIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nível de Energia',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Icon(Icons.bolt, color: AppTheme.secondaryColor),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Energia: ${index + 1}/5')),
                      );
                    },
                    child: Container(
                      height: 8,
                      margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: index < 3
                            ? AppTheme.accentColor
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              'Mantenha sua empolgação e contato visual!',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickNotes() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notas Rápidas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Adicione notas sobre pontos críticos...',
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Adicionar nota'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Checklist de Posse de Palco',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Verifique cada item antes de se considerar pronto.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        ...AppConstants.stageChecklistItems.map((item) {
          return _buildChecklistItem(item);
        }),
        const SizedBox(height: 32),
        _buildReadinessIndicator(),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _allChecked ? _markAsReady : null,
            child: const Text('Marcar Palestra como Pronta'),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem(String item) {
    final isChecked = _stageChecklist[item] ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: isChecked,
        onChanged: (value) {
          setState(() {
            _stageChecklist[item] = value ?? false;
          });
        },
        title: Text(
          item,
          style: TextStyle(
            decoration: isChecked ? TextDecoration.lineThrough : null,
            color: isChecked ? Colors.grey : null,
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppTheme.accentColor,
      ),
    );
  }

  Widget _buildReadinessIndicator() {
    final checkedCount = _stageChecklist.values.where((v) => v).length;
    final totalCount = _stageChecklist.length;
    final percentage = totalCount > 0 ? checkedCount / totalCount : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prontidão',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '$checkedCount/$totalCount',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage == 1.0 ? AppTheme.successColor : AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _allChecked =>
      _stageChecklist.values.every((v) => v);

  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });

    if (_isTimerRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _resetTimer() {
    setState(() {
      _isTimerRunning = false;
      _elapsedSeconds = 0;
    });
    _timer?.cancel();
  }

  Future<void> _markAsReady() async {
    final provider = context.read<PresentationProvider>();
    await provider.markAsReady(widget.presentation.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Palestra marcada como pronta!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/speech.dart';
import '../../providers/speech_provider.dart';
import '../../services/characteristics_service.dart';
import '../tools/timer/presentation_timer_pro_screen.dart';

class TrainingModuleScreen extends StatefulWidget {
  final Speech speech;

  const TrainingModuleScreen({super.key, required this.speech});

  @override
  State<TrainingModuleScreen> createState() => _TrainingModuleScreenState();
}

class _TrainingModuleScreenState extends State<TrainingModuleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isTimerRunning = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  double _energyLevel = 3;

  final Map<String, bool> _checklist = {
    'Presença física marcada': false,
    'Movimentação segura': false,
    'Contato visual': false,
    'Independência de notas': false,
    'Entusiasmo na voz': false,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treinamento'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.timer), text: 'Ensaio'),
            Tab(icon: Icon(Icons.description), text: 'Manuscrito'),
            Tab(icon: Icon(Icons.checklist), text: 'Checklist'),
            Tab(icon: Icon(Icons.school), text: 'Características'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRehearsalTab(),
          _buildManuscriptTab(),
          _buildChecklistTab(),
          _buildCharacteristicsTab(),
        ],
      ),
    );
  }

  Widget _buildManuscriptTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.speech.initialComment.isNotEmpty) ...[
          _buildSectionHeader('Comentário Inicial'),
          _buildTextContent(widget.speech.initialComment),
          const SizedBox(height: 16),
        ],
        _buildSectionHeader('Manuscrito Completo'),
        if (widget.speech.completeManuscript.isEmpty)
          _buildEmptyContent('Nenhum manuscrito gerado/inserido.')
        else
          _buildTextContent(widget.speech.completeManuscript, highlight: true),
        const SizedBox(height: 16),
        if (widget.speech.finalComment.isNotEmpty) ...[
          _buildSectionHeader('Comentário Final'),
          _buildTextContent(widget.speech.finalComment),
          const SizedBox(height: 16),
        ],
        const Divider(),
        _buildSectionHeader('Estrutura (Cards)'),
        if (widget.speech.outline?.mainPoints.isEmpty ?? true)
          _buildEmptyContent('Nenhum card de estrutura.')
        else
          ...widget.speech.outline!.mainPoints.map((p) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(p.content),
            ),
          )),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildTextContent(String text, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? AppTheme.primaryColor.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: highlight ? AppTheme.primaryColor.withOpacity(0.2) : Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              fontSize: 16,
            ),
      ),
    );
  }

  Widget _buildEmptyContent(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(message, style: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
      ),
    );
  }

  Widget _buildRehearsalTab() {
    final targetMinutes = widget.speech.durationMinutes;
    final targetSeconds = targetMinutes * 60;
    final isOvertime = _elapsedSeconds > targetSeconds;
    final progress = _elapsedSeconds / targetSeconds;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    widget.speech.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Meta: $targetMinutes minutos',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0, 1),
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOvertime ? AppTheme.errorColor : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            _formatTime(_elapsedSeconds),
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isOvertime ? AppTheme.errorColor : null,
                                ),
                          ),
                          if (isOvertime)
                            Text(
                              '+${_formatTime(_elapsedSeconds - targetSeconds)}',
                              style: const TextStyle(color: AppTheme.errorColor),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.refresh),
                      ),
                      const SizedBox(width: 16),
                      IconButton.filled(
                        onPressed: _toggleTimer,
                        icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
                        iconSize: 48,
                        style: IconButton.styleFrom(
                          backgroundColor: _isTimerRunning
                              ? AppTheme.warningColor
                              : AppTheme.accentColor,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton.filled(
                        onPressed: _saveSession,
                        icon: const Icon(Icons.save),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PresentationTimerProScreen(),
              ),
            ),
            icon: const Icon(Icons.timer),
            label: const Text('Abrir Timer Pro (split + alertas)'),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nível de Energia',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.battery_1_bar, color: Colors.grey),
                      Expanded(
                        child: Slider(
                          value: _energyLevel,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _energyLevel.toInt().toString(),
                          onChanged: (value) {
                            setState(() {
                              _energyLevel = value;
                            });
                          },
                        ),
                      ),
                      const Icon(Icons.bolt, color: AppTheme.secondaryColor),
                    ],
                  ),
                  Text(
                    _getEnergyDescription(),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistTab() {
    final allChecked = _checklist.values.every((v) => v);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Checklist de Posse de Palco',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Verifique cada item durante o ensaio.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        ..._checklist.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: CheckboxListTile(
              value: entry.value,
              onChanged: (value) {
                setState(() {
                  _checklist[entry.key] = value ?? false;
                });
              },
              title: Text(
                entry.key,
                style: TextStyle(
                  decoration: entry.value ? TextDecoration.lineThrough : null,
                ),
              ),
              activeColor: AppTheme.accentColor,
            ),
          );
        }),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Prontidão'),
                    Text(
                      '${_checklist.values.where((v) => v).length}/${_checklist.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _checklist.values.where((v) => v).length /
                      _checklist.length,
                  backgroundColor: Colors.grey.shade200,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: allChecked ? _markAsReady : null,
          child: const Text('Marcar Discurso como Pronto'),
        ),
      ],
    );
  }

  Widget _buildCharacteristicsTab() {
    final focusId = widget.speech.focusCharacteristicId;
    final focusChar = focusId != null
        ? CharacteristicsService.instance.getCharacteristicById(focusId)
        : null;

    final recommended = CharacteristicsService.instance
        .getRecommendedForSpeechType(
            widget.speech.type == SpeechType.public30min);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (focusChar != null) ...[
          Text(
            'Característica em Foco',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        child: Text('${focusChar.id}'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          focusChar.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'O que fazer:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(focusChar.action),
                  const SizedBox(height: 12),
                  Text(
                    'Por que é importante:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(focusChar.importance),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          'Características Recomendadas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...recommended.map((char) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                radius: 16,
                child: Text(
                  '${char.id}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              title: Text(char.title),
              subtitle: Text(char.category),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ação:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(char.action),
                      const SizedBox(height: 8),
                      Text(
                        'Importância:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(char.importance),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getEnergyDescription() {
    switch (_energyLevel.toInt()) {
      case 1:
        return 'Muito baixa - Precisa aumentar o entusiasmo';
      case 2:
        return 'Baixa - Pode melhorar a vivacidade';
      case 3:
        return 'Moderada - Nível aceitável';
      case 4:
        return 'Alta - Boa energia e entusiasmo';
      case 5:
        return 'Excelente - Energia contagiante!';
      default:
        return '';
    }
  }

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

  void _saveSession() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sessão de treino salva!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  Future<void> _markAsReady() async {
    final provider = context.read<SpeechProvider>();
    await provider.markAsReady(widget.speech.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Discurso marcado como pronto!'),
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

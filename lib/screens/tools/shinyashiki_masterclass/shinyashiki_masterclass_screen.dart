import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/masterclass_step.dart';
import '../../../services/masterclass_service.dart';
import 'shinyashiki_step_detail_screen.dart';

class ShinyashikiMasterclassScreen extends StatefulWidget {
  const ShinyashikiMasterclassScreen({super.key});

  @override
  State<ShinyashikiMasterclassScreen> createState() =>
      _ShinyashikiMasterclassScreenState();
}

class _ShinyashikiMasterclassScreenState
    extends State<ShinyashikiMasterclassScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await MasterclassService.instance.loadData();
    if (mounted) setState(() => _loading = false);
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'track_changes':
        return Icons.track_changes;
      case 'edit_note':
        return Icons.edit_note;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'record_voice_over':
        return Icons.record_voice_over;
      case 'trending_up':
        return Icons.trending_up;
      default:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Masterclass Shinyashiki')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final steps = MasterclassService.instance.steps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Masterclass de Impacto'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Os 5 passos para conexão emocional e impacto com o público',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...steps.map((step) => _StepCard(
                step: step,
                icon: _iconFor(step.iconName),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ShinyashikiStepDetailScreen(step: step),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final MasterclassStep step;
  final IconData icon;
  final VoidCallback onTap;

  const _StepCard({
    required this.step,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          child: Text('${step.stepNumber}'),
        ),
        title: Text(
          step.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          step.summary.length > 100
              ? '${step.summary.substring(0, 100)}...'
              : step.summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(icon, color: AppTheme.secondaryColor),
        onTap: onTap,
      ),
    );
  }
}

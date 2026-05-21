import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/masterclass_step.dart';
import '../../../providers/speech_provider.dart';
import '../../planning/speech_planning_details_screen.dart';
import '../../preparation/outline_editor_screen.dart';
import '../../training/training_module_screen.dart';
import '../../execution/stage_mode_new_screen.dart';
import '../../dashboard/improvement_dashboard_screen.dart';
import 'voice_trainer_widget.dart';

class ShinyashikiStepDetailScreen extends StatelessWidget {
  final MasterclassStep step;

  const ShinyashikiStepDetailScreen({super.key, required this.step});

  void _goToCycleStep(BuildContext context, int stepNumber) {
    final speech = context.read<SpeechProvider>().currentSpeech;
    if (speech == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um discurso na aba Início primeiro.'),
        ),
      );
      return;
    }

    Widget destination;
    switch (stepNumber) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Passo ${step.stepNumber}: ${step.title}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            step.summary,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Dicas práticas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...step.tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 20, color: AppTheme.accentColor),
                  const SizedBox(width: 10),
                  Expanded(child: Text(tip)),
                ],
              ),
            ),
          ),
          if (step.hasVoiceTrainer) ...[
            const SizedBox(height: 24),
            const VoiceTrainerWidget(),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _goToCycleStep(context, step.stepNumber),
              icon: const Icon(Icons.arrow_forward),
              label: Text('Ir para etapa "${step.title}" no ciclo'),
            ),
          ),
        ],
      ),
    );
  }
}

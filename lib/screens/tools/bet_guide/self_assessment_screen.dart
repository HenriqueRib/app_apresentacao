import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/self_assessment_record.dart';
import '../../../providers/oratory_guide_provider.dart';
import '../../../services/characteristics_service.dart';
import 'assessment_history_screen.dart';

class SelfAssessmentScreen extends StatefulWidget {
  const SelfAssessmentScreen({super.key});

  @override
  State<SelfAssessmentScreen> createState() => _SelfAssessmentScreenState();
}

class _SelfAssessmentScreenState extends State<SelfAssessmentScreen> {
  final Map<int, AssessmentLevel> _scores = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OratoryGuideProvider>().load();
    });
  }

  Future<void> _save() async {
    final chars = CharacteristicsService.instance.allCharacteristics;
    final scores = chars
        .map(
          (c) => CharacteristicScore(
            characteristicId: c.id,
            level: _scores[c.id] ?? AssessmentLevel.notYet,
          ),
        )
        .toList();

    await context.read<OratoryGuideProvider>().saveAssessment(scores: scores);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Autoavaliação salva no histórico.')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AssessmentHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chars = CharacteristicsService.instance.allCharacteristics;
    final competencies = CharacteristicsService.instance.allCompetencies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Autoavaliação be-T'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AssessmentHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (competencies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Competências de referência',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      ...competencies.map((c) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  c.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: c.weight / 100,
                                  backgroundColor: Colors.grey.shade200,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${c.weight.toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: chars.length,
              itemBuilder: (context, index) {
                final char = chars[index];
                final level = _scores[char.id] ?? AssessmentLevel.notYet;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${char.id}. ${char.title}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<AssessmentLevel>(
                          segments: const [
                            ButtonSegment(
                              value: AssessmentLevel.notYet,
                              label: Text('Não', style: TextStyle(fontSize: 11)),
                            ),
                            ButtonSegment(
                              value: AssessmentLevel.partial,
                              label:
                                  Text('Parcial', style: TextStyle(fontSize: 11)),
                            ),
                            ButtonSegment(
                              value: AssessmentLevel.yes,
                              label: Text('Sim', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                          selected: {level},
                          onSelectionChanged: (selected) {
                            setState(() {
                              _scores[char.id] = selected.first;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Salvar autoavaliação'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

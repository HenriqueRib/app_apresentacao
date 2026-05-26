import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/oratory_characteristic.dart';
import '../../../models/self_assessment_record.dart';
import '../../../providers/oratory_guide_provider.dart';
import '../../../services/characteristics_service.dart';
import 'assessment_history_screen.dart';

class SelfAssessmentScreen extends StatefulWidget {
  final int? focusCharacteristicId;
  final List<int>? highlightCharacteristicIds;

  const SelfAssessmentScreen({
    super.key,
    this.focusCharacteristicId,
    this.highlightCharacteristicIds,
  });

  @override
  State<SelfAssessmentScreen> createState() => _SelfAssessmentScreenState();
}

class _SelfAssessmentScreenState extends State<SelfAssessmentScreen> {
  final Map<int, AssessmentLevel> _scores = {};
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    for (final id in widget.highlightCharacteristicIds ?? const []) {
      _scores[id] = AssessmentLevel.partial;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OratoryGuideProvider>().load();
      _scrollToFocus();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFocus() {
    final focusId = widget.focusCharacteristicId ??
        (widget.highlightCharacteristicIds?.isNotEmpty == true
            ? widget.highlightCharacteristicIds!.first
            : null);
    if (focusId == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _itemKeys[focusId];
      final context = key?.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );
      }
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
    final focusId = widget.focusCharacteristicId;
    final highlightIds = {
      ...?widget.highlightCharacteristicIds,
      if (focusId != null) focusId,
    };
    OratoryCharacteristic? focusChar;
    if (focusId != null) {
      focusChar = CharacteristicsService.instance.getCharacteristicById(focusId);
    }

    for (final c in chars) {
      _itemKeys.putIfAbsent(c.id, () => GlobalKey());
    }

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
          if (highlightIds.isNotEmpty)
            Container(
              width: double.infinity,
              color: AppTheme.warningColor.withValues(alpha: 0.12),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.mic, color: AppTheme.warningColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlightIds.length == 1 && focusChar != null
                          ? 'Detectado no ensaio — avalie: #${focusChar.id} ${focusChar.title}'
                          : 'Do ensaio — priorize avaliar: '
                              '${highlightIds.map((id) => '#$id').join(', ')}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: chars.length,
              itemBuilder: (context, index) {
                final char = chars[index];
                final level = _scores[char.id] ?? AssessmentLevel.notYet;
                final isFocus = highlightIds.contains(char.id);
                return Card(
                  key: _itemKeys[char.id],
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: isFocus
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppTheme.warningColor,
                            width: 2,
                          ),
                        )
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${char.id}. ${char.title}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isFocus)
                              Chip(
                                label: const Text(
                                  'Foco',
                                  style: TextStyle(fontSize: 10),
                                ),
                                visualDensity: VisualDensity.compact,
                                backgroundColor:
                                    AppTheme.warningColor.withValues(alpha: 0.2),
                              ),
                          ],
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

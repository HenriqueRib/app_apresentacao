import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/self_assessment_record.dart';
import '../../../providers/oratory_guide_provider.dart';

class AssessmentHistoryScreen extends StatefulWidget {
  const AssessmentHistoryScreen({super.key});

  @override
  State<AssessmentHistoryScreen> createState() =>
      _AssessmentHistoryScreenState();
}

class _AssessmentHistoryScreenState extends State<AssessmentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OratoryGuideProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de autoavaliações')),
      body: Consumer<OratoryGuideProvider>(
        builder: (context, provider, _) {
          if (provider.records.isEmpty) {
            return const Center(
              child: Text('Nenhuma autoavaliação registrada ainda.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.records.length,
            itemBuilder: (context, index) {
              final record = provider.records[index];
              final yes = record.countLevel(AssessmentLevel.yes);
              final partial = record.countLevel(AssessmentLevel.partial);
              final notYet = record.countLevel(AssessmentLevel.notYet);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    child: Text('${record.scores.length}'),
                  ),
                  title: Text(_formatDate(record.completedAt)),
                  subtitle: Text(
                    'Sim: $yes · Parcial: $partial · Não: $notYet',
                  ),
                  isThreeLine: record.speechTitle != null,
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

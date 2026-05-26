import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:palestrante_de_sucesso/models/voice_rehearsal.dart';
import 'package:palestrante_de_sucesso/models/voice_rehearsal_attempt.dart';
import 'package:palestrante_de_sucesso/services/voice_rehearsal_report_exporter.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  test('exports plain text with score and title', () {
    final attempt = VoiceRehearsalAttempt(
      id: '1',
      createdAt: DateTime(2026, 3, 1, 14, 30),
      mode: VoiceSessionMode.training,
      durationSeconds: 240,
      finalScore: 7.5,
      topic: 'Parte sobre fé',
      subjectPreview: 'Parte sobre fé',
      seriesName: 'Março',
      summary: const VoiceRehearsalSummary(
        metrics: VoiceRehearsalMetrics(
          wordCount: 100,
          wpm: 120,
          fillerCount: 2,
          liveScore: 7.5,
        ),
        events: [],
        characteristicScores: {},
        insights: [
          VoiceImprovementInsight(
            category: 'muleta',
            message: 'Muitas muletas',
            suggestion: 'Pause',
          ),
        ],
      ),
    );

    final text = VoiceRehearsalReportExporter.toPlainText(attempt);
    expect(text, contains('7.5'));
    expect(text, contains('Parte sobre fé'));
    expect(text, contains('Março'));
    expect(text, contains('Muitas muletas'));
  });
}

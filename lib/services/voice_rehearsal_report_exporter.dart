import '../models/voice_rehearsal_attempt.dart';
import '../utils/voice_rehearsal_ui.dart';

class VoiceRehearsalReportExporter {
  static String toPlainText(VoiceRehearsalAttempt attempt) {
    final m = attempt.summary.metrics;
    final buffer = StringBuffer();

    buffer.writeln('Ensaio be-T — Relatório');
    buffer.writeln(attempt.listTitle);
    buffer.writeln(formatVoiceRehearsalDateTime(attempt.createdAt));
    buffer.writeln(
      '${attempt.modeLabel} · ${_formatDuration(attempt.durationSeconds)}',
    );
    if (attempt.seriesName != null && attempt.seriesName!.trim().isNotEmpty) {
      buffer.writeln('Série: ${attempt.seriesName}');
    }
    buffer.writeln();
    buffer.writeln('Nota: ${attempt.finalScore.toStringAsFixed(1)}/10');
    buffer.writeln('WPM: ${m.wpm > 0 ? m.wpm.toStringAsFixed(0) : "—"}');
    buffer.writeln('Palavras: ${m.wordCount}');
    buffer.writeln('Muletas: ${m.fillerCount}');
    buffer.writeln('Pausas longas: ${m.longPauseCount}');
    buffer.writeln();

    final insights = List.of(attempt.summary.insights)
      ..sort((a, b) => b.severityRank.compareTo(a.severityRank));
    if (insights.isNotEmpty) {
      buffer.writeln('Principais dicas:');
      for (final i in insights.take(3)) {
        buffer.writeln('• ${i.message}');
        if (i.suggestion.isNotEmpty) {
          buffer.writeln('  → ${i.suggestion}');
        }
      }
      buffer.writeln();
    }

    final transcript = attempt.summary.formattedTranscript.trim().isNotEmpty
        ? attempt.summary.formattedTranscript
        : attempt.summary.fullTranscript;
    if (transcript.trim().isNotEmpty) {
      buffer.writeln('Transcrição (trecho):');
      final excerpt = transcript.length > 800
          ? '${transcript.substring(0, 800)}…'
          : transcript;
      buffer.writeln(excerpt);
    }

    buffer.writeln();
    buffer.writeln('Gerado pelo app Palestrante de Sucesso.');
    return buffer.toString();
  }

  static String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

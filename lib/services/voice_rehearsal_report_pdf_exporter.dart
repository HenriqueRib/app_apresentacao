import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/voice_rehearsal_attempt.dart';
import 'voice_rehearsal_report_exporter.dart';

class VoiceRehearsalReportPdfExporter {
  static Future<File> writeToTempFile(VoiceRehearsalAttempt attempt) async {
    final plain = VoiceRehearsalReportExporter.toPlainText(attempt);
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Ensaio be-T — Relatório',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          ...plain.split('\n').map(
                (line) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(
                    line,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              ),
        ],
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/ensaio_${attempt.id}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }
}

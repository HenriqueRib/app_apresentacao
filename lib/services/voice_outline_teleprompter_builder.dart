import '../models/speech.dart';
import '../models/voice_teleprompter_section.dart';

class VoiceOutlineTeleprompterBuilder {
  static List<VoiceTeleprompterSection> fromOutline(SpeechOutline? outline) {
    if (outline == null) return const [];

    final sections = <VoiceTeleprompterSection>[];

    if (outline.introduction.trim().isNotEmpty) {
      sections.add(VoiceTeleprompterSection(
        title: 'Introdução',
        body: outline.introduction.trim(),
      ));
    }

    for (var i = 0; i < outline.mainPoints.length; i++) {
      final point = outline.mainPoints[i];
      final body = [
        if (point.content.trim().isNotEmpty) point.content.trim(),
        ...point.arguments.where((a) => a.trim().isNotEmpty),
      ].join('\n\n');
      if (body.isEmpty && point.title.trim().isEmpty) continue;
      sections.add(VoiceTeleprompterSection(
        title: point.title.trim().isNotEmpty
            ? point.title.trim()
            : 'Ponto ${i + 1}',
        body: body.isNotEmpty ? body : point.title.trim(),
      ));
    }

    if (outline.conclusion.trim().isNotEmpty) {
      sections.add(VoiceTeleprompterSection(
        title: 'Conclusão',
        body: outline.conclusion.trim(),
      ));
    }

    return sections;
  }
}

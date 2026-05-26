import '../models/voice_teleprompter_section.dart';

class VoiceOutlineCoverageResult {
  final double percent;
  final int matched;
  final int total;
  final List<String> missing;

  const VoiceOutlineCoverageResult({
    required this.percent,
    required this.matched,
    required this.total,
    this.missing = const [],
  });
}

/// Heurística local: % de títulos/palavras-chave do esboço citados na transcrição.
class VoiceOutlineCoverageAnalyzer {
  static const _stopwords = {
    'para', 'como', 'mais', 'muito', 'sobre', 'quando', 'porque', 'porquê',
    'também', 'ainda', 'assim', 'com', 'sem', 'uma', 'uns', 'umas', 'the',
    'that', 'this', 'from', 'have', 'will', 'your', 'their', 'they', 'them',
    'de', 'da', 'do', 'das', 'dos', 'em', 'no', 'na', 'nos', 'nas', 'um',
    'que', 'por', 'se', 'ao', 'aos', 'à', 'às', 'ou', 'ser', 'são', 'foi',
    'será', 'mas', 'não', 'sim', 'já', 'até', 'entre', 'isso', 'essa',
    'esse', 'este', 'esta', 'aqui', 'ali', 'onde', 'quem', 'qual', 'quais',
  };

  static VoiceOutlineCoverageResult analyze({
    required List<VoiceTeleprompterSection> sections,
    required String transcript,
  }) {
    if (sections.isEmpty || transcript.trim().isEmpty) {
      return const VoiceOutlineCoverageResult(
        percent: 0,
        matched: 0,
        total: 0,
      );
    }

    final keywords = <String>{};
    for (final section in sections) {
      keywords.addAll(_keywordsFromTitle(section.title));
      keywords.addAll(_keywordsFromBody(section.body));
    }

    if (keywords.isEmpty) {
      return const VoiceOutlineCoverageResult(
        percent: 0,
        matched: 0,
        total: 0,
      );
    }

    final normalizedTranscript = _normalize(transcript);
    final missing = <String>[];
    var matched = 0;

    for (final keyword in keywords) {
      if (_containsKeyword(normalizedTranscript, keyword)) {
        matched++;
      } else {
        missing.add(keyword);
      }
    }

    final total = keywords.length;
    final percent = total > 0 ? (matched / total) * 100 : 0.0;

    return VoiceOutlineCoverageResult(
      percent: percent,
      matched: matched,
      total: total,
      missing: missing.take(8).toList(),
    );
  }

  static Iterable<String> _keywordsFromTitle(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return const [];
    final words = _significantWords(trimmed);
    if (words.isEmpty) return [trimmed.toLowerCase()];
    return {...words, trimmed.toLowerCase()};
  }

  static Iterable<String> _keywordsFromBody(String body) {
    return _significantWords(body).take(12);
  }

  static List<String> _significantWords(String text) {
    final raw = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 4 && !_stopwords.contains(w))
        .toList();
    return raw.toSet().toList();
  }

  static String _normalize(String text) =>
      text.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  static bool _containsKeyword(String normalizedTranscript, String keyword) {
    final k = _normalize(keyword);
    if (k.isEmpty) return false;
    if (k.contains(' ')) {
      return normalizedTranscript.contains(k);
    }
    final pattern = RegExp(r'(?:^|\s)' + RegExp.escape(k) + r'(?:\s|[,.!?;:]|$)');
    return pattern.hasMatch(normalizedTranscript);
  }
}

/// Heurísticas locais para tema e prévia do assunto falado no ensaio.
class VoiceRehearsalTopicHelper {
  static const _stopWords = {
    'de', 'da', 'do', 'e', 'o', 'a', 'que', 'em', 'um', 'uma',
    'para', 'com', 'não', 'se', 'na', 'no', 'por', 'mais', 'as',
    'os', 'dos', 'das', 'ao', 'aos', 'à', 'às', 'eu', 'ele', 'ela',
    'é', 'então', 'tipo', 'né', 'aí',
  };

  static const _maxPreviewLength = 120;

  /// Título para lista: tema do usuário ou trecho da transcrição.
  static String buildListTitle({
    String? userTopic,
    required String transcript,
  }) {
    final topic = userTopic?.trim();
    if (topic != null && topic.isNotEmpty) return topic;
    return _truncateTranscript(transcript);
  }

  /// Prévia do assunto (pode incluir palavras-chave quando sem tema).
  static String buildSubjectPreview({
    String? userTopic,
    required String transcript,
  }) {
    final topic = userTopic?.trim();
    if (topic != null && topic.isNotEmpty) {
      final excerpt = _truncateTranscript(transcript, maxLen: 80);
      if (excerpt == 'Ensaio sem transcrição') return topic;
      return '$topic — $excerpt';
    }
    return _truncateTranscript(transcript);
  }

  /// Palavras mais frequentes no discurso (para subtítulo opcional).
  static List<String> topKeywords(String transcript, {int limit = 3}) {
    final words = transcript
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !_stopWords.contains(w))
        .toList();

    final freq = <String, int>{};
    for (final w in words) {
      freq[w] = (freq[w] ?? 0) + 1;
    }

    final sorted = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((e) => e.key).toList();
  }

  static String _truncateTranscript(String transcript, {int? maxLen}) {
    final max = maxLen ?? _maxPreviewLength;
    final trimmed = transcript.trim();
    if (trimmed.isEmpty) return 'Ensaio sem transcrição';

    if (trimmed.length <= max) return trimmed;

    final cut = trimmed.substring(0, max);
    final lastSpace = cut.lastIndexOf(' ');
    if (lastSpace > 40) {
      return '${cut.substring(0, lastSpace).trim()}…';
    }
    return '$cut…';
  }
}

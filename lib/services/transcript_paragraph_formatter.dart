/// Formata transcrição bruta em parágrafos legíveis.
class TranscriptParagraphFormatter {
  static const _maxParagraphChars = 280;
  static const _minParagraphChars = 80;

  /// Agrupa por pontuação de fim de frase e limite de caracteres.
  /// [pauseBreakIndices] — índices de palavra após pausas longas (opcional).
  static String format(
    String rawTranscript, {
    List<int> pauseBreakIndices = const [],
  }) {
    final trimmed = rawTranscript.trim();
    if (trimmed.isEmpty) return '';

    final sentences = _splitSentences(trimmed);
    if (sentences.isEmpty) return trimmed;

    final paragraphs = <String>[];
    final buffer = StringBuffer();

    for (var i = 0; i < sentences.length; i++) {
      final sentence = sentences[i].trim();
      if (sentence.isEmpty) continue;

      final wordIndex = _wordIndexBefore(sentences, i);
      final forceBreak = pauseBreakIndices.contains(wordIndex);

      if (buffer.isNotEmpty &&
          (forceBreak ||
              buffer.length + sentence.length + 1 > _maxParagraphChars)) {
        paragraphs.add(buffer.toString().trim());
        buffer.clear();
      }

      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(sentence);

      if (buffer.length >= _minParagraphChars &&
          _endsSentence(sentence) &&
          !forceBreak) {
        paragraphs.add(buffer.toString().trim());
        buffer.clear();
      }
    }

    if (buffer.isNotEmpty) {
      paragraphs.add(buffer.toString().trim());
    }

    return paragraphs.join('\n\n');
  }

  static List<String> _splitSentences(String text) {
    final parts = text.split(RegExp(r'(?<=[.!?…])\s+'));
  if (parts.length == 1 && !text.contains(RegExp(r'[.!?…]'))) {
      return _chunkByLength(text);
    }
    return parts.where((p) => p.trim().isNotEmpty).toList();
  }

  static List<String> _chunkByLength(String text) {
    final words = text.split(RegExp(r'\s+'));
    final chunks = <String>[];
    final buffer = StringBuffer();
    for (final word in words) {
      if (buffer.length + word.length + 1 > _maxParagraphChars &&
          buffer.isNotEmpty) {
        chunks.add(buffer.toString().trim());
        buffer.clear();
      }
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(word);
    }
    if (buffer.isNotEmpty) chunks.add(buffer.toString().trim());
    return chunks;
  }

  static bool _endsSentence(String sentence) =>
      RegExp(r'[.!?…]$').hasMatch(sentence.trim());

  static int _wordIndexBefore(List<String> sentences, int sentenceIndex) {
    var count = 0;
    for (var i = 0; i < sentenceIndex; i++) {
      count += sentences[i].split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    }
    return count;
  }
}

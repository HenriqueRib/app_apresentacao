/// Muletas padrão e personalizadas do Ensaio be-T.
class VoiceFillerWordsService {
  static const defaultFillers = {
    'é',
    'então',
    'tipo',
    'né',
    'aí',
    'hum',
    'ah',
    'hm',
    'hmm',
    'enfim',
  };

  static Set<String> effectiveFillers(Set<String> custom) {
    return {...defaultFillers, ...custom.map((w) => w.toLowerCase().trim())}
        .where((w) => w.isNotEmpty)
        .toSet();
  }

  static Set<String> normalizeCustom(Iterable<String> words) {
    return words
        .map((w) => w.toLowerCase().trim())
        .where((w) => w.isNotEmpty && !defaultFillers.contains(w))
        .toSet();
  }

  static List<String> addCustom(List<String> current, String word) {
    final normalized = word.toLowerCase().trim();
    if (normalized.isEmpty || defaultFillers.contains(normalized)) {
      return List.from(current);
    }
    final set = {...current.map((w) => w.toLowerCase()), normalized};
    return set.toList()..sort();
  }

  static List<String> removeCustom(List<String> current, String word) {
    final normalized = word.toLowerCase().trim();
    return current.where((w) => w.toLowerCase() != normalized).toList();
  }
}

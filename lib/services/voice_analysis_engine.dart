import 'dart:math';

import '../models/voice_rehearsal.dart';
import 'transcript_paragraph_formatter.dart';
import 'voice_coaching_builder.dart';
import 'voice_filler_words_service.dart';
import 'voice_speech_structure_analyzer.dart';

/// Limiares centralizados para heurísticas locais de voz.
class VoiceAnalysisThresholds {
  static const fillerRatioWarning = 0.08;
  static const longPauseSeconds = 4.0;
  static const longPausesPerMinuteWarning = 3;
  static const volumeLowDb = -35.0;
  static const volumeHighDb = -10.0;
  static const silenceDb = -45.0;
  static const modulationMinVariance = 2.5;
  static const wpmLow = 90.0;
  static const wpmHigh = 170.0;
  static const alertDebounceSeconds = 20;
  static const minWordsForWpm = 5;
  static const minSecondsForAnalysis = 10;
  static const repetitionMinCount = 4;
  static const repetitionMinRatio = 0.05;
  static const topWordRatioPenalty = 0.08;

  /// Intervalo entre análises pesadas (insights, score completo).
  static const heavyAnalysisInterval = Duration(milliseconds: 2500);

  /// A cada N amostras de volume roda detecção de alertas (≈600 ms no gravador).
  static const amplitudeHeavyEveryNSamples = 3;
}

/// Motor puro de análise vocal — sem dependências Flutter.
class VoiceAnalysisEngine {
  VoiceRehearsalMetrics _metrics = const VoiceRehearsalMetrics();
  final List<VoiceFeedbackEvent> _events = [];
  final Map<int, DateTime> _lastAlertByChar = {};
  final List<double> _amplitudeSamples = [];
  final List<DateTime> _longPauseTimestamps = [];
  final Map<String, int> _wordFrequency = {};
  final Map<String, int> _fillerByWord = {};
  final Map<String, int> _vagueByWord = {};

  String _lastTranscript = '';
  String _fullTranscript = '';
  int _lowConfidenceSegments = 0;
  DateTime? _silenceStart;
  DateTime _sessionStart = DateTime.now();
  double _liveScore = 0.0;
  double _strategicPauseBonus = 0;
  List<ScoreBreakdownItem> _lastBreakdown = [];
  List<VoiceImprovementInsight> _insights = [];
  DateTime? _lastTranscriptHeavyAt;
  int _amplitudeSamplesSinceHeavy = 0;

  VoiceRehearsalMetrics get metrics => _metrics;
  List<VoiceFeedbackEvent> get events => List.unmodifiable(_events);
  double get liveScore => _liveScore;
  List<VoiceImprovementInsight> get insights =>
      List.unmodifiable(_insights);
  String get fullTranscript => _fullTranscript;

  static final Set<String> _defaultFillerWords =
      VoiceFillerWordsService.defaultFillers;
  Set<String> _fillerWords = _defaultFillerWords;

  void setFillerWords(Set<String> words) {
    _fillerWords = words.isEmpty ? _defaultFillerWords : words;
  }

  static const _vagueWords = {
    'coisa',
    'coisas',
    'negócio',
    'negocios',
    'negócios',
    'tal',
  };

  static const _stopWords = {
    'de', 'da', 'do', 'e', 'o', 'a', 'que', 'em', 'um', 'uma',
    'para', 'com', 'não', 'se', 'na', 'no', 'por', 'mais', 'as',
    'os', 'dos', 'das', 'ao', 'aos', 'à', 'às', 'eu', 'ele', 'ela',
  };

  void reset() {
    _metrics = const VoiceRehearsalMetrics();
    _events.clear();
    _lastAlertByChar.clear();
    _amplitudeSamples.clear();
    _longPauseTimestamps.clear();
    _wordFrequency.clear();
    _fillerByWord.clear();
    _vagueByWord.clear();
    _lastTranscript = '';
    _fullTranscript = '';
    _lowConfidenceSegments = 0;
    _silenceStart = null;
    _sessionStart = DateTime.now();
    _liveScore = 0.0;
    _strategicPauseBonus = 0;
    _lastBreakdown = [];
    _insights = [];
    _lastTranscriptHeavyAt = null;
    _amplitudeSamplesSinceHeavy = 0;
  }

  /// Restaura estado parcial a partir de checkpoint.
  void restoreFromCheckpoint({
    required int elapsedSeconds,
    required String transcript,
    required double liveScore,
    required List<VoiceFeedbackEvent> events,
  }) {
    _elapsedOffset = elapsedSeconds;
    _fullTranscript = transcript;
    _lastTranscript = transcript;
    _liveScore = liveScore;
    _events.addAll(events);
    _rebuildWordStatsFromTranscript(transcript);
    _metrics = _metrics.copyWith(
      elapsedSeconds: elapsedSeconds,
      liveScore: liveScore,
      wordCount: _tokenize(transcript).length,
    );
  }

  int _elapsedOffset = 0;

  /// Atualiza amostras e média de volume sem emitir alertas (UI ao vivo).
  void recordAmplitudeSample(double currentDb) {
    _amplitudeSamples.add(currentDb);
    if (_amplitudeSamples.length > 300) {
      _amplitudeSamples.removeAt(0);
    }
    final avg = _amplitudeSamples.isEmpty
        ? 0.0
        : _amplitudeSamples.reduce((a, b) => a + b) / _amplitudeSamples.length;
    final variance = _computeVariance(_amplitudeSamples);
    _metrics = _metrics.copyWith(
      avgAmplitudeDb: avg,
      amplitudeVariance: variance,
    );
  }

  List<VoiceFeedbackEvent> onAmplitude(double currentDb) {
    final now = DateTime.now();
    recordAmplitudeSample(currentDb);

    _amplitudeSamplesSinceHeavy++;
    if (_amplitudeSamplesSinceHeavy <
        VoiceAnalysisThresholds.amplitudeHeavyEveryNSamples) {
      return const [];
    }
    _amplitudeSamplesSinceHeavy = 0;

    final avg = _metrics.avgAmplitudeDb;
    final variance = _metrics.amplitudeVariance;
    final newEvents = <VoiceFeedbackEvent>[];

    if (currentDb < VoiceAnalysisThresholds.silenceDb) {
      _silenceStart ??= now;
    } else if (_silenceStart != null) {
      final pauseDuration = now.difference(_silenceStart!).inSeconds;
      if (pauseDuration >= VoiceAnalysisThresholds.longPauseSeconds) {
        _longPauseTimestamps.add(now);
        _metrics = _metrics.copyWith(
          longPauseCount: _metrics.longPauseCount + 1,
        );
        if (pauseDuration <= 8 && _strategicPauseBonus < 0.5) {
          _strategicPauseBonus += 0.2;
          final event = _tryEmit(
            5,
            'Boa pausa estratégica (${pauseDuration}s) — destaque ideias importantes.',
            VoiceFeedbackSeverity.positive,
            now,
          );
          if (event != null) newEvents.add(event);
        }
      }
      _silenceStart = null;
    }

    if (_amplitudeSamples.length >= 10) {
      if (avg < VoiceAnalysisThresholds.volumeLowDb) {
        final event = _tryEmit(
          8,
          'Volume médio ${avg.toStringAsFixed(0)} dB — fale mais alto.',
          VoiceFeedbackSeverity.warning,
          now,
        );
        if (event != null) newEvents.add(event);
      } else if (avg > VoiceAnalysisThresholds.volumeHighDb) {
        final event = _tryEmit(
          8,
          'Volume médio ${avg.toStringAsFixed(0)} dB — modere a intensidade.',
          VoiceFeedbackSeverity.warning,
          now,
        );
        if (event != null) newEvents.add(event);
      }
    }

    if (_amplitudeSamples.length >= 30) {
      final recent = _amplitudeSamples.length > 150
          ? _amplitudeSamples.sublist(_amplitudeSamples.length - 150)
          : _amplitudeSamples;
      final recentVariance = _computeVariance(recent);
      if (recentVariance < VoiceAnalysisThresholds.modulationMinVariance) {
        final event = _tryEmit(
          9,
          'Voz monótona — varie tom e ritmo conforme o sentido.',
          VoiceFeedbackSeverity.warning,
          now,
        );
        if (event != null) newEvents.add(event);
      }
    }

    _pruneOldPauses(now);
    if (_longPauseTimestamps.length >=
        VoiceAnalysisThresholds.longPausesPerMinuteWarning) {
      final event = _tryEmit(
        4,
        'Muitas pausas longas (${_longPauseTimestamps.length} no último minuto) — trabalhe a fluência.',
        VoiceFeedbackSeverity.warning,
        now,
      );
      if (event != null) newEvents.add(event);
    }

    if (_amplitudeSamples.length >= 20) {
      final volumeOk = avg >= VoiceAnalysisThresholds.volumeLowDb &&
          avg <= VoiceAnalysisThresholds.volumeHighDb;
      final modulationOk =
          variance >= VoiceAnalysisThresholds.modulationMinVariance;
      if (volumeOk && modulationOk) {
        final event = _tryEmit(
          29,
          'Boa qualidade vocal — volume e modulação adequados.',
          VoiceFeedbackSeverity.positive,
          now,
        );
        if (event != null) newEvents.add(event);
      }
    }

    _events.addAll(newEvents);
    _recalculateScore();
    return newEvents;
  }

  List<VoiceFeedbackEvent> onTranscript(String text, {double? confidence}) {
    final now = DateTime.now();
    if (text == _lastTranscript) return [];

    _syncTranscriptWords(text);
    final wordCount =
        _wordFrequency.values.fold<int>(0, (sum, n) => sum + n);

    final fillerCount = _fillerByWord.values.fold(0, (a, b) => a + b);
    final vagueCount = _vagueByWord.values.fold(0, (a, b) => a + b);

    final elapsed = _elapsedOffset +
        now.difference(_sessionStart).inSeconds;
    final wpm = elapsed > 0 ? (wordCount / elapsed) * 60 : 0.0;

    _metrics = _metrics.copyWith(
      wordCount: wordCount,
      wpm: wpm,
      fillerCount: fillerCount,
      vagueWordCount: vagueCount,
      elapsedSeconds: elapsed,
    );

    final newEvents = <VoiceFeedbackEvent>[];

    if (wordCount > 0) {
      final fillerRatio = fillerCount / wordCount;
      if (fillerRatio > VoiceAnalysisThresholds.fillerRatioWarning) {
        final topFiller = _topEntry(_fillerByWord);
        final detail = topFiller != null
            ? " Muleta mais usada: '${topFiller.key}' (${topFiller.value}x)."
            : '';
        final event = _tryEmit(
          4,
          'Muletas: ${(fillerRatio * 100).toStringAsFixed(0)}% das palavras.$detail',
          VoiceFeedbackSeverity.warning,
          now,
        );
        if (event != null) newEvents.add(event);
      }
    }

    for (final entry in _fillerByWord.entries) {
      if (entry.value >= 3) {
        final event = _tryEmit(
          4,
          "Muleta '${entry.key}' usada ${entry.value} vezes — substitua por pausa.",
          VoiceFeedbackSeverity.warning,
          now,
        );
        if (event != null) newEvents.add(event);
      }
    }

    for (final entry in _vagueByWord.entries) {
      if (entry.value >= 2) {
        final event = _tryEmit(
          24,
          "Palavra vaga '${entry.key}' repetida ${entry.value} vezes — seja mais preciso.",
          VoiceFeedbackSeverity.warning,
          now,
        );
        if (event != null) newEvents.add(event);
      }
    }

    for (final entry in _getRepetitionOffenders(wordCount)) {
      final pct = (entry.ratio(wordCount) * 100).toStringAsFixed(0);
      final event = _tryEmit(
        4,
        "Repetiu '${entry.word}' ${entry.count} vezes ($pct%) — varie a formulação.",
        VoiceFeedbackSeverity.warning,
        now,
      );
      if (event != null) newEvents.add(event);
    }

    if (confidence != null && confidence < 0.5 && wordCount <= 3) {
      _lowConfidenceSegments++;
      if (_lowConfidenceSegments >= 2) {
        final event = _tryEmit(
          2,
          'Articule melhor — abra a boca e pronuncie sílabas distintas.',
          VoiceFeedbackSeverity.warning,
          now,
        );
        if (event != null) newEvents.add(event);
      }
    }

    if (elapsed >= VoiceAnalysisThresholds.minSecondsForAnalysis &&
        wordCount >= VoiceAnalysisThresholds.minWordsForWpm) {
      if (wpm < VoiceAnalysisThresholds.wpmLow) {
        final event = _tryEmit(
          28,
          'Ritmo: ${wpm.toStringAsFixed(0)} WPM (ideal: 90–170) — acelere levemente.',
          VoiceFeedbackSeverity.warning,
          now,
        );
        if (event != null) newEvents.add(event);
      } else if (wpm > VoiceAnalysisThresholds.wpmHigh) {
        final event = _tryEmit(
          28,
          'Ritmo: ${wpm.toStringAsFixed(0)} WPM (ideal: 90–170) — desacelere.',
          VoiceFeedbackSeverity.warning,
          now,
        );
        if (event != null) newEvents.add(event);
      }
    }

    _events.addAll(newEvents);

    final runHeavy = _lastTranscriptHeavyAt == null ||
        now.difference(_lastTranscriptHeavyAt!) >=
            VoiceAnalysisThresholds.heavyAnalysisInterval ||
        newEvents.isNotEmpty;
    if (runHeavy) {
      _lastTranscriptHeavyAt = now;
      _recalculateScore();
      _rebuildInsights();
    } else {
      _metrics = _metrics.copyWith(liveScore: _liveScore);
    }
    return newEvents;
  }

  void flushLiveAnalysis({String? topic}) {
    _recalculateScore();
    _rebuildInsights(topic: topic);
  }

  void tick(Duration elapsed) {
    _metrics = _metrics.copyWith(
      elapsedSeconds: elapsed.inSeconds,
      liveScore: _liveScore,
    );
  }

  VoiceRehearsalSummary buildSummary({String? topic}) {
    final scores = <int, int>{};
    for (final id in kMonitoredVoiceCharacteristicIds) {
      scores[id] = _scoreForCharacteristic(id);
    }

    SpeechStructureAnalysis? structure;
    if (_fullTranscript.trim().isNotEmpty &&
        _metrics.elapsedSeconds > 0) {
      structure = VoiceSpeechStructureAnalyzer.analyze(
        transcript: _fullTranscript,
        totalDurationSeconds: _metrics.elapsedSeconds,
        topic: topic,
        endingAmplitudeVariance: _metrics.amplitudeVariance,
      );
      scores[38] = structure.introScore;
      scores[39] = structure.conclusionScore;
      scores[51] = structure.timeScore;
    }

    _rebuildInsights(structure: structure, topic: topic);

    final formatted = TranscriptParagraphFormatter.format(_fullTranscript);

    return VoiceRehearsalSummary(
      metrics: _metrics.copyWith(liveScore: _liveScore),
      events: List.unmodifiable(_events),
      characteristicScores: scores,
      topRepeatedWords: getTopRepeatedWords(5),
      insights: List.unmodifiable(_insights),
      scoreBreakdown: List.unmodifiable(_lastBreakdown),
      fullTranscript: _fullTranscript,
      formattedTranscript: formatted,
      speechStructureJson: structure?.toJson(),
    );
  }

  /// Aplica transcrição completa (ex.: pós-gravação) e gera resumo.
  VoiceRehearsalSummary buildSummaryFromTranscript({
    required String transcript,
    required int elapsedSeconds,
    String? topic,
  }) {
    _fullTranscript = transcript;
    _lastTranscript = transcript;
    _rebuildWordStatsFromTranscript(transcript);
    final wordCount = _tokenize(transcript).length;
    final wpm =
        elapsedSeconds > 0 ? (wordCount / elapsedSeconds) * 60 : 0.0;
    _metrics = _metrics.copyWith(
      elapsedSeconds: elapsedSeconds,
      wordCount: wordCount,
      wpm: wpm,
      fillerCount: _fillerByWord.values.fold<int>(0, (a, b) => a + b),
      vagueWordCount: _vagueByWord.values.fold<int>(0, (a, b) => a + b),
    );
    _recalculateScore();
    return buildSummary(topic: topic);
  }

  List<WordStat> getTopRepeatedWords(int limit) {
    final contentWords = _wordFrequency.entries
        .where((e) => !_stopWords.contains(e.key) && e.key.length > 2)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return contentWords
        .take(limit)
        .map((e) => WordStat(word: e.key, count: e.value))
        .toList();
  }

  List<WordStat> _getRepetitionOffenders(int totalWords) {
    if (totalWords == 0) return [];
    return _wordFrequency.entries
        .where((e) =>
            !_stopWords.contains(e.key) &&
            !_fillerWords.contains(e.key) &&
            e.key.length > 2 &&
            e.value >= VoiceAnalysisThresholds.repetitionMinCount &&
            e.value / totalWords >= VoiceAnalysisThresholds.repetitionMinRatio)
        .map((e) => WordStat(word: e.key, count: e.value))
        .toList();
  }

  void _syncTranscriptWords(String text) {
    final previous = _fullTranscript;
    _lastTranscript = text;
    _fullTranscript = text;

    if (previous.isNotEmpty &&
        text.length >= previous.length &&
        text.startsWith(previous)) {
      final delta = text.substring(previous.length);
      for (final word in _tokenize(delta)) {
        _incrementWordStat(word);
      }
    } else {
      _rebuildWordStatsFromTranscript(text);
    }
  }

  void _incrementWordStat(String word) {
    _wordFrequency[word] = (_wordFrequency[word] ?? 0) + 1;
    if (_fillerWords.contains(word)) {
      _fillerByWord[word] = (_fillerByWord[word] ?? 0) + 1;
    }
    if (_vagueWords.contains(word)) {
      _vagueByWord[word] = (_vagueByWord[word] ?? 0) + 1;
    }
  }

  void _rebuildWordStatsFromTranscript(String text) {
    _wordFrequency.clear();
    _fillerByWord.clear();
    _vagueByWord.clear();
    for (final word in _tokenize(text)) {
      _incrementWordStat(word);
    }
  }

  void _recalculateScore() {
    var raw = 0.0;
    final breakdown = <ScoreBreakdownItem>[];
    final wordCount = _metrics.wordCount;
    final elapsed = _metrics.elapsedSeconds;

    if (wordCount > 0) {
      final fillerRatio = _metrics.fillerCount / wordCount;
      final fillerGain = max(0.0, 3.0 - min(fillerRatio * 20, 3.0));
      if (fillerGain > 0.05) {
        raw += fillerGain;
        breakdown.add(ScoreBreakdownItem(
          label: 'Poucas muletas',
          points: fillerGain,
        ));
      }
    }

    final topWords = getTopRepeatedWords(1);
    if (topWords.isNotEmpty && wordCount > 0) {
      final top = topWords.first;
      final ratio = top.count / wordCount;
      if (ratio <= VoiceAnalysisThresholds.topWordRatioPenalty) {
        const gain = 1.5;
        raw += gain;
        breakdown.add(ScoreBreakdownItem(
          label: 'Boa variedade de palavras',
          points: gain,
        ));
      }
    } else if (wordCount >= VoiceAnalysisThresholds.minWordsForWpm) {
      const gain = 1.5;
      raw += gain;
      breakdown.add(ScoreBreakdownItem(
        label: 'Sem repetição excessiva',
        points: gain,
      ));
    }

    if (elapsed >= VoiceAnalysisThresholds.minSecondsForAnalysis &&
        wordCount >= VoiceAnalysisThresholds.minWordsForWpm &&
        _metrics.wpm >= VoiceAnalysisThresholds.wpmLow &&
        _metrics.wpm <= VoiceAnalysisThresholds.wpmHigh) {
      const gain = 1.0;
      raw += gain;
      breakdown.add(ScoreBreakdownItem(
        label: 'Ritmo adequado (${_metrics.wpm.toStringAsFixed(0)} WPM)',
        points: gain,
      ));
    }

    if (_amplitudeSamples.length >= 10) {
      final avg = _metrics.avgAmplitudeDb;
      if (avg >= VoiceAnalysisThresholds.volumeLowDb &&
          avg <= VoiceAnalysisThresholds.volumeHighDb) {
        const gain = 1.0;
        raw += gain;
        breakdown.add(ScoreBreakdownItem(
          label: 'Volume adequado',
          points: gain,
        ));
      }
    }

    if (_metrics.amplitudeVariance >=
        VoiceAnalysisThresholds.modulationMinVariance) {
      const gain = 0.5;
      raw += gain;
      breakdown.add(ScoreBreakdownItem(
        label: 'Boa modulação',
        points: gain,
      ));
    }

    if (_strategicPauseBonus > 0) {
      raw += _strategicPauseBonus;
      breakdown.add(ScoreBreakdownItem(
        label: 'Pausas estratégicas',
        points: _strategicPauseBonus,
      ));
    }

    if (_longPauseTimestamps.length >=
        VoiceAnalysisThresholds.longPausesPerMinuteWarning) {
      const penalty = 0.5;
      raw -= penalty;
      breakdown.add(ScoreBreakdownItem(
        label: 'Pausas longas em excesso',
        points: -penalty,
      ));
    }

    raw = raw.clamp(0.0, 10.0);
    _liveScore = 0.7 * _liveScore + 0.3 * raw;
    _liveScore = _liveScore.clamp(0.0, 10.0);
    _lastBreakdown = breakdown;
    _metrics = _metrics.copyWith(liveScore: _liveScore);
  }

  void _rebuildInsights({
    SpeechStructureAnalysis? structure,
    String? topic,
  }) {
    if (_fullTranscript.trim().isEmpty && _metrics.wordCount == 0) {
      _insights = [];
      return;
    }
    _insights = VoiceCoachingBuilder.build(
      transcript: _fullTranscript,
      metrics: _metrics,
      fillerByWord: Map.unmodifiable(_fillerByWord),
      vagueByWord: Map.unmodifiable(_vagueByWord),
      repetitionOffenders: _getRepetitionOffenders(_metrics.wordCount),
      lowConfidenceSegments: _lowConfidenceSegments,
      recentLongPauses: _longPauseTimestamps.length,
      amplitudeSampleCount: _amplitudeSamples.length,
      structure: structure,
      topic: topic,
    );
  }

  VoiceFeedbackEvent? _tryEmit(
    int characteristicId,
    String message,
    VoiceFeedbackSeverity severity,
    DateTime now,
  ) {
    final last = _lastAlertByChar[characteristicId];
    if (last != null &&
        now.difference(last).inSeconds <
            VoiceAnalysisThresholds.alertDebounceSeconds) {
      return null;
    }
    _lastAlertByChar[characteristicId] = now;
    final event = VoiceFeedbackEvent(
      characteristicId: characteristicId,
      message: message,
      severity: severity,
      timestamp: now,
    );
    _events.add(event);
    return event;
  }

  MapEntry<String, int>? _topEntry(Map<String, int> map) {
    if (map.isEmpty) return null;
    return map.entries.reduce((a, b) => a.value >= b.value ? a : b);
  }

  int _scoreForCharacteristic(int id) {
    final charEvents = _events.where((e) => e.characteristicId == id).toList();
    if (charEvents.isEmpty) return 2;
    final warnings = charEvents
        .where((e) => e.severity == VoiceFeedbackSeverity.warning)
        .length;
    final positives = charEvents
        .where((e) => e.severity == VoiceFeedbackSeverity.positive)
        .length;
    if (warnings == 0 && positives > 0) return 3;
    if (warnings <= 1) return 2;
    if (warnings <= 2) return 1;
    return 0;
  }

  double _computeVariance(List<double> samples) {
    if (samples.length < 2) return 0;
    final mean = samples.reduce((a, b) => a + b) / samples.length;
    final sumSq = samples.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b);
    return sumSq / samples.length;
  }

  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  void _pruneOldPauses(DateTime now) {
    _longPauseTimestamps.removeWhere(
      (t) => now.difference(t).inMinutes >= 1,
    );
  }
}

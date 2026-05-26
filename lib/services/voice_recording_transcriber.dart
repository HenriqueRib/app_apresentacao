import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Transcreve gravação local reproduzindo o áudio e capturando via STT.
/// Limitação: qualidade depende do ambiente; backend futuro pode substituir.
class VoiceRecordingTranscriber {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _player = AudioPlayer();

  Future<String?> transcribeFromFile(String filePath) async {
    final available = await _speech.initialize();
    if (!available) return null;

    final buffer = StringBuffer();
    var lastText = '';
    final completer = Completer<String?>();

    try {
      await _speech.listen(
        onResult: (result) {
          final words = result.recognizedWords.trim();
          if (words.isNotEmpty && words != lastText) {
            lastText = words;
            buffer.clear();
            buffer.write(words);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: 'pt_BR',
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
          listenFor: const Duration(hours: 1),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));

      final sub = _player.onPlayerComplete.listen((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        try {
          if (_speech.isListening) await _speech.stop();
        } catch (_) {}
        if (!completer.isCompleted) {
          completer.complete(
            buffer.toString().trim().isEmpty ? null : buffer.toString().trim(),
          );
        }
      });

      await _player.play(DeviceFileSource(filePath));

      final result = await completer.future.timeout(
        const Duration(minutes: 30),
        onTimeout: () => buffer.toString().trim().isEmpty
            ? null
            : buffer.toString().trim(),
      );

      await sub.cancel();
      return result;
    } catch (_) {
      try {
        if (_speech.isListening) await _speech.stop();
      } catch (_) {}
      final text = buffer.toString().trim();
      return text.isEmpty ? null : text;
    } finally {
      await _player.stop();
    }
  }

  void dispose() {
    _player.dispose();
  }
}

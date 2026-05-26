import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/voice_rehearsal.dart';
import '../providers/voice_rehearsal_provider.dart';

/// Reproduz os últimos 30 s da gravação da sessão atual.
class VoiceRehearsalListenBackButton extends StatefulWidget {
  const VoiceRehearsalListenBackButton({super.key});

  @override
  State<VoiceRehearsalListenBackButton> createState() =>
      _VoiceRehearsalListenBackButtonState();
}

class _VoiceRehearsalListenBackButtonState
    extends State<VoiceRehearsalListenBackButton> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle(String? path, int durationSeconds) async {
    if (path == null) return;

    if (_playing) {
      await _player.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }

    final startSec = (durationSeconds - 30).clamp(0, durationSeconds);
    await _player.play(DeviceFileSource(path));
    await _player.seek(Duration(seconds: startSec));
    if (mounted) setState(() => _playing = true);
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceRehearsalProvider>(
      builder: (context, provider, _) {
        if (!provider.smartFlags.listenBackEnabled) {
          return const SizedBox.shrink();
        }
        if (provider.summary == null ||
            provider.recordingPath == null ||
            provider.sessionMode != VoiceSessionMode.recording) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: OutlinedButton.icon(
            onPressed: () => _toggle(
              provider.recordingPath,
              provider.elapsedSeconds,
            ),
            icon: Icon(_playing ? Icons.stop : Icons.replay),
            label: Text(_playing ? 'Parar' : 'Ouvir últimos 30 s'),
          ),
        );
      },
    );
  }
}

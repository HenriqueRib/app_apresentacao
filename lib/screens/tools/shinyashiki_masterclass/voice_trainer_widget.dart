import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_theme.dart';

class VoiceTrainerWidget extends StatefulWidget {
  const VoiceTrainerWidget({super.key});

  @override
  State<VoiceTrainerWidget> createState() => _VoiceTrainerWidgetState();
}

class _VoiceTrainerWidgetState extends State<VoiceTrainerWidget> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordingPath;
  bool _hasPermission = true;

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      setState(() => _hasPermission = false);
      return;
    }
    await _player.stop();
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/ensaio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    setState(() {
      _isRecording = true;
      _isPlaying = false;
      _recordingPath = path;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    setState(() {
      _isRecording = false;
      _recordingPath = path ?? _recordingPath;
    });
  }

  Future<void> _playRecording() async {
    if (_recordingPath == null) return;
    setState(() => _isPlaying = true);
    await _player.play(DeviceFileSource(_recordingPath!));
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  void _discard() {
    _player.stop();
    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      if (file.existsSync()) file.deleteSync();
    }
    setState(() {
      _recordingPath = null;
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Card(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Permissão de microfone necessária. Ative nas configurações do dispositivo.',
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mic, color: AppTheme.secondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Treinador de Voz',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Grave seu ensaio e ouça ritmo, pausas e entonação.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Parar' : 'Gravar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isRecording ? AppTheme.errorColor : AppTheme.accentColor,
                  ),
                ),
                if (_recordingPath != null && !_isRecording) ...[
                  OutlinedButton.icon(
                    onPressed: _isPlaying ? null : _playRecording,
                    icon: Icon(_isPlaying ? Icons.volume_up : Icons.play_arrow),
                    label: Text(_isPlaying ? 'Reproduzindo...' : 'Ouvir'),
                  ),
                  OutlinedButton(
                    onPressed: _discard,
                    child: const Text('Descartar'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

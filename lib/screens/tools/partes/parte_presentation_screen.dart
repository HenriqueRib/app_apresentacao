import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/parte_provider.dart';

class PartePresentationScreen extends StatefulWidget {
  final String parteId;

  const PartePresentationScreen({super.key, required this.parteId});

  @override
  State<PartePresentationScreen> createState() =>
      _PartePresentationScreenState();
}

class _PartePresentationScreenState extends State<PartePresentationScreen> {
  static const int _totalSeconds = 10 * 60;
  int _elapsed = 0;
  Timer? _timer;
  bool _running = false;
  double _fontSize = 22;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Color get _timerColor {
    final remaining = _totalSeconds - _elapsed;
    if (remaining <= 120) return Colors.red;
    if (remaining <= 300) return Colors.amber;
    return Colors.green;
  }

  String _format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
      return;
    }
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed++;
        if (_elapsed >= _totalSeconds) {
          _timer?.cancel();
          _running = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final parte = context.read<ParteProvider>().getParteById(widget.parteId);
    final text = parte?.esbocoManuscrito ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text(parte?.tema ?? 'Apresentar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(14, 40)),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(14, 40)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: _timerColor.withValues(alpha: 0.3),
            child: Column(
              children: [
                Text(
                  _format(_elapsed),
                  style: TextStyle(
                    color: _timerColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Meta: ${_format(_totalSeconds)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                LinearProgressIndicator(
                  value: (_elapsed / _totalSeconds).clamp(0, 1),
                  backgroundColor: Colors.white12,
                  color: _timerColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _fontSize,
                  height: 1.5,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: IconButton.filled(
              onPressed: _toggle,
              iconSize: 48,
              icon: Icon(_running ? Icons.pause : Icons.play_arrow),
              style: IconButton.styleFrom(
                backgroundColor: _running ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

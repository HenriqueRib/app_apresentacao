import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/timer_preset.dart';
import '../../../providers/timer_pro_provider.dart';

enum _TimerBorderState { onTrack, warning, overtime }

class PresentationTimerProScreen extends StatefulWidget {
  const PresentationTimerProScreen({super.key});

  @override
  State<PresentationTimerProScreen> createState() =>
      _PresentationTimerProScreenState();
}

class _PresentationTimerProScreenState
    extends State<PresentationTimerProScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _segmentElapsed = 0;
  int _currentSegmentIndex = 0;
  bool _isRunning = false;
  _TimerBorderState _borderState = _TimerBorderState.onTrack;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimerProProvider>().load();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  TimerPreset? get _preset => context.read<TimerProProvider>().activePreset;

  List<TimerSegment> get _segments => _preset?.segments ?? [];

  TimerSegment? get _currentSegment {
    if (_segments.isEmpty || _currentSegmentIndex >= _segments.length) {
      return null;
    }
    return _segments[_currentSegmentIndex];
  }

  int get _segmentTarget => _currentSegment?.durationSeconds ?? 0;

  int get _totalTarget =>
      _preset?.totalTargetSeconds ??
      (_segments.isEmpty ? 600 : _segments.fold(0, (a, s) => a + s.durationSeconds));

  void _updateBorderState() {
    final target = _segments.isNotEmpty ? _segmentTarget : _totalTarget;
    if (target <= 0) {
      _borderState = _TimerBorderState.onTrack;
      return;
    }
    final elapsed = _segments.isNotEmpty ? _segmentElapsed : _elapsedSeconds;
    if (elapsed > target) {
      _borderState = _TimerBorderState.overtime;
    } else if (elapsed >= (target * 0.85).floor()) {
      _borderState = _TimerBorderState.warning;
    } else {
      _borderState = _TimerBorderState.onTrack;
    }
  }

  Color get _borderColor {
    switch (_borderState) {
      case _TimerBorderState.onTrack:
        return AppTheme.accentColor;
      case _TimerBorderState.warning:
        return AppTheme.warningColor;
      case _TimerBorderState.overtime:
        return AppTheme.errorColor;
    }
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds++;
        _segmentElapsed++;
        _updateBorderState();
        if (_segments.isNotEmpty &&
            _segmentTarget > 0 &&
            _segmentElapsed >= _segmentTarget) {
          if (_currentSegmentIndex < _segments.length - 1) {
            _currentSegmentIndex++;
            _segmentElapsed = 0;
            _borderState = _TimerBorderState.onTrack;
          }
        }
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _elapsedSeconds = 0;
      _segmentElapsed = 0;
      _currentSegmentIndex = 0;
      _borderState = _TimerBorderState.onTrack;
    });
  }

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProProvider>(
      builder: (context, provider, _) {
        final preset = provider.activePreset;
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            title: const Text('Timer Pro'),
            actions: [
              PopupMenuButton<TimerPreset>(
                icon: const Icon(Icons.tune, color: Colors.white),
                onSelected: provider.selectPreset,
                itemBuilder: (context) => provider.presets
                    .map(
                      (p) => PopupMenuItem(
                        value: p,
                        child: Text(p.name),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor, width: 12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (preset != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        preset.name,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_currentSegment != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _currentSegment!.name,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    _format(_segments.isNotEmpty ? _segmentElapsed : _elapsedSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 88,
                      fontWeight: FontWeight.w300,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ${_format(_elapsedSeconds)} / ${_format(_totalTarget)}',
                    style: const TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                  if (_segments.isNotEmpty && _segmentTarget > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Meta do bloco: ${_format(_segmentTarget)}',
                      style: const TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(20),
                        ),
                        onPressed: _reset,
                        icon: const Icon(Icons.replay, size: 32),
                      ),
                      const SizedBox(width: 32),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: _isRunning
                              ? AppTheme.errorColor
                              : AppTheme.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(28),
                        ),
                        onPressed: _toggleTimer,
                        icon: Icon(
                          _isRunning ? Icons.pause : Icons.play_arrow,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

class VoiceRehearsalCountdownOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onCancel;

  const VoiceRehearsalCountdownOverlay({
    super.key,
    required this.onComplete,
    this.onCancel,
  });

  @override
  State<VoiceRehearsalCountdownOverlay> createState() =>
      _VoiceRehearsalCountdownOverlayState();
}

class _VoiceRehearsalCountdownOverlayState
    extends State<VoiceRehearsalCountdownOverlay> {
  int _count = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_count <= 1) {
        _timer?.cancel();
        widget.onComplete();
        return;
      }
      setState(() => _count--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Stack(
          children: [
            if (widget.onCancel != null)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: widget.onCancel,
                ),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_count',
                    style: const TextStyle(
                      fontSize: 96,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Prepare-se…',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

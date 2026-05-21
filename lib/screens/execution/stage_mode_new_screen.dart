import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../models/speech.dart';
import '../../services/characteristics_service.dart';

class StageModeNewScreen extends StatefulWidget {
  final Speech speech;

  const StageModeNewScreen({super.key, required this.speech});

  @override
  State<StageModeNewScreen> createState() => _StageModeNewScreenState();
}

class _StageModeNewScreenState extends State<StageModeNewScreen> {
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  int _currentSection = 0;
  bool _showCue = false;
  String _currentCue = '';

  late List<_OutlineSection> _sections;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initSections();
  }

  void _initSections() {
    _sections = [];

    // 1. Initial Comment
    if (widget.speech.initialComment.isNotEmpty) {
      _sections.add(_OutlineSection(
        title: 'Comentário Inicial',
        content: widget.speech.initialComment,
        type: _SectionType.intro,
        durationHint: 60,
      ));
    }

    // 2. Complete Manuscript (Split by paragraphs for better scrolling)
    if (widget.speech.completeManuscript.isNotEmpty) {
      final paragraphs = widget.speech.completeManuscript
          .split('\n')
          .where((p) => p.trim().isNotEmpty)
          .toList();
      
      for (int i = 0; i < paragraphs.length; i++) {
        _sections.add(_OutlineSection(
          title: 'Manuscrito (Parte ${i + 1})',
          content: paragraphs[i],
          type: _SectionType.main,
          durationHint: (widget.speech.durationMinutes * 60) ~/ paragraphs.length,
        ));
      }
    }

    // 3. Official Outline Cards (If available and no manuscript, or as reference)
    final outline = widget.speech.outline;
    if (outline != null && widget.speech.completeManuscript.isEmpty) {
      if (outline.introduction.isNotEmpty) {
        _sections.add(_OutlineSection(
          title: 'Introdução',
          content: outline.introduction,
          type: _SectionType.intro,
          durationHint: widget.speech.type == SpeechType.student10min ? 60 : 180,
        ));
      }

      for (int i = 0; i < outline.mainPoints.length; i++) {
        final point = outline.mainPoints[i];
        _sections.add(_OutlineSection(
          title: 'Ponto ${i + 1}: ${point.title}',
          content: point.content,
          type: _SectionType.main,
          illustrations: point.illustrations,
          characteristicId: point.characteristicTag,
          durationHint: widget.speech.type == SpeechType.student10min ? 150 : 300,
        ));
      }

      if (outline.conclusion.isNotEmpty) {
        _sections.add(_OutlineSection(
          title: 'Conclusão',
          content: outline.conclusion,
          type: _SectionType.conclusion,
          durationHint: widget.speech.type == SpeechType.student10min ? 60 : 180,
        ));
      }
    }

    // 4. Final Comment
    if (widget.speech.finalComment.isNotEmpty) {
      _sections.add(_OutlineSection(
        title: 'Comentário Final',
        content: widget.speech.finalComment,
        type: _SectionType.conclusion,
        durationHint: 60,
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    final targetSeconds = widget.speech.durationMinutes * 60;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTimerBar(targetSeconds),
            if (_showCue) _buildCueCard(),
            Expanded(child: _buildTeleprompter()),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppTheme.primaryColor.withValues(alpha: 0.3),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  widget.speech.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Objetivo: ${widget.speech.centralObjective}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showCharacteristicHelp,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar(int targetSeconds) {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    final progress = _elapsedSeconds / targetSeconds;
    final isIn3MinWindow = _elapsedSeconds < 180;
    final isOvertime = _elapsedSeconds > targetSeconds;

    Color timerColor;
    String? warningText;

    if (isOvertime) {
      timerColor = AppTheme.errorColor;
      warningText = 'ENCERRAR IMEDIATAMENTE';
    } else if (progress > 0.9) {
      timerColor = AppTheme.warningColor;
      warningText = 'CONCLUIR AGORA';
    } else if (isIn3MinWindow && _isRunning) {
      timerColor = AppTheme.accentColor;
      warningText = 'LARGADA FORTE - Capte a atenção!';
    } else {
      timerColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: timerColor,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
          ),
          if (warningText != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: timerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                warningText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCueCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentCue,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() {
                _showCue = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTeleprompter() {
    if (_sections.isEmpty) {
      return const Center(
        child: Text(
          'Preencha o esboço primeiro',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          _nextSection();
        } else if (details.primaryVelocity! > 0) {
          _previousSection();
        }
      },
      child: PageView.builder(
        itemCount: _sections.length,
        controller: PageController(initialPage: _currentSection),
        onPageChanged: (index) {
          setState(() {
            _currentSection = index;
          });
          _checkForCue(index);
        },
        itemBuilder: (context, index) {
          final section = _sections[index];
          return _buildSectionCard(section, index);
        },
      ),
    );
  }

  Widget _buildSectionCard(_OutlineSection section, int index) {
    Color accentColor;
    switch (section.type) {
      case _SectionType.intro:
        accentColor = Colors.blue;
      case _SectionType.main:
        accentColor = AppTheme.primaryColor;
      case _SectionType.conclusion:
        accentColor = AppTheme.accentColor;
    }

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}/${_sections.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '~${section.durationHint ~/ 60}min',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.content,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.6,
                    ),
                  ),
                  if (section.illustrations.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb,
                                  color: AppTheme.secondaryColor),
                              SizedBox(width: 8),
                              Text(
                                'Ilustração',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            section.illustrations.first,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _previousSection,
            icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32),
          ),
          IconButton(
            onPressed: _triggerPause,
            icon: const Icon(Icons.pause_circle_outline,
                color: Colors.white, size: 32),
          ),
          IconButton.filled(
            onPressed: _toggleTimer,
            icon: Icon(
              _isRunning ? Icons.pause : Icons.play_arrow,
              size: 48,
            ),
            style: IconButton.styleFrom(
              backgroundColor:
                  _isRunning ? AppTheme.warningColor : AppTheme.accentColor,
              padding: const EdgeInsets.all(16),
            ),
          ),
          IconButton(
            onPressed: _resetTimer,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 32),
          ),
          IconButton(
            onPressed: _nextSection,
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  void _nextSection() {
    if (_currentSection < _sections.length - 1) {
      setState(() {
        _currentSection++;
      });
    }
  }

  void _previousSection() {
    if (_currentSection > 0) {
      setState(() {
        _currentSection--;
      });
    }
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedSeconds++;
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _elapsedSeconds = 0;
      _currentSection = 0;
    });
    _timer?.cancel();
  }

  void _triggerPause() {
    setState(() {
      _showCue = true;
      _currentCue = 'FAÇA UMA PAUSA - Deixe a ideia ecoar no coração';
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showCue = false;
        });
      }
    });
  }

  void _checkForCue(int sectionIndex) {
    if (sectionIndex < _sections.length) {
      final section = _sections[sectionIndex];
      if (section.characteristicId != null) {
        final char = CharacteristicsService.instance
            .getCharacteristicById(section.characteristicId!);
        if (char != null) {
          setState(() {
            _showCue = true;
            _currentCue = '${char.title}: ${char.action.split('.').first}';
          });
        }
      }
    }
  }

  void _showCharacteristicHelp() {
    final focusId = widget.speech.focusCharacteristicId;
    if (focusId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma característica em foco')),
      );
      return;
    }

    final char = CharacteristicsService.instance.getCharacteristicById(focusId);
    if (char == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text(
            char.title,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O que fazer:',
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                char.action,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}

enum _SectionType { intro, main, conclusion }

class _OutlineSection {
  final String title;
  final String content;
  final _SectionType type;
  final List<String> illustrations;
  final int? characteristicId;
  final int durationHint;

  _OutlineSection({
    required this.title,
    required this.content,
    required this.type,
    this.illustrations = const [],
    this.characteristicId,
    required this.durationHint,
  });
}

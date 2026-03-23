import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/presentation.dart';

class StageModeScreen extends StatefulWidget {
  final Presentation presentation;

  const StageModeScreen({
    super.key,
    required this.presentation,
  });

  @override
  State<StageModeScreen> createState() => _StageModeScreenState();
}

class _StageModeScreenState extends State<StageModeScreen> {
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  int _currentElementIndex = 0;
  bool _showSilenceIndicator = false;
  
  final Map<String, bool> _professionalismChecklist = {};

  final List<_TeleprompterElement> _elements = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initElements();
    _initChecklist();
  }

  void _initElements() {
    final arch = widget.presentation.messageArchitecture;
    if (arch == null) return;

    if (arch.centralIdea.isNotEmpty) {
      _elements.add(_TeleprompterElement(
        title: 'Ideia Central',
        content: arch.centralIdea,
        type: _ElementType.normal,
      ));
    }
    if (arch.problem.isNotEmpty) {
      _elements.add(_TeleprompterElement(
        title: 'Problema/Desafio',
        content: arch.problem,
        type: _ElementType.normal,
      ));
    }
    if (arch.audienceIdentification.isNotEmpty) {
      _elements.add(_TeleprompterElement(
        title: 'Identificação do Público',
        content: arch.audienceIdentification,
        type: _ElementType.normal,
      ));
    }
    if (arch.problemCause.isNotEmpty) {
      _elements.add(_TeleprompterElement(
        title: 'Causa do Problema',
        content: arch.problemCause,
        type: _ElementType.normal,
      ));
    }
    if (arch.solutionAndMethod.isNotEmpty) {
      _elements.add(_TeleprompterElement(
        title: 'Solução e Método',
        content: arch.solutionAndMethod,
        type: _ElementType.eureka,
      ));
    }
    if (arch.motivationSelfConfidence.isNotEmpty ||
        arch.motivationOvercoming.isNotEmpty ||
        arch.motivationAction.isNotEmpty) {
      _elements.add(_TeleprompterElement(
        title: 'Motivação',
        content:
            '• Autoconfiança: ${arch.motivationSelfConfidence}\n'
            '• Superação: ${arch.motivationOvercoming}\n'
            '• Ação: ${arch.motivationAction}',
        type: _ElementType.motivation,
      ));
    }
    if (arch.requestedAction.isNotEmpty) {
      _elements.add(_TeleprompterElement(
        title: 'Ação Solicitada',
        content: arch.requestedAction,
        type: _ElementType.action,
      ));
    }
    if (arch.celebration.isNotEmpty) {
      _elements.add(_TeleprompterElement(
        title: 'Celebração',
        content: arch.celebration,
        type: _ElementType.celebration,
      ));
    }
  }

  void _initChecklist() {
    for (final item in AppConstants.professionalismChecklistItems) {
      _professionalismChecklist[item] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTimerWarning(),
            Expanded(child: _buildTeleprompter()),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: Text(
              widget.presentation.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.checklist, color: Colors.white),
            onPressed: _showProfessionalismChecklist,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerWarning() {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    final isInCriticalOpening = minutes < AppConstants.openingCriticalMinutes;

    String? warningMessage;
    Color warningColor = Colors.transparent;

    if (_isRunning) {
      if (minutes == 0 && seconds < 30) {
        warningMessage = 'EXECUTAR ABERTURA FORTE';
        warningColor = AppTheme.secondaryColor;
      } else if (minutes == 2 && seconds >= 30) {
        warningMessage = 'PAUSAR PARA REFLEXÃO';
        warningColor = AppTheme.warningColor;
      } else if (minutes >= 4 && seconds >= 30) {
        warningMessage = 'ENCERRAR AGORA';
        warningColor = AppTheme.errorColor;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isInCriticalOpening && _isRunning
                      ? AppTheme.secondaryColor
                      : Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          if (warningMessage != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: warningColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                warningMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeleprompter() {
    if (_elements.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum conteúdo disponível.\nPreencha a arquitetura da mensagem.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          _nextElement();
        } else if (details.primaryVelocity! > 0) {
          _previousElement();
        }
      },
      child: PageView.builder(
        itemCount: _elements.length,
        controller: PageController(initialPage: _currentElementIndex),
        onPageChanged: (index) {
          setState(() {
            _currentElementIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final element = _elements[index];
          return _buildElementCard(element, index);
        },
      ),
    );
  }

  Widget _buildElementCard(_TeleprompterElement element, int index) {
    Color accentColor;
    switch (element.type) {
      case _ElementType.eureka:
        accentColor = AppTheme.secondaryColor;
      case _ElementType.motivation:
        accentColor = AppTheme.accentColor;
      case _ElementType.action:
        accentColor = AppTheme.warningColor;
      case _ElementType.celebration:
        accentColor = Colors.purple;
      case _ElementType.normal:
        accentColor = AppTheme.primaryColor;
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${index + 1}/${_elements.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  element.title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                element.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.6,
                ),
              ),
            ),
          ),
          if (_showSilenceIndicator)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pause_circle, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'PAUSA ESTRATÉGICA',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _previousElement,
            icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _showSilenceIndicator = !_showSilenceIndicator;
              });
            },
            icon: Icon(
              _showSilenceIndicator ? Icons.volume_off : Icons.pause_circle_outline,
              color: _showSilenceIndicator ? AppTheme.warningColor : Colors.white,
              size: 32,
            ),
          ),
          IconButton.filled(
            onPressed: _toggleTimer,
            icon: Icon(
              _isRunning ? Icons.pause : Icons.play_arrow,
              size: 48,
            ),
            style: IconButton.styleFrom(
              backgroundColor: _isRunning ? AppTheme.warningColor : AppTheme.accentColor,
              padding: const EdgeInsets.all(16),
            ),
          ),
          IconButton(
            onPressed: _resetTimer,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 32),
          ),
          IconButton(
            onPressed: _nextElement,
            icon: const Icon(Icons.skip_next, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  void _nextElement() {
    if (_currentElementIndex < _elements.length - 1) {
      setState(() {
        _currentElementIndex++;
      });
    }
  }

  void _previousElement() {
    if (_currentElementIndex > 0) {
      setState(() {
        _currentElementIndex--;
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
      _currentElementIndex = 0;
    });
    _timer?.cancel();
  }

  void _showProfessionalismChecklist() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Checklist de Profissionalismo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...AppConstants.professionalismChecklistItems.map((item) {
                    return CheckboxListTile(
                      value: _professionalismChecklist[item],
                      onChanged: (value) {
                        setModalState(() {
                          _professionalismChecklist[item] = value ?? false;
                        });
                      },
                      title: Text(
                        item,
                        style: const TextStyle(color: Colors.white),
                      ),
                      checkColor: Colors.white,
                      activeColor: AppTheme.accentColor,
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
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

enum _ElementType {
  normal,
  eureka,
  motivation,
  action,
  celebration,
}

class _TeleprompterElement {
  final String title;
  final String content;
  final _ElementType type;

  _TeleprompterElement({
    required this.title,
    required this.content,
    required this.type,
  });
}

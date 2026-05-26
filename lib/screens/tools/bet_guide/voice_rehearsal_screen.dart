import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/speech.dart';
import '../../../models/voice_rehearsal.dart';
import '../../../models/voice_rehearsal_report_view_mode.dart';
import '../../../providers/speech_provider.dart';
import '../../../providers/voice_rehearsal_provider.dart';
import '../../../services/storage_service.dart';
import '../../../services/voice_session_checkpoint.dart';
import '../../../widgets/voice_coaching_feed.dart';
import '../../../widgets/voice_rehearsal_compact_metrics.dart';
import '../../../widgets/voice_rehearsal_live/voice_rehearsal_live_bindings.dart';
import '../../../widgets/voice_rehearsal_live/voice_rehearsal_live_minimal_layout.dart';
import '../../../widgets/voice_rehearsal_live/voice_rehearsal_live_visual_layout.dart';
import '../../../widgets/voice_rehearsal/voice_rehearsal_countdown_overlay.dart';
import '../../../widgets/voice_rehearsal_listen_back_button.dart';
import '../../../widgets/voice_rehearsal_prepare_card.dart';
import 'voice_recordings_screen.dart';
import 'voice_rehearsal_help_screen.dart';
import 'voice_rehearsal_history_screen.dart';
import '../../../utils/voice_rehearsal_navigation.dart';
import '../../../widgets/voice_rehearsal/voice_rehearsal_onboarding.dart';

class VoiceRehearsalScreen extends StatefulWidget {
  final Speech? initialSpeech;

  /// Atalho: ex. 240 para ensaio de 4 minutos.
  final int? initialDurationGoalSeconds;

  const VoiceRehearsalScreen({
    super.key,
    this.initialSpeech,
    this.initialDurationGoalSeconds,
  });

  @override
  State<VoiceRehearsalScreen> createState() => _VoiceRehearsalScreenState();
}

class _VoiceRehearsalScreenState extends State<VoiceRehearsalScreen>
    with WidgetsBindingObserver {
  final ScrollController _feedScrollController = ScrollController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _seriesController = TextEditingController();
  final TextEditingController _speakerController = TextEditingController();
  final GlobalKey _firstInsightKey = GlobalKey();

  CoachingCategoryFilter _selectedFilter = CoachingCategoryFilter.all;
  VoiceRehearsalReportViewMode _viewMode = VoiceRehearsalReportViewMode.minimal;
  double? _baselineLastScore;
  double? _baselineBestScore;
  int _previousInsightCount = 0;
  VoiceRehearsalSummary? _handledSummary;
  VoiceRehearsalProvider? _provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _provider = context.read<VoiceRehearsalProvider>();

      final storage = await StorageService.getInstance();
      final viewMode = await storage.getVoiceRehearsalReportViewMode();
      if (mounted) setState(() => _viewMode = viewMode);

      await _provider!.initialize();
      await _provider!.loadSessionPrefs();
      if (widget.initialDurationGoalSeconds != null) {
        await _provider!
            .setDurationGoalSeconds(widget.initialDurationGoalSeconds);
      }
      if (!mounted) return;
      final speechProvider = context.read<SpeechProvider>();
      if (speechProvider.speeches.isEmpty) {
        await speechProvider.loadSpeeches();
      }
      if (widget.initialSpeech != null) {
        await _provider!.linkSpeech(widget.initialSpeech);
        if (mounted) {
          _topicController.text = widget.initialSpeech!.title;
        }
      } else {
        await _restoreLinkedSpeechFromStorage();
      }
      await _loadBaselineScores();
      if (!mounted) return;
      final checkpoint = await _provider!.loadCheckpoint();
      if (checkpoint != null && mounted) {
        _showResumeDialog(checkpoint);
      } else if (mounted) {
        await showVoiceRehearsalOnboardingIfNeeded(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _detachProviderListeners();
    _feedScrollController.dispose();
    _topicController.dispose();
    _seriesController.dispose();
    _speakerController.dispose();
    super.dispose();
  }

  Future<void> _restoreLinkedSpeechFromStorage() async {
    final linkedId = _provider?.linkedSpeechId;
    if (linkedId == null || !mounted) return;
    final speeches = context.read<SpeechProvider>().speeches;
    for (final s in speeches) {
      if (s.id == linkedId) {
        await _provider!.linkSpeech(s);
        break;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<VoiceRehearsalProvider>();
    if (!identical(_provider, provider)) {
      _detachProviderListeners();
      _provider = provider;
      _attachProviderListeners();
    }
  }

  void _attachProviderListeners() {
    _provider?.addListener(_onProviderChanged);
    _provider?.contentListenable.addListener(_onProviderChanged);
  }

  void _detachProviderListeners() {
    _provider?.removeListener(_onProviderChanged);
    _provider?.contentListenable.removeListener(_onProviderChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _provider?.saveCheckpointNow();
    }
  }

  Future<void> _loadBaselineScores() async {
    try {
      final storage = await StorageService.getInstance();
      final attempts = await storage.getVoiceRehearsalAttempts();
      if (!mounted || attempts.isEmpty) return;
      var best = attempts.first.finalScore;
      for (final a in attempts) {
        if (a.finalScore > best) best = a.finalScore;
      }
      setState(() {
        _baselineLastScore = attempts.first.finalScore;
        _baselineBestScore = best;
      });
    } catch (_) {}
  }

  void _onProviderChanged() {
    if (!mounted) return;
    final provider = _provider;
    if (provider == null) return;

    final insightCount = provider.insights.length;
    if (provider.isRecording && insightCount > _previousInsightCount) {
      _previousInsightCount = insightCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_feedScrollController.hasClients) {
          _feedScrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else if (!provider.isRecording) {
      _previousInsightCount = insightCount;
    }

    final summary = provider.summary;
    if (summary != null && !identical(summary, _handledSummary)) {
      _handledSummary = summary;
      _loadBaselineScores();
    }
  }

  Future<void> _setViewMode(VoiceRehearsalReportViewMode mode) async {
    if (_viewMode == mode) return;
    final storage = await StorageService.getInstance();
    await storage.setVoiceRehearsalReportViewMode(mode);
    if (mounted) setState(() => _viewMode = mode);
  }

  Future<void> _openVolumeTest(BuildContext context) =>
      openVoiceVolumeTest(context);

  void _onAppBarMenu(BuildContext context, String value) {
    switch (value) {
      case 'view_minimal':
        _setViewMode(VoiceRehearsalReportViewMode.minimal);
      case 'view_visual':
        _setViewMode(VoiceRehearsalReportViewMode.visual);
      case 'help':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VoiceRehearsalHelpScreen()),
        );
      case 'volume':
        _openVolumeTest(context);
      case 'history':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const VoiceRehearsalHistoryScreen(),
          ),
        );
      case 'recordings':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VoiceRecordingsScreen()),
        );
    }
  }

  Future<void> _showResumeDialog(VoiceSessionCheckpoint checkpoint) async {
    final resume = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Continuar ensaio?'),
        content: Text(
          'Há um ensaio em andamento '
          '(${VoiceRehearsalCompactMetrics.formatTime(checkpoint.elapsedSeconds)}). '
          'Deseja continuar de onde parou?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Descartar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (resume == true) {
      await _provider!.resumeFromCheckpoint(checkpoint);
    } else {
      final discard = await _confirmDiscardCheckpoint(checkpoint);
      if (discard == true) {
        await VoiceSessionCheckpoint.clear();
      } else if (discard == false && mounted) {
        await _provider!.resumeFromCheckpoint(checkpoint);
      }
    }
  }

  Future<bool?> _confirmDiscardCheckpoint(VoiceSessionCheckpoint checkpoint) {
    if (checkpoint.elapsedSeconds < 60) return Future.value(true);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar ensaio?'),
        content: Text(
          'Você perderá o progresso de '
          '${VoiceRehearsalCompactMetrics.formatTime(checkpoint.elapsedSeconds)} '
          'e a transcrição salva até agora.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }

  Future<void> _startSession(VoiceSessionMode mode) async {
    await _loadBaselineScores();
    if (!mounted) return;
    _provider!.setSeriesName(_seriesController.text);
    await _provider!.startSessionWithSmartFlow(mode);
  }

  Future<void> _restartWithMode(VoiceSessionMode mode) async {
    await _provider!.discardSession();
    _topicController.clear();
    _handledSummary = null;
    _previousInsightCount = 0;
    await _loadBaselineScores();
    if (mounted) await _startSession(mode);
  }

  VoiceImprovementInsight? _topInsight(VoiceRehearsalProvider provider) {
    if (provider.insights.isEmpty) return null;
    final sorted = List<VoiceImprovementInsight>.from(provider.insights)
      ..sort((a, b) => b.severityRank.compareTo(a.severityRank));
    return sorted.first;
  }

  ({String? label, Color? color}) _scoreDelta(VoiceRehearsalProvider provider) {
    if (provider.summary == null) return (label: null, color: null);
    final current = provider.summary!.metrics.liveScore;

    if (_baselineBestScore != null) {
      final vsBest = current - _baselineBestScore!;
      if (vsBest >= 0.05) {
        return (label: 'Novo recorde!', color: AppTheme.successColor);
      }
      if (vsBest < -0.05) {
        return (
          label: '${vsBest.toStringAsFixed(1)} vs recorde',
          color: AppTheme.warningColor,
        );
      }
    }

    if (_baselineLastScore != null) {
      final delta = current - _baselineLastScore!;
      if (delta.abs() < 0.05) {
        return (label: '= último ensaio', color: AppTheme.textSecondary);
      }
      final sign = delta > 0 ? '+' : '';
      return (
        label: '$sign${delta.toStringAsFixed(1)} vs último',
        color: delta > 0 ? AppTheme.successColor : AppTheme.errorColor,
      );
    }

    return (label: null, color: null);
  }

  void _scrollToFirstInsight() {
    final target = _firstInsightKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else if (_feedScrollController.hasClients) {
      _feedScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ensaio be-T', style: TextStyle(fontSize: 18)),
            Text(
              'Ensaie. Treine. Evolua.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
        actions: [
          Consumer<VoiceRehearsalProvider>(
            builder: (context, provider, _) {
              if (!provider.isRecording) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  provider.focusMode
                      ? Icons.center_focus_strong
                      : Icons.center_focus_weak,
                ),
                tooltip: provider.focusMode
                    ? 'Desativar modo foco'
                    : 'Ativar modo foco',
                onPressed: () => provider.setFocusMode(!provider.focusMode),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Mais opções',
            onSelected: (value) => _onAppBarMenu(context, value),
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                value: 'view_minimal',
                checked: _viewMode == VoiceRehearsalReportViewMode.minimal,
                child: const Text('Layout minimalista'),
              ),
              CheckedPopupMenuItem(
                value: 'view_visual',
                checked: _viewMode == VoiceRehearsalReportViewMode.visual,
                child: const Text('Layout dinâmico'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'help',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.info_outline, size: 22),
                  title: Text('Como funciona'),
                ),
              ),
              const PopupMenuItem(
                value: 'volume',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.graphic_eq, size: 22),
                  title: Text('Teste de volume'),
                ),
              ),
              const PopupMenuItem(
                value: 'history',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.history, size: 22),
                  title: Text('Histórico'),
                ),
              ),
              const PopupMenuItem(
                value: 'recordings',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.library_music, size: 22),
                  title: Text('Gravações'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Selector<VoiceRehearsalProvider, bool>(
        selector: (_, p) => p.hasMicPermission,
        builder: (context, hasMicPermission, _) {
          if (!hasMicPermission) {
            return _buildPermissionWarning();
          }
          return _buildMainBody(context);
        },
      ),
    );
  }

  Widget _buildMainBody(BuildContext context) {
    final provider = context.watch<VoiceRehearsalProvider>();
    final bindings = VoiceRehearsalLiveBindings(
      selectedFilter: _selectedFilter,
      onFilterChanged: (f) => setState(() => _selectedFilter = f),
      feedScrollController: _feedScrollController,
      firstInsightKey: _firstInsightKey,
      onScrollToFirstInsight: _scrollToFirstInsight,
      postScoreDeltaLabel: _scoreDelta(provider).label,
      postScoreDeltaColor: _scoreDelta(provider).color,
      baselineBestScore: _baselineBestScore,
    );

    final inSetup = _showSessionSetup(provider);

    return Stack(
      children: [
        Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: inSetup
              ? SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!provider.speechAvailable)
                        const _SpeechUnavailableCard(),
                      VoiceRehearsalPrepareCard(
                        topicController: _topicController,
                        seriesController: _seriesController,
                        speakerController: _speakerController,
                        bestScore: _baselineBestScore,
                        onTopicChanged: provider.setSessionTopic,
                      ),
                    ],
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _viewMode == VoiceRehearsalReportViewMode.minimal
                      ? VoiceRehearsalLiveMinimalLayout(
                          key: const ValueKey('live_minimal'),
                          provider: provider,
                          bindings: bindings,
                          topInsight: provider.isRecording
                              ? _topInsight(provider)
                              : null,
                        )
                      : VoiceRehearsalLiveVisualLayout(
                          key: const ValueKey('live_visual'),
                          provider: provider,
                          bindings: bindings,
                          topInsight: provider.isRecording
                              ? _topInsight(provider)
                              : null,
                        ),
                ),
        ),
        const VoiceRehearsalListenBackButton(),
        _VoiceRehearsalBottomBar(
          onRestartTraining: () => _restartWithMode(VoiceSessionMode.training),
          onRestartRecording: () =>
              _restartWithMode(VoiceSessionMode.recording),
          onStartTraining: () => _startSession(VoiceSessionMode.training),
          onStartRecording: () => _startSession(VoiceSessionMode.recording),
          onNewRehearsal: () {
            provider.discardSession();
            _topicController.clear();
            _speakerController.clear();
            _handledSummary = null;
            _previousInsightCount = 0;
            setState(() => _selectedFilter = CoachingCategoryFilter.all);
          },
        ),
      ],
    ),
        if (provider.sessionPhase == VoiceSessionPhase.countdown)
          VoiceRehearsalCountdownOverlay(
            onComplete: () async {
              await provider.completeCountdownAndStart();
            },
            onCancel: provider.cancelCountdown,
          ),
      ],
    );
  }

  bool _showSessionSetup(VoiceRehearsalProvider provider) =>
      !provider.isRecording && provider.summary == null;

  Widget _buildPermissionWarning() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.mic_off, size: 40, color: AppTheme.warningColor),
              const SizedBox(height: 12),
              const Text(
                'Microfone necessário para ensaiar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                Platform.isIOS
                    ? 'Ajustes → Privacidade e Segurança → Microfone → ative este app. '
                        'Em seguida toque em Tentar novamente.'
                    : 'Configurações → Apps → Palestrante de Sucesso → Permissões → '
                        'Microfone. Depois toque em Tentar novamente.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  await context.read<VoiceRehearsalProvider>().initialize();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _SpeechUnavailableCard extends StatelessWidget {
  const _SpeechUnavailableCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        color: AppTheme.warningColor.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.record_voice_over_outlined,
                  color: AppTheme.warningColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reconhecimento de voz indisponível',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Platform.isIOS
                          ? 'Use Gravar (.m4a) ou verifique Ajustes → Privacidade → '
                              'Reconhecimento de fala. Volume, pausas e ritmo '
                              'continuam no modo Gravar.'
                          : 'Use Gravar (.m4a) ou verifique se o Google Speech '
                              'está disponível no dispositivo.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceRehearsalBottomBar extends StatelessWidget {
  final VoidCallback onStartTraining;
  final VoidCallback onStartRecording;
  final VoidCallback onRestartTraining;
  final VoidCallback onRestartRecording;
  final VoidCallback onNewRehearsal;

  const _VoiceRehearsalBottomBar({
    required this.onStartTraining,
    required this.onStartRecording,
    required this.onRestartTraining,
    required this.onRestartRecording,
    required this.onNewRehearsal,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<VoiceRehearsalProvider, _BottomBarState>(
      selector: (_, p) => _BottomBarState(
        isRecording: p.isRecording,
        isPaused: p.isPaused,
        hasSummary: p.summary != null,
        speechAvailable: p.speechAvailable,
      ),
      builder: (context, state, _) {
        final provider = context.read<VoiceRehearsalProvider>();

        return Material(
          elevation: 8,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!state.speechAvailable)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'STT indisponível — volume e pausas continuam ativos.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (state.isRecording) ...[
                    if (state.isPaused)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => provider.resumeSession(),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Retomar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => provider.pauseSession(),
                              icon: const Icon(Icons.pause),
                              label: const Text('Pausar'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => provider.stopSession(),
                              icon: const Icon(Icons.stop),
                              label: const Text('Parar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (state.isPaused) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => provider.stopSession(),
                          icon: const Icon(Icons.stop),
                          label: const Text('Encerrar ensaio'),
                        ),
                      ),
                    ],
                  ] else if (state.hasSummary) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onNewRehearsal,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Novo ensaio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onRestartTraining,
                            icon: const Icon(Icons.mic_none, size: 18),
                            label: const Text('Treino'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onRestartRecording,
                            icon: const Icon(Icons.fiber_manual_record, size: 18),
                            label: const Text('Gravar'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: Semantics(
                            button: true,
                            label: 'Iniciar treino com reconhecimento de voz',
                            child: OutlinedButton(
                            onPressed: onStartTraining,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.mic_none),
                                SizedBox(height: 4),
                                Text('Iniciar treino',
                                    style: TextStyle(fontSize: 13)),
                                Text(
                                  'Sem salvar áudio',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Semantics(
                            button: true,
                            label: 'Gravar ensaio em arquivo de áudio',
                            child: ElevatedButton(
                            onPressed: onStartRecording,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fiber_manual_record),
                                SizedBox(height: 4),
                                Text('Gravar',
                                    style: TextStyle(fontSize: 13)),
                                Text(
                                  'Salva .m4a',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomBarState {
  final bool isRecording;
  final bool isPaused;
  final bool hasSummary;
  final bool speechAvailable;

  const _BottomBarState({
    required this.isRecording,
    required this.isPaused,
    required this.hasSummary,
    required this.speechAvailable,
  });

  @override
  bool operator ==(Object other) =>
      other is _BottomBarState &&
      isRecording == other.isRecording &&
      isPaused == other.isPaused &&
      hasSummary == other.hasSummary &&
      speechAvailable == other.speechAvailable;

  @override
  int get hashCode => Object.hash(
        isRecording,
        isPaused,
        hasSummary,
        speechAvailable,
      );
}

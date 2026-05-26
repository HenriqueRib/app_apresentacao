import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/voice_rehearsal_provider.dart';

/// Roteiro do esboço: bloco ativo, próximo bloco e rolagem lenta opcional.
class VoiceRehearsalTeleprompterStrip extends StatefulWidget {
  const VoiceRehearsalTeleprompterStrip({super.key});

  @override
  State<VoiceRehearsalTeleprompterStrip> createState() =>
      _VoiceRehearsalTeleprompterStripState();
}

class _VoiceRehearsalTeleprompterStripState
    extends State<VoiceRehearsalTeleprompterStrip> {
  final ScrollController _bodyScrollController = ScrollController();
  Timer? _autoScrollTimer;
  int _lastActiveIndex = 0;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _bodyScrollController.dispose();
    super.dispose();
  }

  void _syncAutoScroll(VoiceRehearsalProvider provider) {
    _autoScrollTimer?.cancel();
    if (!provider.isRecording ||
        provider.isPaused ||
        !provider.smartFlags.autoScrollTeleprompter) {
      return;
    }
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!_bodyScrollController.hasClients) return;
      final max = _bodyScrollController.position.maxScrollExtent;
      if (_bodyScrollController.offset >= max - 1) return;
      _bodyScrollController.jumpTo(_bodyScrollController.offset + 1.2);
    });
  }

  void _resetBodyScroll(int activeIndex) {
    if (activeIndex == _lastActiveIndex) return;
    _lastActiveIndex = activeIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_bodyScrollController.hasClients) {
        _bodyScrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceRehearsalProvider>(
      builder: (context, provider, _) {
        final sections = provider.teleprompterSections;
        if (sections.isEmpty) return const SizedBox.shrink();

        final activeIndex = provider.teleprompterActiveIndex
            .clamp(0, sections.length - 1);
        final active = sections[activeIndex];
        final isLive = provider.isRecording && !provider.isPaused;

        _resetBodyScroll(activeIndex);
        _syncAutoScroll(provider);

        return RepaintBoundary(
          child: Material(
            color: AppTheme.backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Roteiro do esboço',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      if (isLive)
                        TextButton.icon(
                          onPressed: activeIndex < sections.length - 1
                              ? provider.advanceTeleprompterBlock
                              : null,
                          icon: const Icon(Icons.skip_next, size: 18),
                          label: const Text(
                            'Próximo bloco',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: sections.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final section = sections[index];
                      final selected = index == activeIndex;
                      return ChoiceChip(
                        label: Text(
                          section.title,
                          style: const TextStyle(fontSize: 11),
                        ),
                        selected: selected,
                        onSelected: (_) =>
                            provider.selectTeleprompterBlock(index),
                        visualDensity: VisualDensity.compact,
                      );
                    },
                  ),
                ),
                if (isLive || provider.summary != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 96),
                    child: SingleChildScrollView(
                      controller: _bodyScrollController,
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                      child: Text(
                        active.body,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: isLive
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                const Divider(height: 1),
              ],
            ),
          ),
        );
      },
    );
  }
}

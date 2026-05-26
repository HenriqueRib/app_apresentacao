import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/voice_teleprompter_section.dart';
import '../../providers/voice_rehearsal_provider.dart';

class VoiceRehearsalTeleprompterStrip extends StatelessWidget {
  const VoiceRehearsalTeleprompterStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceRehearsalProvider>(
      builder: (context, provider, _) {
        final sections = provider.teleprompterSections;
        if (sections.isEmpty) return const SizedBox.shrink();

        return Material(
          color: AppTheme.backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                child: Text(
                  'Roteiro do esboço',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
                    return ActionChip(
                      label: Text(
                        section.title,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () => _showSection(context, section),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        );
      },
    );
  }

  void _showSection(BuildContext context, VoiceTeleprompterSection section) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.45,
        maxChildSize: 0.85,
        minChildSize: 0.25,
        builder: (context, scrollController) => SafeArea(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Text(
                section.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(section.body, style: const TextStyle(height: 1.45)),
            ],
          ),
        ),
      ),
    );
  }
}

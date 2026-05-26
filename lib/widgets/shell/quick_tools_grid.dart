import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/tools/assentinel/assentinel_screen.dart';
import '../../screens/tools/bet_guide/self_assessment_screen.dart';
import '../../screens/tools/bet_guide/voice_rehearsal_screen.dart';
import '../../screens/tools/discursos/discursos_admin_screen.dart';
import '../../screens/tools/meeting/meeting_hub_screen.dart';
import '../../screens/tools/partes/partes_list_screen.dart';
import '../../screens/tools/shinyashiki_masterclass/shinyashiki_masterclass_screen.dart';
import '../../screens/tools/studio/study_studio_list_screen.dart';
import '../../screens/tools/timer/presentation_timer_pro_screen.dart';

class QuickToolItem {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final String? customLabel;
  final VoidCallback onTap;

  const QuickToolItem({
    required this.title,
    required this.icon,
    this.iconColor,
    this.customLabel,
    required this.onTap,
  });
}

class QuickToolsGrid extends StatelessWidget {
  const QuickToolsGrid({super.key});

  static List<QuickToolItem> primaryTools(BuildContext context) => [
        QuickToolItem(
          title: 'Central da Reunião',
          icon: Icons.event_note,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MeetingHubScreen()),
          ),
        ),
        QuickToolItem(
          title: 'A Sentinela',
          icon: Icons.auto_stories,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AssentinelScreen()),
          ),
        ),
        QuickToolItem(
          title: 'Discursos',
          icon: Icons.record_voice_over,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DiscursosAdminScreen()),
          ),
        ),
        QuickToolItem(
          title: 'Partes 10 min',
          icon: Icons.timer_10,
          customLabel: '10s',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PartesListScreen()),
          ),
        ),
        QuickToolItem(
          title: 'Timer Pro',
          icon: Icons.timer,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PresentationTimerProScreen(),
            ),
          ),
        ),
        QuickToolItem(
          title: 'Meu Estúdio',
          icon: Icons.style,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const StudyStudioListScreen(),
            ),
          ),
        ),
      ];

  static List<QuickToolItem> extraTools(BuildContext context) => [
        QuickToolItem(
          title: 'Ensaio be-T',
          icon: Icons.mic,
          iconColor: AppTheme.secondaryColor,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const VoiceRehearsalScreen()),
          ),
        ),
        QuickToolItem(
          title: 'Autoavaliação be-T',
          icon: Icons.fact_check,
          iconColor: AppTheme.accentColor,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SelfAssessmentScreen()),
          ),
        ),
        QuickToolItem(
          title: 'Masterclass',
          icon: Icons.school,
          iconColor: Colors.blueGrey,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ShinyashikiMasterclassScreen(),
            ),
          ),
        ),
      ];

  void _showAllTools(BuildContext context) {
    final extras = extraTools(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.shellSurfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Todas as ferramentas',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...extras.map(
                  (tool) => ListTile(
                    leading: Icon(
                      tool.icon,
                      color: tool.iconColor ?? AppTheme.shellAccentTeal,
                    ),
                    title: Text(tool.title),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      tool.onTap();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tools = primaryTools(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Ferramentas rápidas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: () => _showAllTools(context),
              child: const Text(
                'Ver todas',
                style: TextStyle(color: AppTheme.shellAccentTeal),
              ),
            ),
          ],
        ),
        Text(
          'Acesse o que você mais usa',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            return _QuickToolTile(item: tools[index]);
          },
        ),
      ],
    );
  }
}

class _QuickToolTile extends StatefulWidget {
  final QuickToolItem item;

  const _QuickToolTile({required this.item});

  @override
  State<_QuickToolTile> createState() => _QuickToolTileState();
}

class _QuickToolTileState extends State<_QuickToolTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.item.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.shellSurfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.shellAccentTeal.withValues(alpha: 0.15),
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.item.customLabel != null)
                Text(
                  widget.item.customLabel!,
                  style: const TextStyle(
                    color: AppTheme.shellAccentTeal,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Icon(
                  widget.item.icon,
                  color: widget.item.iconColor ?? AppTheme.shellAccentTeal,
                  size: 28,
                ),
              const SizedBox(height: 8),
              Text(
                widget.item.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.shellTextPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

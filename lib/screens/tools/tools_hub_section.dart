import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'assentinel/assentinel_screen.dart';
import 'discursos/discursos_admin_screen.dart';
import 'meeting/meeting_hub_screen.dart';
import 'partes/partes_list_screen.dart';
import 'timer/presentation_timer_pro_screen.dart';
import 'studio/study_studio_list_screen.dart';
import 'bet_guide/self_assessment_screen.dart';
import 'shinyashiki_masterclass/shinyashiki_masterclass_screen.dart';

class ToolsHubSection extends StatelessWidget {
  const ToolsHubSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ferramentas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Central da reunião, Sentinela, discursos, partes e treino',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.25,
          children: [
            _ToolCard(
              title: 'Central da Reunião',
              subtitle: 'Comentários + respostas IA',
              icon: Icons.event_note,
              color: AppTheme.primaryColor,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MeetingHubScreen()),
              ),
            ),
            _ToolCard(
              title: 'A Sentinela',
              subtitle: 'Estudos e comentários',
              icon: Icons.auto_stories,
              color: Colors.teal,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AssentinelScreen()),
              ),
            ),
            _ToolCard(
              title: 'Discursos',
              subtitle: 'Listar · adicionar · IA',
              icon: Icons.record_voice_over,
              color: Colors.indigo,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DiscursosAdminScreen(),
                ),
              ),
            ),
            _ToolCard(
              title: 'Partes 10 min',
              subtitle: 'Esboço · apresentar',
              icon: Icons.timer_10,
              color: Colors.deepOrange,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PartesListScreen()),
              ),
            ),
            _ToolCard(
              title: 'Timer Pro',
              subtitle: 'Split e alertas visuais',
              icon: Icons.timer,
              color: AppTheme.secondaryColor,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PresentationTimerProScreen(),
                ),
              ),
            ),
            _ToolCard(
              title: 'Meu Estúdio',
              subtitle: 'Tópicos e flashcards',
              icon: Icons.style,
              color: Colors.purple,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StudyStudioListScreen(),
                ),
              ),
            ),
            _ToolCard(
              title: 'Autoavaliação be-T',
              subtitle: '53 características',
              icon: Icons.fact_check,
              color: AppTheme.accentColor,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SelfAssessmentScreen()),
              ),
            ),
            _ToolCard(
              title: 'Masterclass',
              subtitle: 'Método Shinyashiki',
              icon: Icons.school,
              color: Colors.blueGrey,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ShinyashikiMasterclassScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 26),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                    ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/oratory_characteristic.dart';
import '../../../providers/oratory_guide_provider.dart';

class CharacteristicDetailScreen extends StatelessWidget {
  final OratoryCharacteristic characteristic;

  const CharacteristicDetailScreen({
    super.key,
    required this.characteristic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${characteristic.id}. ${characteristic.title}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text(characteristic.category),
                backgroundColor: AppTheme.accentColor.withValues(alpha: 0.15),
              ),
              Chip(
                label: Text('Pág. ${characteristic.pageReference}'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionBlock(
            icon: Icons.play_arrow,
            title: 'O que fazer',
            color: Colors.blue,
            body: characteristic.action,
          ),
          const SizedBox(height: 16),
          _SectionBlock(
            icon: Icons.lightbulb,
            title: 'Por que é importante',
            color: AppTheme.accentColor,
            body: characteristic.importance,
          ),
          const SizedBox(height: 24),
          Consumer<OratoryGuideProvider>(
            builder: (context, provider, _) {
              final isFocus =
                  provider.isWeeklyFocus(characteristic.id);
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    provider.toggleWeeklyFocus(characteristic.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFocus
                              ? 'Removido do foco da semana.'
                              : 'Adicionado ao foco da semana.',
                        ),
                      ),
                    );
                  },
                  icon: Icon(isFocus ? Icons.star : Icons.star_border),
                  label: Text(
                    isFocus
                        ? 'No foco da semana'
                        : 'Praticar esta característica',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String body;

  const _SectionBlock({
    required this.icon,
    required this.title,
    required this.color,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(body),
        ],
      ),
    );
  }
}

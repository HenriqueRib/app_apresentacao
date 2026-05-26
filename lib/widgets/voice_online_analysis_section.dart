import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../models/voice_rehearsal_online_analysis.dart';

class VoiceOnlineAnalysisSection extends StatelessWidget {
  final VoiceRehearsalOnlineAnalysis analysis;
  final bool dense;

  const VoiceOnlineAnalysisSection({
    super.key,
    required this.analysis,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat.yMMMd('pt_BR').add_Hm().format(analysis.analyzedAt);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Análise online',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _Disclaimer(text: analysis.disclaimer),
            if (analysis.pontosFortes.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ListBlock(
                title: 'Pontos fortes',
                icon: Icons.thumb_up_outlined,
                color: AppTheme.successColor,
                items: analysis.pontosFortes,
              ),
            ],
            if (analysis.pontosMelhorar.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ListBlock(
                title: 'Pontos a melhorar',
                icon: Icons.trending_up,
                color: AppTheme.warningColor,
                items: analysis.pontosMelhorar,
              ),
            ],
            if (analysis.proximosPassos.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ListBlock(
                title: 'Próximos passos',
                icon: Icons.checklist_rtl,
                color: AppTheme.primaryColor,
                items: analysis.proximosPassos,
              ),
            ],
            if (analysis.estruturaComentarios.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Estrutura da fala',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              ...analysis.estruturaComentarios.map(_StructureRow.new),
            ],
            if (analysis.caracteristicasBeT.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Características be-T (online)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              ...analysis.caracteristicasBeT.map(_CharacteristicRow.new),
            ],
          ],
    );

    if (dense) {
      return body;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: body,
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  final String text;

  const _Disclaimer({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, height: 1.35, color: AppTheme.textSecondary),
      ),
    );
  }
}

class _ListBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _ListBlock({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: color)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StructureRow extends StatelessWidget {
  final VoiceRehearsalOnlineStructureComment comment;

  const _StructureRow(this.comment);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _sectionLabel(comment.secao),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            comment.comentario,
            style: const TextStyle(fontSize: 12, height: 1.35),
          ),
        ],
      ),
    );
  }

  String _sectionLabel(String secao) {
    return switch (secao.toLowerCase()) {
      'intro' || 'introducao' => 'Introdução',
      'corpo' => 'Corpo',
      'conclusao' => 'Conclusão',
      _ => secao,
    };
  }
}

class _CharacteristicRow extends StatelessWidget {
  final VoiceRehearsalOnlineCharacteristic item;

  const _CharacteristicRow(this.item);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.titulo ?? 'Característica #${item.id}'} · ${item.nota}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          if (item.evidencia != null && item.evidencia!.isNotEmpty)
            Text(
              item.evidencia!,
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          if (item.sugestao != null && item.sugestao!.isNotEmpty)
            Text(
              item.sugestao!,
              style: const TextStyle(fontSize: 11, height: 1.35),
            ),
        ],
      ),
    );
  }
}

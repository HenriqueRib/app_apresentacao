import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/weekly_comment_item.dart';
import '../../../providers/meeting_hub_provider.dart';
import '../../../services/api_service.dart';

/// Aba Comentários: GET `/v1/comentarios/semanal` + POST `/wol/comentarios` (gerar).
class MeetingComentariosTab extends StatefulWidget {
  const MeetingComentariosTab({super.key});

  @override
  State<MeetingComentariosTab> createState() => _MeetingComentariosTabState();
}

class _MeetingComentariosTabState extends State<MeetingComentariosTab> {
  late Future<WeeklyCommentsResponse> _future;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _future = ApiService().getWeeklyComments();
  }

  void _refresh() {
    setState(() {
      _future = ApiService().getWeeklyComments();
    });
  }

  Future<void> _generateComments() async {
    setState(() => _isGenerating = true);
    try {
      final count = await ApiService().generateWeeklyComments();
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0
                ? '$count comentário(s) gerado(s).'
                : 'Geração concluída. Atualizando lista…',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeeklyCommentsResponse>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        final items = data.comentarios;

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.semana.isNotEmpty)
                        Text(
                          data.semana,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      if (data.textoJoiaEspiritual.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Joia: ${data.textoJoiaEspiritual}'),
                      ],
                      Text(
                        '${items.length} comentário(s)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: _isGenerating ? null : _generateComments,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            _isGenerating
                                ? 'Gerando comentários…'
                                : 'Gerar comentários',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Sem comentários para esta semana.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _CommentCard(
                      weekKey:
                          data.semana.isEmpty ? 'semana_atual' : data.semana,
                      index: index,
                      item: items[index],
                    ),
                    childCount: items.length,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CommentCard extends StatefulWidget {
  final String weekKey;
  final int index;
  final WeeklyCommentItem item;

  const _CommentCard({
    required this.weekKey,
    required this.index,
    required this.item,
  });

  @override
  State<_CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<_CommentCard> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.item.comentario;

    return Consumer<MeetingHubProvider>(
      builder: (context, provider, _) {
        final note = provider.getNote(widget.weekKey, widget.index);
        final isFavorite = note?.isFavorite ?? false;
        if (_noteController.text.isEmpty &&
            (note?.personalNote.isNotEmpty ?? false)) {
          _noteController.text = note!.personalNote;
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: isFavorite
                  ? AppTheme.secondaryColor
                  : AppTheme.primaryColor,
              foregroundColor: Colors.white,
              child: Text('${widget.index + 1}'),
            ),
            title: Text('Comentário ${widget.index + 1}'),
            subtitle: Text(
              text.length > 60 ? '${text.substring(0, 60)}...' : text,
            ),
            trailing: IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? AppTheme.secondaryColor : null,
              ),
              onPressed: () => provider.toggleFavorite(
                widget.weekKey,
                widget.index,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.item.tags.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        children: widget.item.tags
                            .map(
                              (t) => Chip(
                                label: Text(t, style: const TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                      ),
                    Text(text),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Nota da prancheta',
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          provider.setPersonalNote(
                            widget.weekKey,
                            widget.index,
                            _noteController.text.trim(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nota salva.')),
                          );
                        },
                        child: const Text('Salvar nota'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

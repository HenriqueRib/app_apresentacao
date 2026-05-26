import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/voice_rehearsal_attempt.dart';
import '../../../providers/voice_rehearsal_history_provider.dart';
import '../../../utils/voice_rehearsal_ui.dart' show formatVoiceRehearsalDateTime, voiceRehearsalScoreColor;
import '../../../widgets/voice_rehearsal_evolution_chart.dart';
import 'voice_rehearsal_compare_screen.dart';
import 'voice_rehearsal_history_detail_screen.dart';

class VoiceRehearsalHistoryScreen extends StatefulWidget {
  const VoiceRehearsalHistoryScreen({super.key});

  @override
  State<VoiceRehearsalHistoryScreen> createState() =>
      _VoiceRehearsalHistoryScreenState();
}

class _VoiceRehearsalHistoryScreenState
    extends State<VoiceRehearsalHistoryScreen> {
  bool _compareMode = false;
  final Set<String> _selectedIds = {};
  String? _seriesFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceRehearsalHistoryProvider>().load();
    });
  }

  void _toggleCompareMode() {
    setState(() {
      _compareMode = !_compareMode;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else if (_selectedIds.length < 2) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(_selectedIds.first);
        _selectedIds.add(id);
      }
    });
  }

  void _openCompare(List<VoiceRehearsalAttempt> attempts) {
    if (_selectedIds.length != 2) return;

    final allAttempts = context.read<VoiceRehearsalHistoryProvider>().attempts;
    final selected = allAttempts
        .where((a) => _selectedIds.contains(a.id))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    if (selected.length != 2) return;

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => VoiceRehearsalCompareScreen(
          older: selected.first,
          newer: selected.last,
        ),
      ),
    )
        .then((_) {
      if (mounted) {
        setState(() {
          _compareMode = false;
          _selectedIds.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_compareMode ? 'Selecione 2 ensaios' : 'Histórico de ensaios'),
        actions: [
          Consumer<VoiceRehearsalHistoryProvider>(
            builder: (context, provider, _) {
              if (provider.attempts.length < 2) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: _compareMode ? 'Cancelar' : 'Comparar ensaios',
                icon: Icon(_compareMode ? Icons.close : Icons.compare_arrows),
                onPressed: _toggleCompareMode,
              );
            },
          ),
        ],
      ),
      body: Consumer<VoiceRehearsalHistoryProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.attempts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Nenhum ensaio registrado ainda.\n'
                  'Faça um treino ou gravação no Ensaio be-T — '
                  'cada tentativa aparece aqui com o relatório completo.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
            );
          }

          final seriesNames = provider.attempts
              .map((a) => a.seriesName?.trim())
              .whereType<String>()
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          final filtered = _seriesFilter == null
              ? provider.attempts
              : provider.attempts
                  .where((a) => a.seriesName?.trim() == _seriesFilter)
                  .toList();

          return Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  _compareMode && _selectedIds.length == 2 ? 88 : 16,
                ),
                itemCount: filtered.length + 1 + (seriesNames.isNotEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  if (seriesNames.isNotEmpty && index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('Todas'),
                              selected: _seriesFilter == null,
                              onSelected: (_) =>
                                  setState(() => _seriesFilter = null),
                            ),
                            const SizedBox(width: 6),
                            ...seriesNames.map(
                              (name) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  label: Text(name),
                                  selected: _seriesFilter == name,
                                  onSelected: (_) =>
                                      setState(() => _seriesFilter = name),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final chartIndex = seriesNames.isNotEmpty ? 1 : 0;
                  if (index == chartIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: VoiceRehearsalEvolutionChart(
                        attempts: filtered,
                      ),
                    );
                  }
                  final attempt = filtered[index - chartIndex - 1];
                  final selected = _selectedIds.contains(attempt.id);

                  if (_compareMode) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: selected
                            ? BorderSide(
                                color: AppTheme.primaryColor, width: 2)
                            : BorderSide.none,
                      ),
                      child: CheckboxListTile(
                        value: selected,
                        onChanged: (_) => _toggleSelection(attempt.id),
                        secondary: CircleAvatar(
                          backgroundColor:
                              voiceRehearsalScoreColor(attempt.finalScore),
                          child: Text(
                            attempt.finalScore.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          attempt.listTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${formatVoiceRehearsalDateTime(attempt.createdAt)} · '
                          '${attempt.modeLabel} · '
                          '${_formatDuration(attempt.durationSeconds)}'
                          '${attempt.seriesName != null && attempt.seriesName!.isNotEmpty ? ' · ${attempt.seriesName}' : ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    );
                  }

                  return Dismissible(
                    key: ValueKey(attempt.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) => _confirmDelete(context, attempt),
                    onDismissed: (_) => provider.delete(attempt.id),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              voiceRehearsalScoreColor(attempt.finalScore),
                          child: Text(
                            attempt.finalScore.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          attempt.listTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${formatVoiceRehearsalDateTime(attempt.createdAt)}\n'
                          '${attempt.modeLabel} · '
                          '${_formatDuration(attempt.durationSeconds)} · '
                          'Nota ${attempt.finalScore.toStringAsFixed(1)}/10'
                          '${attempt.seriesName != null && attempt.seriesName!.isNotEmpty ? '\n${attempt.seriesName}' : ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final ok = await _confirmDelete(context, attempt);
                            if (ok == true && context.mounted) {
                              await provider.delete(attempt.id);
                            }
                          },
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VoiceRehearsalHistoryDetailScreen(
                              attemptId: attempt.id,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_compareMode)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    child: FilledButton.icon(
                      onPressed: _selectedIds.length == 2
                          ? () => _openCompare(provider.attempts)
                          : null,
                      icon: const Icon(Icons.compare_arrows),
                      label: Text(
                        _selectedIds.length == 2
                            ? 'Comparar selecionados'
                            : 'Selecione mais ${_selectedIds.isEmpty ? 2 : 1}',
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    VoiceRehearsalAttempt attempt,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir ensaio?'),
        content: Text('Remover "${attempt.listTitle}" do histórico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/admin_discurso.dart';
import '../../../providers/discurso_admin_provider.dart';
import '../../../widgets/content_block_panel.dart';
import 'discurso_form_screen.dart';

class DiscursoDetailScreen extends StatefulWidget {
  final int discursoId;

  const DiscursoDetailScreen({super.key, required this.discursoId});

  @override
  State<DiscursoDetailScreen> createState() => _DiscursoDetailScreenState();
}

class _DiscursoDetailScreenState extends State<DiscursoDetailScreen> {
  AdminDiscurso? _discurso;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final d = await context.read<DiscursoAdminProvider>().loadDetail(
          widget.discursoId,
        );
    if (mounted) {
      setState(() {
        _discurso = d;
        _loading = false;
      });
    }
  }

  void _improveManuscriptDialog() {
    final d = _discurso;
    if (d == null) return;
    final instrCtrl = TextEditingController();
    final textCtrl = TextEditingController(text: d.manuscritoCompleto);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Melhorar manuscrito (IA)'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: instrCtrl,
                decoration: const InputDecoration(
                  labelText: 'Instrução *',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Manuscrito atual',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await context
                  .read<DiscursoAdminProvider>()
                  .improveManuscript(
                    d.id,
                    instrCtrl.text.trim(),
                    textCtrl.text,
                  );
              if (result != null) await _load();
            },
            child: const Text('Melhorar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Discurso')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final d = _discurso;
    if (d == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Discurso')),
        body: const Center(child: Text('Não foi possível carregar.')),
      );
    }

    final provider = context.watch<DiscursoAdminProvider>();
    final busy = provider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(d.tema),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DiscursoFormScreen(existing: d),
                ),
              );
              await _load();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (d.objetivo != null && d.objetivo!.isNotEmpty)
            Text('Objetivo: ${d.objetivo}'),
          const SizedBox(height: 12),
          ContentBlockPanel(
            title: 'Esboço original',
            content: d.esbocoOriginal,
            accentColor: Colors.grey,
            canGenerate: false,
          ),
          const SizedBox(height: 12),
          ContentBlockPanel(
            title: 'Manuscrito completo',
            content: d.manuscritoCompleto,
            isLoading: busy && provider.loadingAction == 'manuscrito',
            onGenerate: () async {
              await provider.generateManuscript(d.id);
              await _load();
            },
            onImprove: d.manuscritoCompleto.isNotEmpty
                ? _improveManuscriptDialog
                : null,
          ),
          const SizedBox(height: 12),
          ContentBlockPanel(
            title: 'Guia prático',
            content: d.guide,
            accentColor: AppTheme.secondaryColor,
            isLoading: busy && provider.loadingAction == 'guia',
            generateLabel: 'Gerar guia',
            onGenerate: () async {
              await provider.generateGuide(d.id);
              await _load();
            },
            onImprove: d.guide != null && d.guide!.isNotEmpty
                ? () async {
                    await provider.generateGuide(d.id);
                    await _load();
                  }
                : null,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: d.manuscritoCompleto.isEmpty
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Use o Modo Palco do ciclo principal com um discurso vinculado, ou leia o manuscrito em Visualizar.',
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.record_voice_over),
            label: const Text('Apresentar (manuscrito)'),
          ),
        ],
      ),
    );
  }
}

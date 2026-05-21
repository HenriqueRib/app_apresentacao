import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/discurso_admin_provider.dart';
import 'discurso_detail_screen.dart';
import 'discurso_form_screen.dart';

class DiscursosAdminScreen extends StatefulWidget {
  const DiscursosAdminScreen({super.key});

  @override
  State<DiscursosAdminScreen> createState() => _DiscursosAdminScreenState();
}

class _DiscursosAdminScreenState extends State<DiscursosAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscursoAdminProvider>().load();
    });
  }

  void _showSettings(BuildContext context, DiscursoAdminProvider provider) {
    final geral = TextEditingController(text: provider.promptGeral);
    final guia = TextEditingController(text: provider.promptGuia);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Instruções de geração (IA)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: geral,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Prompt manuscrito',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: guia,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Prompt guia prático',
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
            onPressed: () {
              provider.saveSettings(geral.text, guia.text);
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Discursos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final provider = context.read<DiscursoAdminProvider>();
              await provider.refreshSettings();
              if (!context.mounted) return;
              _showSettings(context, provider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const DiscursoFormScreen()),
          );
          if (created == true && mounted) {
            context.read<DiscursoAdminProvider>().load();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo discurso'),
      ),
      body: Consumer<DiscursoAdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.discursos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.discursos.isEmpty) {
            return const Center(
              child: Text('Nenhum discurso no servidor. Adicione um novo.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.discursos.length,
            itemBuilder: (context, index) {
              final d = provider.discursos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(d.tema.isEmpty ? 'Sem título' : d.tema),
                  subtitle: Text(
                    [
                      if (d.objetivo != null && d.objetivo!.isNotEmpty)
                        d.objetivo,
                      if (d.manuscritoCompleto.isNotEmpty) 'Manuscrito ✓',
                      if (d.guide != null && d.guide!.isNotEmpty) 'Guia ✓',
                    ].whereType<String>().join(' · '),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'open') {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DiscursoDetailScreen(discursoId: d.id),
                          ),
                        );
                        if (context.mounted) provider.load();
                      } else if (v == 'delete') {
                        await provider.deleteDiscurso(d.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'open',
                        child: Text('Abrir / Gerar / Melhorar'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Excluir'),
                      ),
                    ],
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DiscursoDetailScreen(discursoId: d.id),
                      ),
                    );
                    if (context.mounted) provider.load();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/parte_provider.dart';
import 'parte_detail_screen.dart';
import 'parte_form_screen.dart';

class PartesListScreen extends StatefulWidget {
  const PartesListScreen({super.key});

  @override
  State<PartesListScreen> createState() => _PartesListScreenState();
}

class _PartesListScreenState extends State<PartesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParteProvider>().load();
    });
  }

  void _showSettings(BuildContext context, ParteProvider provider) {
    final ctrl = TextEditingController(text: provider.promptGeral);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Instrução de geração (IA)'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Prompt geral'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.saveSettings(ctrl.text.trim());
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
        title: const Text('Partes da Reunião'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final provider = context.read<ParteProvider>();
              await provider.refreshSettings();
              if (!context.mounted) return;
              _showSettings(context, provider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ParteFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova parte'),
      ),
      body: Consumer<ParteProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.partes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.partes.isEmpty) {
            return const Center(
              child: Text('Nenhuma parte cadastrada. Adicione uma nova.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.partes.length,
            itemBuilder: (context, index) {
              final p = provider.partes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    child: Text('${p.topicos.length}'),
                  ),
                  title: Text(p.tema),
                  subtitle: Text(
                    p.esbocoManuscrito != null && p.esbocoManuscrito!.isNotEmpty
                        ? 'Esboço gerado · ${p.topicos.length} tópico(s)'
                        : '${p.topicos.length} tópico(s) · sem esboço',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ParteDetailScreen(parteId: p.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/parte_provider.dart';

class ParteEsbocoEditorScreen extends StatefulWidget {
  final String parteId;

  const ParteEsbocoEditorScreen({super.key, required this.parteId});

  @override
  State<ParteEsbocoEditorScreen> createState() => _ParteEsbocoEditorScreenState();
}

class _ParteEsbocoEditorScreenState extends State<ParteEsbocoEditorScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final parte = context.read<ParteProvider>().getParteById(widget.parteId);
      if (parte != null && mounted) {
        _controller.text = parte.esbocoManuscrito ?? '';
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<ParteProvider>();
    final parte = provider.getParteById(widget.parteId);
    if (parte == null) return;
    await provider.updateParte(
      parte.copyWith(esbocoManuscrito: _controller.text),
    );
    if (mounted) Navigator.pop(context);
  }

  void _improve() {
    final instr = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Melhorar com IA'),
        content: TextField(
          controller: instr,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Instrução'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<ParteProvider>().improveEsboco(
                    widget.parteId,
                    instr.text.trim(),
                  );
              final updated =
                  context.read<ParteProvider>().getParteById(widget.parteId);
              if (updated?.esbocoManuscrito != null) {
                _controller.text = updated!.esbocoManuscrito!;
              }
            },
            child: const Text('Melhorar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar esboço'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            onPressed: _improve,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _controller,
          maxLines: null,
          expands: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Esboço manuscrito...',
          ),
        ),
      ),
    );
  }
}

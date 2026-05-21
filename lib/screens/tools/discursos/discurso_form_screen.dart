import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/admin_discurso.dart';
import '../../../providers/discurso_admin_provider.dart';

class DiscursoFormScreen extends StatefulWidget {
  final AdminDiscurso? existing;

  const DiscursoFormScreen({super.key, this.existing});

  @override
  State<DiscursoFormScreen> createState() => _DiscursoFormScreenState();
}

class _DiscursoFormScreenState extends State<DiscursoFormScreen> {
  late final TextEditingController _tema;
  late final TextEditingController _data;
  late final TextEditingController _numero;
  late final TextEditingController _cantico;
  late final TextEditingController _objetivo;
  late final TextEditingController _esboco;
  late final TextEditingController _manuscrito;
  late final TextEditingController _fontes;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _tema = TextEditingController(text: e?.tema ?? '');
    _data = TextEditingController(text: e?.data ?? '');
    _numero = TextEditingController(text: e?.numero ?? '');
    _cantico = TextEditingController(text: e?.cantico ?? '');
    _objetivo = TextEditingController(text: e?.objetivo ?? '');
    _esboco = TextEditingController(text: e?.esbocoOriginal ?? '');
    _manuscrito = TextEditingController(text: e?.manuscritoCompleto ?? '');
    _fontes = TextEditingController(text: e?.fonteMaterias ?? '');
  }

  @override
  void dispose() {
    _tema.dispose();
    _data.dispose();
    _numero.dispose();
    _cantico.dispose();
    _objetivo.dispose();
    _esboco.dispose();
    _manuscrito.dispose();
    _fontes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_tema.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o tema.')),
      );
      return;
    }
    final provider = context.read<DiscursoAdminProvider>();
    final draft = AdminDiscurso(
      id: widget.existing?.id ?? 0,
      tema: _tema.text.trim(),
      data: _data.text.trim(),
      numero: _numero.text.trim(),
      cantico: _cantico.text.trim(),
      objetivo: _objetivo.text.trim(),
      esbocoOriginal: _esboco.text.trim(),
      manuscritoCompleto: _manuscrito.text.trim(),
      fonteMaterias: _fontes.text.trim(),
      guide: widget.existing?.guide,
    );

    if (widget.existing != null) {
      final ok = await provider.updateDiscurso(draft);
      if (mounted) Navigator.pop(context, ok);
    } else {
      final created = await provider.createDiscurso(draft);
      if (mounted) Navigator.pop(context, created != null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar discurso' : 'Novo discurso'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _tema,
            decoration: const InputDecoration(labelText: 'Tema *'),
          ),
          TextField(
            controller: _data,
            decoration: const InputDecoration(
              labelText: 'Data',
              hintText: 'AAAA-MM-DD',
            ),
          ),
          TextField(
            controller: _numero,
            decoration: const InputDecoration(labelText: 'Número'),
          ),
          TextField(
            controller: _cantico,
            decoration: const InputDecoration(labelText: 'Cântico'),
          ),
          TextField(
            controller: _objetivo,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Objetivo'),
          ),
          TextField(
            controller: _esboco,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Esboço original'),
          ),
          TextField(
            controller: _manuscrito,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Manuscrito completo'),
          ),
          TextField(
            controller: _fontes,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Fonte de matérias'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            child: Text(isEdit ? 'Salvar alterações' : 'Adicionar discurso'),
          ),
        ],
      ),
    );
  }
}

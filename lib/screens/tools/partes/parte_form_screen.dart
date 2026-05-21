import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/parte.dart';
import '../../../providers/parte_provider.dart';

class ParteFormScreen extends StatefulWidget {
  final Parte? existing;

  const ParteFormScreen({super.key, this.existing});

  @override
  State<ParteFormScreen> createState() => _ParteFormScreenState();
}

class _ParteFormScreenState extends State<ParteFormScreen> {
  late final TextEditingController _tema;
  late final TextEditingController _conteudo;
  final List<_TopicoRow> _topicos = [];

  @override
  void initState() {
    super.initState();
    _tema = TextEditingController(text: widget.existing?.tema ?? '');
    _conteudo = TextEditingController(text: widget.existing?.conteudoOriginal ?? '');
    if (widget.existing != null) {
      for (final t in widget.existing!.topicos) {
        _topicos.add(_TopicoRow(
          descricao: TextEditingController(text: t.descricao),
          texto: TextEditingController(text: t.texto ?? ''),
          fonte: TextEditingController(text: t.fonte ?? ''),
        ));
      }
    } else {
      _addTopico();
    }
  }

  void _addTopico() {
    setState(() {
      _topicos.add(_TopicoRow());
    });
  }

  @override
  void dispose() {
    _tema.dispose();
    _conteudo.dispose();
    for (final t in _topicos) {
      t.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_tema.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o tema.')),
      );
      return;
    }
    final topicos = <ParteTopico>[];
    for (final row in _topicos) {
      if (row.descricao.text.trim().isEmpty) continue;
      topicos.add(ParteTopico(
        descricao: row.descricao.text.trim(),
        texto: row.texto.text.trim().isEmpty ? null : row.texto.text.trim(),
        fonte: row.fonte.text.trim().isEmpty ? null : row.fonte.text.trim(),
      ));
    }
    if (topicos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos um tópico.')),
      );
      return;
    }

    final provider = context.read<ParteProvider>();
    if (widget.existing != null) {
      await provider.updateParte(
        widget.existing!.copyWith(
          tema: _tema.text.trim(),
          topicos: topicos,
          conteudoOriginal: _conteudo.text.trim(),
        ),
      );
    } else {
      await provider.createParte(
        tema: _tema.text.trim(),
        topicos: topicos,
        conteudoOriginal: _conteudo.text.trim(),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Nova parte' : 'Editar parte'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _tema,
            decoration: const InputDecoration(labelText: 'Tema *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _conteudo,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Conteúdo original'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tópicos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: _addTopico,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          ..._topicos.asMap().entries.map((entry) {
            final i = entry.key;
            final row = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Tópico ${i + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        if (_topicos.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() {
                                row.dispose();
                                _topicos.removeAt(i);
                              });
                            },
                          ),
                      ],
                    ),
                    TextField(
                      controller: row.descricao,
                      decoration: const InputDecoration(
                        labelText: 'Descrição *',
                      ),
                    ),
                    TextField(
                      controller: row.texto,
                      decoration: const InputDecoration(
                        labelText: 'Referência bíblica',
                      ),
                    ),
                    TextField(
                      controller: row.fonte,
                      decoration: const InputDecoration(
                        labelText: 'Fonte publicação',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

class _TopicoRow {
  final TextEditingController descricao;
  final TextEditingController texto;
  final TextEditingController fonte;

  _TopicoRow({
    TextEditingController? descricao,
    TextEditingController? texto,
    TextEditingController? fonte,
  })  : descricao = descricao ?? TextEditingController(),
        texto = texto ?? TextEditingController(),
        fonte = fonte ?? TextEditingController();

  void dispose() {
    descricao.dispose();
    texto.dispose();
    fonte.dispose();
  }
}

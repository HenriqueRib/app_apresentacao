import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/speech.dart';
import '../../providers/speech_provider.dart';
import '../../services/characteristics_service.dart';

class SpeechPlanningDetailsScreen extends StatefulWidget {
  final Speech speech;

  const SpeechPlanningDetailsScreen({
    super.key,
    required this.speech,
  });

  @override
  State<SpeechPlanningDetailsScreen> createState() => _SpeechPlanningDetailsScreenState();
}

class _SpeechPlanningDetailsScreenState extends State<SpeechPlanningDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _objectiveController;
  late TextEditingController _themeController;
  late TextEditingController _numberController;
  late TextEditingController _songController;
  late SpeechType _type;
  int? _focusCharacteristicId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.speech.title);
    _objectiveController = TextEditingController(text: widget.speech.centralObjective);
    _themeController = TextEditingController(text: widget.speech.theme);
    _numberController = TextEditingController(text: widget.speech.number);
    _songController = TextEditingController(text: widget.speech.song);
    _type = widget.speech.type;
    _focusCharacteristicId = widget.speech.focusCharacteristicId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _objectiveController.dispose();
    _themeController.dispose();
    _numberController.dispose();
    _songController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = widget.speech.copyWith(
      title: _titleController.text,
      centralObjective: _objectiveController.text,
      theme: _themeController.text,
      number: _numberController.text,
      song: _songController.text,
      type: _type,
      focusCharacteristicId: _focusCharacteristicId,
    );

    await context.read<SpeechProvider>().updateSpeech(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Planejamento salvo com sucesso!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final characteristics = CharacteristicsService.instance.allCharacteristics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etapa 1: Planejar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Informações Básicas'),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título do Registro (Interno)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _themeController,
              decoration: const InputDecoration(labelText: 'Tema do Discurso'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numberController,
                    decoration: const InputDecoration(labelText: 'Número'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _songController,
                    decoration: const InputDecoration(labelText: 'Cântico'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Configuração e Foco'),
            const SizedBox(height: 12),
            DropdownButtonFormField<SpeechType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Tipo de Discurso'),
              items: const [
                DropdownMenuItem(value: SpeechType.student10min, child: Text('Estudante (10 min)')),
                DropdownMenuItem(value: SpeechType.public30min, child: Text('Público (30 min)')),
              ],
              onChanged: (val) => setState(() => _type = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              isExpanded: true,
              value: _focusCharacteristicId,
              decoration: const InputDecoration(labelText: 'Característica em Foco'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Nenhuma', overflow: TextOverflow.ellipsis),
                ),
                ...characteristics.map(
                  (c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      '${c.id}. ${c.title}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
              selectedItemBuilder: (context) => [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Nenhuma', overflow: TextOverflow.ellipsis),
                ),
                ...characteristics.map(
                  (c) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${c.id}. ${c.title}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
              onChanged: (val) => setState(() => _focusCharacteristicId = val),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Objetivo Central'),
            const SizedBox(height: 12),
            TextField(
              controller: _objectiveController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'O que você deseja alcançar com este discurso?',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text('Salvar Planejamento'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

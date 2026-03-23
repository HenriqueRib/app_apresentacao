import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../models/speech.dart';
import '../../providers/speech_provider.dart';
import '../../services/characteristics_service.dart';

class OutlineEditorScreen extends StatefulWidget {
  final Speech speech;

  const OutlineEditorScreen({
    super.key,
    required this.speech,
  });

  @override
  State<OutlineEditorScreen> createState() => _OutlineEditorScreenState();
}

class _OutlineEditorScreenState extends State<OutlineEditorScreen> {
  late SpeechOutline _outline;
  final _uuid = const Uuid();

  final _introController = TextEditingController();
  final _conclusionController = TextEditingController();
  final List<_MainPointControllers> _pointControllers = [];

  @override
  void initState() {
    super.initState();
    _outline = widget.speech.outline ?? const SpeechOutline();
    _loadControllers();
  }

  void _loadControllers() {
    _introController.text = _outline.introduction;
    _conclusionController.text = _outline.conclusion;

    for (final point in _outline.mainPoints) {
      _pointControllers.add(_MainPointControllers(point));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esboço do Discurso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveOutline,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildObjectiveHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProgressCard(),
                const SizedBox(height: 16),
                _buildIntroductionSection(),
                const SizedBox(height: 16),
                _buildMainPointsSection(),
                const SizedBox(height: 16),
                _buildConclusionSection(),
                const SizedBox(height: 16),
                _buildBiblicalTextsSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMainPoint,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Ponto'),
      ),
    );
  }

  Widget _buildObjectiveHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.speech.type == SpeechType.student10min
                      ? '10 min'
                      : '30 min',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const Spacer(),
              if (widget.speech.focusCharacteristicId != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Foco: ${CharacteristicsService.instance.getCharacteristicById(widget.speech.focusCharacteristicId!)?.title ?? ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Objetivo: ${widget.speech.centralObjective}',
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final progress = _calculateProgress();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progresso do Esboço',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 8),
            Text(
              'Máximo: ${widget.speech.maxMainPoints} pontos principais',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroductionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Text(
                  'Introdução',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  widget.speech.type == SpeechType.student10min
                      ? '~1 min'
                      : '~3 min',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Dica: Desperte interesse imediato com uma pergunta instigante ou cenário real.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _introController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escreva sua introdução aqui...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pontos Principais',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _pointControllers.length > widget.speech.maxMainPoints
                    ? AppTheme.errorColor
                    : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_pointControllers.length}/${widget.speech.maxMainPoints}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_pointControllers.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.add_circle_outline,
                    size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Adicione pontos principais',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pointControllers.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _pointControllers.removeAt(oldIndex);
                _pointControllers.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              return _buildMainPointCard(index, key: ValueKey(index));
            },
          ),
      ],
    );
  }

  Widget _buildMainPointCard(int index, {Key? key}) {
    final controllers = _pointControllers[index];
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          child: Text('${index + 1}'),
        ),
        title: TextField(
          controller: controllers.titleController,
          decoration: const InputDecoration(
            hintText: 'Título do ponto',
            border: InputBorder.none,
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              onPressed: () => _removeMainPoint(index),
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controllers.contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Desenvolvimento',
                    hintText: 'Desenvolva o argumento...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controllers.illustrationController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Ilustração',
                    hintText: 'Adicione uma ilustração ou exemplo...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lightbulb_outline),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConclusionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.flag, color: AppTheme.accentColor),
                ),
                const SizedBox(width: 12),
                Text(
                  'Conclusão',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  widget.speech.type == SpeechType.student10min
                      ? '~1 min'
                      : '~3 min',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Dica: Resuma os pontos principais e indique claramente o que a assistência deve fazer.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _conclusionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escreva sua conclusão aqui...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiblicalTextsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.menu_book, color: AppTheme.secondaryColor),
                ),
                const SizedBox(width: 12),
                Text(
                  'Textos Bíblicos (Método L.E.I.A.)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Para cada texto bíblico:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  _buildLeiaItem('L', 'Leia - Leitura exata do texto'),
                  _buildLeiaItem('E', 'Explique - Esclareça o sentido'),
                  _buildLeiaItem('I', 'Ilustre - Use uma analogia'),
                  _buildLeiaItem('A', 'Aplique - Mostre o valor prático'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _addBiblicalText,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Texto Bíblico'),
            ),
            if (_outline.biblicalTexts.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...List.generate(_outline.biblicalTexts.length, (index) {
                final text = _outline.biblicalTexts[index];
                return ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(text.reference),
                  subtitle: Text(
                    text.isLeiaComplete
                        ? 'L.E.I.A. completo'
                        : 'L.E.I.A. incompleto',
                    style: TextStyle(
                      color: text.isLeiaComplete
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editBiblicalText(index),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeiaItem(String letter, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  void _addMainPoint() {
    if (_pointControllers.length >= widget.speech.maxMainPoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Máximo de ${widget.speech.maxMainPoints} pontos atingido'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() {
      _pointControllers.add(_MainPointControllers(
        MainPoint(id: _uuid.v4(), title: ''),
      ));
    });
  }

  void _removeMainPoint(int index) {
    setState(() {
      _pointControllers[index].dispose();
      _pointControllers.removeAt(index);
    });
  }

  void _addBiblicalText() {
    final referenceController = TextEditingController();
    final readController = TextEditingController();
    final explainController = TextEditingController();
    final illustrateController = TextEditingController();
    final applyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adicionar Texto Bíblico',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Referência',
                    hintText: 'Ex: João 3:16',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: readController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'L - Leitura',
                    hintText: 'Texto a ser lido...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: explainController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'E - Explicação',
                    hintText: 'Sentido e contexto...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: illustrateController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'I - Ilustração',
                    hintText: 'Analogia ou exemplo...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: applyController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'A - Aplicação',
                    hintText: 'Valor prático para a vida...',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (referenceController.text.isEmpty) return;

                      final newText = BiblicalText(
                        id: _uuid.v4(),
                        reference: referenceController.text,
                        read: readController.text,
                        explain: explainController.text,
                        illustrate: illustrateController.text,
                        apply: applyController.text,
                      );

                      setState(() {
                        _outline = _outline.copyWith(
                          biblicalTexts: [..._outline.biblicalTexts, newText],
                        );
                      });

                      Navigator.of(context).pop();
                    },
                    child: const Text('Adicionar'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editBiblicalText(int index) {
    final text = _outline.biblicalTexts[index];
    final referenceController = TextEditingController(text: text.reference);
    final readController = TextEditingController(text: text.read);
    final explainController = TextEditingController(text: text.explain);
    final illustrateController = TextEditingController(text: text.illustrate);
    final applyController = TextEditingController(text: text.apply);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editar Texto Bíblico',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: referenceController,
                  decoration: const InputDecoration(labelText: 'Referência'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: readController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'L - Leitura'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: explainController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'E - Explicação'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: illustrateController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'I - Ilustração'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: applyController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'A - Aplicação'),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            final texts =
                                List<BiblicalText>.from(_outline.biblicalTexts);
                            texts.removeAt(index);
                            _outline = _outline.copyWith(biblicalTexts: texts);
                          });
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                        ),
                        child: const Text('Remover'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final updated = text.copyWith(
                            reference: referenceController.text,
                            read: readController.text,
                            explain: explainController.text,
                            illustrate: illustrateController.text,
                            apply: applyController.text,
                          );

                          setState(() {
                            final texts =
                                List<BiblicalText>.from(_outline.biblicalTexts);
                            texts[index] = updated;
                            _outline = _outline.copyWith(biblicalTexts: texts);
                          });

                          Navigator.of(context).pop();
                        },
                        child: const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  double _calculateProgress() {
    int total = 3;
    int filled = 0;
    if (_introController.text.isNotEmpty) filled++;
    if (_pointControllers.isNotEmpty) filled++;
    if (_conclusionController.text.isNotEmpty) filled++;
    return filled / total;
  }

  Future<void> _saveOutline() async {
    final mainPoints = _pointControllers.map((c) {
      return MainPoint(
        id: c.point.id,
        title: c.titleController.text,
        content: c.contentController.text,
        illustrations: c.illustrationController.text.isNotEmpty
            ? [c.illustrationController.text]
            : [],
      );
    }).toList();

    final updatedOutline = _outline.copyWith(
      introduction: _introController.text,
      mainPoints: mainPoints,
      conclusion: _conclusionController.text,
    );

    final provider = context.read<SpeechProvider>();
    await provider.updateOutline(widget.speech.id, updatedOutline);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esboço salvo com sucesso!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _conclusionController.dispose();
    for (final c in _pointControllers) {
      c.dispose();
    }
    super.dispose();
  }
}

class _MainPointControllers {
  final MainPoint point;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final TextEditingController illustrationController;

  _MainPointControllers(this.point)
      : titleController = TextEditingController(text: point.title),
        contentController = TextEditingController(text: point.content),
        illustrationController = TextEditingController(
          text: point.illustrations.isNotEmpty ? point.illustrations.first : '',
        );

  void dispose() {
    titleController.dispose();
    contentController.dispose();
    illustrationController.dispose();
  }
}

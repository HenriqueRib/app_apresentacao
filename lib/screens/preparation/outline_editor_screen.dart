import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../models/speech.dart';
import '../../providers/speech_provider.dart';
import '../../services/characteristics_service.dart';
import '../../services/api_service.dart';

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
  final _originalOutlineController = TextEditingController();
  final _completeManuscriptController = TextEditingController();
  final _initialCommentController = TextEditingController();
  final _finalCommentController = TextEditingController();
  final List<_MainPointControllers> _pointControllers = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _outline = widget.speech.outline ?? const SpeechOutline();
    _loadControllers();
  }

  void _loadControllers() {
    _introController.text = _outline.introduction;
    _conclusionController.text = _outline.conclusion;
    _originalOutlineController.text = widget.speech.originalOutline;
    _completeManuscriptController.text = widget.speech.completeManuscript;
    _initialCommentController.text = widget.speech.initialComment;
    _finalCommentController.text = widget.speech.finalComment;

    for (final point in _outline.mainPoints) {
      _pointControllers.add(_MainPointControllers(point));
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _conclusionController.dispose();
    _originalOutlineController.dispose();
    _completeManuscriptController.dispose();
    _initialCommentController.dispose();
    _finalCommentController.dispose();
    for (var c in _pointControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAll() async {
    final updatedOutline = _outline.copyWith(
      introduction: _introController.text,
      conclusion: _conclusionController.text,
      mainPoints: _pointControllers.map((c) => c.toMainPoint()).toList(),
    );

    final updatedSpeech = widget.speech.copyWith(
      outline: updatedOutline,
      originalOutline: _originalOutlineController.text,
      completeManuscript: _completeManuscriptController.text,
      initialComment: _initialCommentController.text,
      finalComment: _finalCommentController.text,
    );

    await context.read<SpeechProvider>().updateSpeech(updatedSpeech);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tudo salvo com sucesso!')),
      );
    }
  }

  Future<void> _generateManuscript() async {
    if (_originalOutlineController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insira o esboço original para gerar o manuscrito.')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final result = await ApiService().generateManuscript(_originalOutlineController.text);
      setState(() {
        _completeManuscriptController.text = result['manuscrito_completo'] ?? '';
        _initialCommentController.text = result['comentario_inicial'] ?? '';
        _finalCommentController.text = result['comentario_final'] ?? '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manuscrito gerado com IA!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Etapa 2: Preparar'),
        actions: [
          if (_isGenerating)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAll,
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
                _buildAIToolbox(),
                const SizedBox(height: 16),
                _buildOriginalOutlineToggle(),
                const SizedBox(height: 12),
                _buildManuscriptToggle(),
                const SizedBox(height: 16),
                const Divider(),
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
    final focus = widget.speech.focusCharacteristicId != null
        ? CharacteristicsService.instance.getCharacteristicById(widget.speech.focusCharacteristicId!)
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBadge(widget.speech.type == SpeechType.student10min ? '10 min' : '30 min'),
              if (focus != null) ...[
                const SizedBox(width: 8),
                _buildBadge('Foco: ${focus.title}', color: AppTheme.secondaryColor),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Objetivo: ${widget.speech.centralObjective}',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11)),
    );
  }

  Widget _buildAIToolbox() {
    return Card(
      color: AppTheme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text('Ferramentas de IA', style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateManuscript,
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('Manuscrito'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {}, // TODO: Implementar generateGuide
                    icon: const Icon(Icons.menu_book, size: 18),
                    label: const Text('Gerar Guia'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalOutlineToggle() {
    return Card(
      child: ExpansionTile(
        title: const Text('Esboço Original'),
        subtitle: const Text('Cole aqui o texto do esboço oficial'),
        leading: const Icon(Icons.list_alt, color: Colors.blue),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _originalOutlineController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Digite ou cole o esboço...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManuscriptToggle() {
    return Card(
      child: ExpansionTile(
        title: const Text('Manuscrito Completo'),
        subtitle: const Text('O que você realmente vai falar (L.E.I.A.)'),
        leading: const Icon(Icons.edit_note, color: AppTheme.secondaryColor),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _initialCommentController,
                  decoration: const InputDecoration(labelText: 'Comentário Inicial', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _completeManuscriptController,
                  maxLines: 15,
                  decoration: const InputDecoration(
                    hintText: 'Escreva seu manuscrito completo aqui...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _finalCommentController,
                  decoration: const InputDecoration(labelText: 'Comentário Final', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSED SECTIONS FROM ORIGINAL CODE ---

  Widget _buildIntroductionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.play_arrow, color: Colors.blue),
                const SizedBox(width: 12),
                Text('Introdução', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _introController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Resumo da introdução...', border: OutlineInputBorder()),
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
        Text('Esboço Local (Por Cards)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_pointControllers.isEmpty)
          const Text('Nenhum card adicionado.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pointControllers.length,
            itemBuilder: (context, index) => _buildMainPointCard(index),
          ),
      ],
    );
  }

  Widget _buildMainPointCard(int index) {
    final controllers = _pointControllers[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text('Ponto ${index + 1}: ${controllers.titleController.text}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(controller: controllers.titleController, decoration: const InputDecoration(labelText: 'Título')),
                TextField(controller: controllers.contentController, decoration: const InputDecoration(labelText: 'Desenvolvimento'), maxLines: 2),
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
                const Icon(Icons.flag, color: AppTheme.accentColor),
                const SizedBox(width: 12),
                Text('Conclusão', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _conclusionController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Resumo da conclusão...', border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiblicalTextsSection() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.book, color: AppTheme.secondaryColor),
        title: const Text('Textos Bíblicos (Métricas)'),
        subtitle: Text('${_outline.biblicalTexts.length} textos registrados'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Link to a dedicated biblical text management screen if needed
        },
      ),
    );
  }

  void _addMainPoint() {
    setState(() {
      _pointControllers.add(_MainPointControllers(MainPoint(id: _uuid.v4(), title: '')));
    });
  }

  void _removeMainPoint(int index) {
    setState(() {
      _pointControllers[index].dispose();
      _pointControllers.removeAt(index);
    });
  }
}

class _MainPointControllers {
  final MainPoint point;
  late final TextEditingController titleController;
  late final TextEditingController contentController;
  late final TextEditingController illustrationController;

  _MainPointControllers(this.point) {
    titleController = TextEditingController(text: point.title);
    contentController = TextEditingController(text: point.content);
    illustrationController = TextEditingController(text: point.illustration ?? '');
  }

  void dispose() {
    titleController.dispose();
    contentController.dispose();
    illustrationController.dispose();
  }

  MainPoint toMainPoint() {
    return point.copyWith(
      title: titleController.text,
      content: contentController.text,
      illustration: illustrationController.text,
    );
  }
}

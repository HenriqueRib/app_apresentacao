import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../providers/speech_provider.dart';
import '../../models/speech.dart';
import '../../widgets/shell/shell_tab_scaffold.dart';
import '../../widgets/shell/gradient_primary_button.dart';

class CreateOutlineScreen extends StatefulWidget {
  const CreateOutlineScreen({super.key});

  @override
  State<CreateOutlineScreen> createState() => _CreateOutlineScreenState();
}

class _CreateOutlineScreenState extends State<CreateOutlineScreen> {
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _generateOutline() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira as informações do discurso.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result =
          await ApiService().generateManuscript(_contentController.text);
      setState(() {
        _result = result;
        if (_titleController.text.isEmpty && result.containsKey('titulo')) {
          _titleController.text = result['titulo'];
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveSpeech() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, defina um título para o discurso.'),
        ),
      );
      return;
    }

    if (_result == null) return;

    final provider = context.read<SpeechProvider>();

    final outline = SpeechOutline(
      introduction: _result!['introducao'] ?? '',
      conclusion: _result!['conclusao'] ?? '',
      mainPoints: (_result!['pontos_principais'] as List?)
              ?.map(
                (p) => MainPoint(
                  id: '${DateTime.now().millisecondsSinceEpoch}${p['titulo']}',
                  title: p['titulo'] ?? '',
                  content: p['conteudo'] ?? '',
                ),
              )
              .toList() ??
          [],
    );

    final speech = await provider.createSpeech(
      title: _titleController.text,
      type: SpeechType.public30min,
      goalType: SpeechGoalType.helpOthers,
      centralObjective: _result!['objetivo_central'] ?? '',
    );

    await provider.updateOutline(speech.id, outline);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Discurso criado e salvo com sucesso!'),
          backgroundColor: AppTheme.shellAccentGreen,
        ),
      );
      setState(() {
        _result = null;
        _contentController.clear();
        _titleController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShellTabScaffold(
      title: 'Criar Esboço',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações do Discurso',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Envie o conteúdo bruto, ideias ou transcrição para que o sistema gere um esboço completo.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _contentController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText: 'Digite ou cole as informações aqui...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _generateOutline,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                          _isLoading ? 'Processando...' : 'Gerar Esboço via IA',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              _buildResultSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Resultado do Esboço',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Título do Discurso',
            hintText: 'Ex: A importância da persistência',
          ),
        ),
        const SizedBox(height: 16),
        _buildSectionCard('Introdução', _result!['introducao']),
        _buildSectionCard('Conclusão', _result!['conclusao']),
        if (_result!['pontos_principais'] != null)
          ...(_result!['pontos_principais'] as List).map(
            (p) => _buildSectionCard('Ponto: ${p['titulo']}', p['conteudo']),
          ),
        const SizedBox(height: 24),
        GradientPrimaryButton(
          label: 'Salvar no Aplicativo',
          icon: Icons.save,
          onPressed: _saveSpeech,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionCard(String title, String? content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.shellAccentTeal,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(color: AppTheme.shellTextSecondary),
            Text(
              content ?? 'Sem conteúdo gerado.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

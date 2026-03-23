import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/presentation.dart';
import '../../providers/presentation_provider.dart';

class MessageArchitectureScreen extends StatefulWidget {
  final Presentation presentation;

  const MessageArchitectureScreen({
    super.key,
    required this.presentation,
  });

  @override
  State<MessageArchitectureScreen> createState() =>
      _MessageArchitectureScreenState();
}

class _MessageArchitectureScreenState extends State<MessageArchitectureScreen> {
  late MessageArchitecture _architecture;
  final _formKey = GlobalKey<FormState>();

  final _centralIdeaController = TextEditingController();
  final _problemController = TextEditingController();
  final _audienceController = TextEditingController();
  final _causeController = TextEditingController();
  final _solutionController = TextEditingController();
  final _selfConfidenceController = TextEditingController();
  final _overcomingController = TextEditingController();
  final _actionMotivationController = TextEditingController();
  final _requestedActionController = TextEditingController();
  final _celebrationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _architecture =
        widget.presentation.messageArchitecture ?? const MessageArchitecture();
    _loadControllers();
  }

  void _loadControllers() {
    _centralIdeaController.text = _architecture.centralIdea;
    _problemController.text = _architecture.problem;
    _audienceController.text = _architecture.audienceIdentification;
    _causeController.text = _architecture.problemCause;
    _solutionController.text = _architecture.solutionAndMethod;
    _selfConfidenceController.text = _architecture.motivationSelfConfidence;
    _overcomingController.text = _architecture.motivationOvercoming;
    _actionMotivationController.text = _architecture.motivationAction;
    _requestedActionController.text = _architecture.requestedAction;
    _celebrationController.text = _architecture.celebration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arquitetura da Mensagem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveArchitecture,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildProgressCard(),
            const SizedBox(height: 24),
            _buildArchitectureElements(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.presentation.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'KPI: ${widget.presentation.kpiGoal}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final percentage = _calculateProgress();
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
                  'Progresso da Estrutura',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage == 1.0 ? AppTheme.successColor : AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchitectureElements() {
    return Column(
      children: [
        _buildElementCard(
          number: 1,
          title: 'Ideia Central',
          description: 'O núcleo da mensagem em uma frase.',
          controller: _centralIdeaController,
          maxLength: 100,
          isHighlight: false,
        ),
        _buildElementCard(
          number: 2,
          title: 'Problema/Desafio',
          description: 'A dor ou oportunidade detectada.',
          controller: _problemController,
          maxLength: 200,
          isHighlight: false,
        ),
        _buildElementCard(
          number: 3,
          title: 'Identificação do Público',
          description: 'Argumentos que gerem empatia imediata ("Ele me entende").',
          controller: _audienceController,
          maxLength: 200,
          isHighlight: false,
        ),
        _buildElementCard(
          number: 4,
          title: 'Causa do Problema',
          description: 'Diagnóstico técnico ou comportamental.',
          controller: _causeController,
          maxLength: 200,
          isHighlight: false,
        ),
        _buildElementCard(
          number: 5,
          title: 'Solução e Método',
          description: 'Apresentação visual da saída e dos passos do método.',
          controller: _solutionController,
          maxLength: 500,
          isHighlight: true,
          highlightLabel: 'Pico de Eureca!',
        ),
        _buildMotivationSection(),
        _buildElementCard(
          number: 7,
          title: 'Ação Solicitada',
          description: 'Comando claro para a conversão (venda ou mudança).',
          controller: _requestedActionController,
          maxLength: 200,
          isHighlight: false,
        ),
        _buildElementCard(
          number: 8,
          title: 'Celebração/Conclusão',
          description: 'Encerramento com pico de energia vital.',
          controller: _celebrationController,
          maxLength: 200,
          isHighlight: false,
        ),
      ],
    );
  }

  Widget _buildElementCard({
    required int number,
    required String title,
    required String description,
    required TextEditingController controller,
    required int maxLength,
    required bool isHighlight,
    String? highlightLabel,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isHighlight
            ? const BorderSide(color: AppTheme.secondaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isHighlight
                        ? AppTheme.secondaryColor
                        : AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (highlightLabel != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            highlightLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              maxLines: number == 5 ? 5 : 3,
              maxLength: maxLength,
              decoration: InputDecoration(
                hintText: 'Digite aqui...',
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '6',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Motivação Tripartite',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMotivationField(
              label: 'Autoconfiança',
              description: 'Garantir que a plateia se sinta capaz.',
              controller: _selfConfidenceController,
              icon: Icons.psychology,
            ),
            const SizedBox(height: 12),
            _buildMotivationField(
              label: 'Superação',
              description: 'Inspirar a ultrapassar limites acima da média.',
              controller: _overcomingController,
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 12),
            _buildMotivationField(
              label: 'Ação',
              description: 'O gatilho motivacional final.',
              controller: _actionMotivationController,
              icon: Icons.bolt,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationField({
    required String label,
    required String description,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.accentColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: 2,
            maxLength: 150,
            decoration: const InputDecoration(
              hintText: 'Digite aqui...',
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    int filled = 0;
    if (_centralIdeaController.text.isNotEmpty) filled++;
    if (_problemController.text.isNotEmpty) filled++;
    if (_audienceController.text.isNotEmpty) filled++;
    if (_causeController.text.isNotEmpty) filled++;
    if (_solutionController.text.isNotEmpty) filled++;
    if (_selfConfidenceController.text.isNotEmpty) filled++;
    if (_overcomingController.text.isNotEmpty) filled++;
    if (_actionMotivationController.text.isNotEmpty) filled++;
    if (_requestedActionController.text.isNotEmpty) filled++;
    if (_celebrationController.text.isNotEmpty) filled++;
    return filled / 10;
  }

  Future<void> _saveArchitecture() async {
    final newArchitecture = MessageArchitecture(
      centralIdea: _centralIdeaController.text,
      problem: _problemController.text,
      audienceIdentification: _audienceController.text,
      problemCause: _causeController.text,
      solutionAndMethod: _solutionController.text,
      motivationSelfConfidence: _selfConfidenceController.text,
      motivationOvercoming: _overcomingController.text,
      motivationAction: _actionMotivationController.text,
      requestedAction: _requestedActionController.text,
      celebration: _celebrationController.text,
    );

    final provider = context.read<PresentationProvider>();
    await provider.updateMessageArchitecture(
      widget.presentation.id,
      newArchitecture,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arquitetura salva com sucesso!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _centralIdeaController.dispose();
    _problemController.dispose();
    _audienceController.dispose();
    _causeController.dispose();
    _solutionController.dispose();
    _selfConfidenceController.dispose();
    _overcomingController.dispose();
    _actionMotivationController.dispose();
    _requestedActionController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/speech.dart';
import '../../providers/speech_provider.dart';
import '../../services/characteristics_service.dart';
import '../preparation/outline_editor_screen.dart';

class SpeechPlanningScreen extends StatefulWidget {
  const SpeechPlanningScreen({super.key});

  @override
  State<SpeechPlanningScreen> createState() => _SpeechPlanningScreenState();
}

class _SpeechPlanningScreenState extends State<SpeechPlanningScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  SpeechType _speechType = SpeechType.student10min;
  SpeechGoalType _goalType = SpeechGoalType.personalObjective;

  final _titleController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _knowledgeLevelController = TextEditingController();
  final _needsController = TextEditingController();
  final _attitudeController = TextEditingController();
  final _transformationController = TextEditingController();

  int? _selectedCharacteristicId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Discurso'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildTypeStep(),
                  _buildGoalStep(),
                  _buildObjectiveStep(),
                  _buildAudienceStep(),
                  if (_speechType == SpeechType.student10min)
                    _buildCharacteristicStep(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final totalSteps =
        _speechType == SpeechType.student10min ? 5 : 4;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color:
                          isActive ? AppTheme.primaryColor : Colors.grey.shade300,
                    ),
                  ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        isActive ? AppTheme.primaryColor : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de Discurso',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha o formato da sua apresentação.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _TypeOption(
            title: 'Designação de Estudante (10 min)',
            description:
                'Foco em 1-2 pontos principais. Aplicação direta. Ideal para desenvolver uma característica específica.',
            icon: Icons.school,
            isSelected: _speechType == SpeechType.student10min,
            onTap: () {
              setState(() {
                _speechType = SpeechType.student10min;
              });
            },
          ),
          const SizedBox(height: 16),
          _TypeOption(
            title: 'Discurso Público (30 min)',
            description:
                'Baseado em esboço fornecido. 4-5 pontos principais. Argumentação lógica e transições suaves.',
            icon: Icons.groups,
            isSelected: _speechType == SpeechType.public30min,
            onTap: () {
              setState(() {
                _speechType = SpeechType.public30min;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qual é o foco do discurso?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Defina se o objetivo é pessoal ou voltado para ajudar outros.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _TypeOption(
            title: 'Objetivo Próprio',
            description:
                'Venda de produtos, projetos, ideias. Foco na conversão direta.',
            icon: Icons.person,
            isSelected: _goalType == SpeechGoalType.personalObjective,
            onTap: () {
              setState(() {
                _goalType = SpeechGoalType.personalObjective;
              });
            },
          ),
          const SizedBox(height: 16),
          _TypeOption(
            title: 'Ajudar o Próximo',
            description:
                'Instrução, espiritualidade, auxílio comunitário. Foco na transformação do ouvinte.',
            icon: Icons.volunteer_activism,
            isSelected: _goalType == SpeechGoalType.helpOthers,
            onTap: () {
              setState(() {
                _goalType = SpeechGoalType.helpOthers;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Defina o Objetivo Central',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Este objetivo permanecerá visível durante toda a preparação.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título do Discurso',
              hintText: 'Ex: A importância da perseverança',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, insira um título';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _objectiveController,
            decoration: InputDecoration(
              labelText: 'Objetivo Central',
              hintText: _goalType == SpeechGoalType.personalObjective
                  ? 'Ex: Convencer 50% da audiência a se inscrever'
                  : 'Ex: Fortalecer a fé dos ouvintes na promessa de Deus',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, defina o objetivo central';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.warningColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'O sucesso é medido pela ação provocada na plateia, não pelos aplausos.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Análise da Assistência',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Prepare o coração conhecendo seu público.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _knowledgeLevelController,
            decoration: const InputDecoration(
              labelText: 'Nível de conhecimento prévio',
              hintText: 'Ex: Conhecimento básico do assunto',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _needsController,
            decoration: const InputDecoration(
              labelText: 'Necessidades imediatas',
              hintText: 'Ex: Precisam de encorajamento prático',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _attitudeController,
            decoration: const InputDecoration(
              labelText: 'Atitude esperada',
              hintText: 'Ex: Receptivos mas cansados',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _transformationController,
            decoration: const InputDecoration(
              labelText: 'Transformação desejada',
              hintText: 'Ex: Que saiam motivados a aplicar o aprendizado',
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicStep() {
    final characteristics =
        CharacteristicsService.instance.getRecommendedForSpeechType(false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Característica em Foco',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione uma das 53 características para trabalhar neste discurso.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ...characteristics.map((char) {
            final isSelected = _selectedCharacteristicId == char.id;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? const BorderSide(color: AppTheme.primaryColor, width: 2)
                    : BorderSide.none,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  child: Text('${char.id}'),
                ),
                title: Text(char.title),
                subtitle: Text(
                  char.category,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedCharacteristicId = char.id;
                  });
                },
              ),
            );
          }),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _showAllCharacteristics(context);
            },
            child: const Text('Ver todas as 53 características'),
          ),
        ],
      ),
    );
  }

  void _showAllCharacteristics(BuildContext context) {
    final allChars = CharacteristicsService.instance.allCharacteristics;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '53 Características de Oratória',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: allChars.length,
                    itemBuilder: (context, index) {
                      final char = allChars[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          child: Text('${char.id}'),
                        ),
                        title: Text(char.title),
                        subtitle: Text(char.category),
                        onTap: () {
                          setState(() {
                            _selectedCharacteristicId = char.id;
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNavigationButtons() {
    final totalSteps = _speechType == SpeechType.student10min ? 5 : 4;
    final isLastStep = _currentStep == totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Voltar'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextStep,
              child: Text(isLastStep ? 'Criar Discurso' : 'Próximo'),
            ),
          ),
        ],
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    final totalSteps = _speechType == SpeechType.student10min ? 5 : 4;

    if (_currentStep == 2) {
      if (_titleController.text.trim().isEmpty ||
          _objectiveController.text.trim().isEmpty) {
        _formKey.currentState?.validate();
        return;
      }
    }

    if (_currentStep == totalSteps - 1) {
      _createSpeech();
      return;
    }

    setState(() {
      _currentStep++;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _createSpeech() async {
    final provider = context.read<SpeechProvider>();

    final audienceAnalysis = AudienceAnalysis(
      knowledgeLevel: _knowledgeLevelController.text,
      immediateNeeds: _needsController.text,
      expectedAttitude: _attitudeController.text,
      desiredTransformation: _transformationController.text,
    );

    final speech = await provider.createSpeech(
      title: _titleController.text.trim(),
      type: _speechType,
      goalType: _goalType,
      centralObjective: _objectiveController.text.trim(),
      audienceAnalysis: audienceAnalysis,
      focusCharacteristicId: _selectedCharacteristicId,
    );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OutlineEditorScreen(speech: speech),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _objectiveController.dispose();
    _knowledgeLevelController.dispose();
    _needsController.dispose();
    _attitudeController.dispose();
    _transformationController.dispose();
    super.dispose();
  }
}

class _TypeOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.primaryColor : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

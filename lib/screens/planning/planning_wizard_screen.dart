import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/presentation.dart';
import '../../providers/presentation_provider.dart';
import '../preparation/message_architecture_screen.dart';

class PlanningWizardScreen extends StatefulWidget {
  const PlanningWizardScreen({super.key});

  @override
  State<PlanningWizardScreen> createState() => _PlanningWizardScreenState();
}

class _PlanningWizardScreenState extends State<PlanningWizardScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  WorkflowType _selectedWorkflowType = WorkflowType.objetivoProprio;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _kpiController = TextEditingController();

  bool _isQuickPitch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Palestra'),
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
                  _buildWorkflowTypeStep(),
                  _buildTitleStep(),
                  _buildKpiStep(),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
                    ),
                  ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
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

  Widget _buildWorkflowTypeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Qual é o foco da sua palestra?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha o tipo de workflow que melhor se encaixa no seu objetivo.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _WorkflowOption(
            title: 'Objetivo Próprio',
            description: 'Conversão direta: Venda, patrocínio, suporte.',
            question: 'Qual meta específica EU pretendo atingir com este pitch?',
            icon: Icons.person,
            isSelected: _selectedWorkflowType == WorkflowType.objetivoProprio,
            onTap: () {
              setState(() {
                _selectedWorkflowType = WorkflowType.objetivoProprio;
              });
            },
          ),
          const SizedBox(height: 16),
          _WorkflowOption(
            title: 'Objetivo do Cliente',
            description: 'Resolução de dor: Consultoria, agências, problemas.',
            question: 'Qual dor o MEU CLIENTE quer resolver através desta solução?',
            icon: Icons.group,
            isSelected: _selectedWorkflowType == WorkflowType.objetivoCliente,
            onTap: () {
              setState(() {
                _selectedWorkflowType = WorkflowType.objetivoCliente;
              });
            },
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Quick Pitch (5 minutos)'),
            subtitle: const Text(
              'Template de microapresentação para conexão cerebral imediata.',
            ),
            value: _isQuickPitch,
            onChanged: (value) {
              setState(() {
                _isQuickPitch = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nome da sua palestra',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha um título que capture a essência da sua mensagem.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título da palestra',
              hintText: 'Ex: Como triplicar suas vendas em 90 dias',
            ),
            maxLength: AppConstants.maxTitleLength,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, insira um título';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKpiStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Defina seu KPI de Sucesso',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _selectedWorkflowType == WorkflowType.objetivoProprio
                ? 'Qual meta específica VOCÊ pretende atingir com este pitch?'
                : 'Qual dor o seu CLIENTE quer resolver através desta solução?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppTheme.primaryColor,
                ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.warningColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'O sucesso não é medido por aplausos, mas por objetivos realizados.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _kpiController,
            decoration: InputDecoration(
              labelText: 'Objetivo/KPI',
              hintText: _selectedWorkflowType == WorkflowType.objetivoProprio
                  ? 'Ex: Fechar 10 contratos de consultoria'
                  : 'Ex: Ajudar empresas a reduzir custos em 30%',
            ),
            maxLines: 3,
            maxLength: AppConstants.maxShortDescriptionLength,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor, defina seu KPI de sucesso';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
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
              child: Text(_currentStep == 2 ? 'Criar Palestra' : 'Próximo'),
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
    if (_currentStep == 1 && _titleController.text.trim().isEmpty) {
      _formKey.currentState?.validate();
      return;
    }

    if (_currentStep == 2) {
      if (_kpiController.text.trim().isEmpty) {
        _formKey.currentState?.validate();
        return;
      }
      _createPresentation();
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

  Future<void> _createPresentation() async {
    final provider = context.read<PresentationProvider>();
    
    final presentation = await provider.createPresentation(
      title: _titleController.text.trim(),
      workflowType: _selectedWorkflowType,
      kpiGoal: _kpiController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MessageArchitectureScreen(presentation: presentation),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _kpiController.dispose();
    super.dispose();
  }
}

class _WorkflowOption extends StatelessWidget {
  final String title;
  final String description;
  final String question;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _WorkflowOption({
    required this.title,
    required this.description,
    required this.question,
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
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

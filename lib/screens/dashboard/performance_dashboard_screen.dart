import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/presentation.dart';
import '../../providers/presentation_provider.dart';

class PerformanceDashboardScreen extends StatelessWidget {
  const PerformanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
      ),
      body: Consumer<PresentationProvider>(
        builder: (context, provider, _) {
          final executedPresentations = provider.presentations
              .where((p) => p.status == PresentationStatus.executed)
              .toList();

          if (executedPresentations.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildOverallMetrics(context, executedPresentations),
              const SizedBox(height: 24),
              _buildPresentationsList(context, executedPresentations),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma palestra executada',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Execute suas palestras para começar a acompanhar suas métricas de sucesso.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallMetrics(
    BuildContext context,
    List<Presentation> presentations,
  ) {
    int totalBusiness = 0;
    int totalContracts = 0;
    int totalLeads = 0;

    for (final p in presentations) {
      if (p.performanceMetrics != null) {
        totalBusiness += p.performanceMetrics!.businessClosed;
        totalContracts += p.performanceMetrics!.contractsSigned;
        totalLeads += p.performanceMetrics!.leadsGenerated;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métricas de Sucesso',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Resultados que realmente importam',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.handshake,
                    label: 'Negócios\nFechados',
                    value: totalBusiness.toString(),
                    color: AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.description,
                    label: 'Contratos\nAssinados',
                    value: totalContracts.toString(),
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.people,
                    label: 'Leads\nGerados',
                    value: totalLeads.toString(),
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sucesso Efetivo: Medição da ação real provocada na plateia.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresentationsList(
    BuildContext context,
    List<Presentation> presentations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Palestras Executadas',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...presentations.map((presentation) {
          return _PresentationMetricsCard(
            presentation: presentation,
            onTap: () => _showMetricsDialog(context, presentation),
          );
        }),
      ],
    );
  }

  void _showMetricsDialog(BuildContext context, Presentation presentation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _MetricsDetailSheet(
              presentation: presentation,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PresentationMetricsCard extends StatelessWidget {
  final Presentation presentation;
  final VoidCallback onTap;

  const _PresentationMetricsCard({
    required this.presentation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = presentation.performanceMetrics;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.done_all,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      presentation.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (metrics != null)
                      Row(
                        children: [
                          _buildSmallMetric(
                            Icons.handshake,
                            metrics.businessClosed.toString(),
                          ),
                          const SizedBox(width: 16),
                          _buildSmallMetric(
                            Icons.description,
                            metrics.contractsSigned.toString(),
                          ),
                          const SizedBox(width: 16),
                          _buildSmallMetric(
                            Icons.people,
                            metrics.leadsGenerated.toString(),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Adicionar métricas',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryColor,
                            ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallMetric(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _MetricsDetailSheet extends StatefulWidget {
  final Presentation presentation;
  final ScrollController scrollController;

  const _MetricsDetailSheet({
    required this.presentation,
    required this.scrollController,
  });

  @override
  State<_MetricsDetailSheet> createState() => _MetricsDetailSheetState();
}

class _MetricsDetailSheetState extends State<_MetricsDetailSheet> {
  late TextEditingController _businessController;
  late TextEditingController _contractsController;
  late TextEditingController _leadsController;
  late TextEditingController _feedbackController;
  late TextEditingController _lessonsController;

  @override
  void initState() {
    super.initState();
    final metrics = widget.presentation.performanceMetrics;
    _businessController = TextEditingController(
      text: metrics?.businessClosed.toString() ?? '0',
    );
    _contractsController = TextEditingController(
      text: metrics?.contractsSigned.toString() ?? '0',
    );
    _leadsController = TextEditingController(
      text: metrics?.leadsGenerated.toString() ?? '0',
    );
    _feedbackController = TextEditingController(
      text: metrics?.feedback.join('\n') ?? '',
    );
    _lessonsController = TextEditingController(
      text: metrics?.lessonsLearned.join('\n') ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.presentation.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'KPI: ${widget.presentation.kpiGoal}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Resultados Efetivos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildMetricInput(
          label: 'Negócios Fechados',
          controller: _businessController,
          icon: Icons.handshake,
        ),
        _buildMetricInput(
          label: 'Contratos Assinados',
          controller: _contractsController,
          icon: Icons.description,
        ),
        _buildMetricInput(
          label: 'Leads Gerados',
          controller: _leadsController,
          icon: Icons.people,
        ),
        const SizedBox(height: 24),
        Text(
          'Feedback e Aprendizados',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _feedbackController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Feedback recebido',
            hintText: 'Críticas sinceras e observações...',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _lessonsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Lições aprendidas',
            hintText: 'O que você faria diferente?',
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _saveMetrics,
          child: const Text('Salvar Métricas'),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _scheduleFollowUp,
          icon: const Icon(Icons.calendar_today),
          label: const Text('Agendar Follow-up'),
        ),
      ],
    );
  }

  Widget _buildMetricInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Future<void> _saveMetrics() async {
    final provider = context.read<PresentationProvider>();
    
    final metrics = PerformanceMetrics(
      businessClosed: int.tryParse(_businessController.text) ?? 0,
      contractsSigned: int.tryParse(_contractsController.text) ?? 0,
      leadsGenerated: int.tryParse(_leadsController.text) ?? 0,
      feedback: _feedbackController.text.split('\n').where((s) => s.isNotEmpty).toList(),
      lessonsLearned: _lessonsController.text.split('\n').where((s) => s.isNotEmpty).toList(),
    );

    await provider.updatePerformanceMetrics(
      widget.presentation.id,
      metrics,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Métricas salvas com sucesso!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _scheduleFollowUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de follow-up em desenvolvimento'),
      ),
    );
  }

  @override
  void dispose() {
    _businessController.dispose();
    _contractsController.dispose();
    _leadsController.dispose();
    _feedbackController.dispose();
    _lessonsController.dispose();
    super.dispose();
  }
}

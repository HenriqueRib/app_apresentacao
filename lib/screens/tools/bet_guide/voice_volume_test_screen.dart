import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/voice_volume_test_provider.dart';
import '../../../services/voice_analysis_engine.dart';
import '../../../services/voice_volume_calibrator.dart';

class VoiceVolumeTestScreen extends StatefulWidget {
  const VoiceVolumeTestScreen({super.key});

  @override
  State<VoiceVolumeTestScreen> createState() => _VoiceVolumeTestScreenState();
}

class _VoiceVolumeTestScreenState extends State<VoiceVolumeTestScreen> {
  static final _dateFormat = DateFormat('dd/MM');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceVolumeTestProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de volume'),
      ),
      body: Consumer<VoiceVolumeTestProvider>(
        builder: (context, provider, _) {
          if (!provider.hasMicPermission) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Permissão de microfone necessária para testar o volume.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final isActive =
              provider.isListening || provider.isCalibrating;
          final zone = isActive
              ? provider.currentZone
              : VolumeZone.transition;
          final zoneColor = _zoneColor(zone);
          final db = isActive ? provider.currentDb : 0.0;

          return Column(
            children: [
              if (provider.calibration != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 16, color: AppTheme.successColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Calibrado em ${_dateFormat.format(provider.calibration!.calibratedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      TextButton(
                        onPressed: provider.isCalibrating || provider.isListening
                            ? null
                            : () => provider.startCalibration(),
                        child: const Text('Recalibrar'),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Card(
                    color: AppTheme.warningColor.withValues(alpha: 0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Calibre o microfone para resultados mais precisos neste aparelho.',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: provider.isCalibrating ||
                                      provider.isListening
                                  ? null
                                  : () => provider.startCalibration(),
                              icon: const Icon(Icons.tune, size: 18),
                              label: const Text('Calibrar microfone'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  color: zoneColor.withValues(alpha: 0.12),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: zoneColor.withValues(alpha: 0.25),
                            border: Border.all(color: zoneColor, width: 6),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isActive
                                      ? '${db.toStringAsFixed(0)} dB'
                                      : '—',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: zoneColor,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  provider.isCalibrating
                                      ? 'Calibrando… fale em volume normal'
                                      : isActive
                                          ? volumeZoneLabel(zone)
                                          : 'Aguardando',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: zoneColor.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            provider.isCalibrating
                                ? 'Fale uma frase em volume normal de proferimento por 5 segundos.'
                                : provider.isListening
                                    ? 'Fale uma frase normal e ajuste até a cor ficar verde.'
                                    : 'Toque em Iniciar teste e fale em volume de proferimento.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (provider.isListening) ...[
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              children: [
                                LinearProgressIndicator(
                                  value: provider.idealSecondsHeld /
                                      VoiceVolumeTestProvider
                                          .idealVolumeGoalSeconds,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade200,
                                  color: AppTheme.successColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  provider.goalReached
                                      ? 'Pronto para ensaiar!'
                                      : 'Meta: ${VoiceVolumeTestProvider.idealVolumeGoalSeconds}s no verde '
                                          '(${provider.idealSecondsHeld.toStringAsFixed(1)}s)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: provider.goalReached
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: provider.goalReached
                                        ? AppTheme.successColor
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Column(
                  children: [
                    if (provider.isListening) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _normalizedDb(db),
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          color: zoneColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Média: ${provider.avgDb.toStringAsFixed(0)} dB · '
                        '${volumeZoneLabel(provider.avgZone)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _LegendRow(
                      color: AppTheme.errorColor,
                      label:
                          'Baixo (< ${VoiceAnalysisThresholds.volumeLowDb.toInt()} dB) ou '
                          'alto (> ${VoiceAnalysisThresholds.volumeHighDb.toInt()} dB)',
                    ),
                    const SizedBox(height: 6),
                    _LegendRow(
                      color: AppTheme.warningColor,
                      label: 'Transição (perto do ideal)',
                    ),
                    const SizedBox(height: 6),
                    _LegendRow(
                      color: AppTheme.successColor,
                      label:
                          'Ideal (${VoiceAnalysisThresholds.volumeLowDb.toInt()} a '
                          '${VoiceAnalysisThresholds.volumeHighDb.toInt()} dB)',
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: provider.isCalibrating
                          ? null
                          : provider.isListening
                              ? () => provider.stop()
                              : () => provider.start(),
                      icon: Icon(
                        provider.isListening ? Icons.stop : Icons.mic,
                      ),
                      label: Text(
                        provider.isListening ? 'Parar teste' : 'Iniciar teste',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: provider.isListening
                            ? AppTheme.errorColor
                            : AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _zoneColor(VolumeZone zone) {
    switch (zone) {
      case VolumeZone.low:
      case VolumeZone.high:
        return AppTheme.errorColor;
      case VolumeZone.transition:
        return AppTheme.warningColor;
      case VolumeZone.ideal:
        return AppTheme.successColor;
    }
  }

  double _normalizedDb(double db) {
    return ((db + 60) / 50).clamp(0.0, 1.0);
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

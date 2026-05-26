import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/voice_rehearsal_smart_flags.dart';
import '../providers/voice_rehearsal_provider.dart';

class VoiceRehearsalSmartFlagsPanel extends StatelessWidget {
  const VoiceRehearsalSmartFlagsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceRehearsalProvider>(
      builder: (context, provider, _) {
        final flags = provider.smartFlags;
        final nextFocus = provider.nextFocus;

        return ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          title: const Text(
            'Modo inteligente',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            _activeCount(flags) > 0
                ? '${_activeCount(flags)} recurso(s) ativo(s)'
                : 'Ative recursos opcionais de coach e performance',
            style: const TextStyle(fontSize: 11),
          ),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ActionChip(
                  label: const Text('Iniciante', style: TextStyle(fontSize: 11)),
                  onPressed: () => _update(
                    provider,
                    VoiceRehearsalSmartFlags.presetBeginner,
                  ),
                ),
                ActionChip(
                  label: const Text('Completo', style: TextStyle(fontSize: 11)),
                  onPressed: () => _update(
                    provider,
                    VoiceRehearsalSmartFlags.presetComplete,
                  ),
                ),
                ActionChip(
                  label: const Text('Desligar tudo', style: TextStyle(fontSize: 11)),
                  onPressed: () => _update(
                    provider,
                    const VoiceRehearsalSmartFlags(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (nextFocus != null && flags.carryOverFocusEnabled)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Chip(
                  avatar: Icon(Icons.track_changes,
                      size: 16, color: AppTheme.primaryColor),
                  label: Text(
                    'Foco: ${nextFocus.label}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            _sectionTitle('Performance'),
            _flagSwitch(
              title: 'Contagem regressiva',
              subtitle: '3…2…1 antes de iniciar',
              value: flags.countdownEnabled,
              onChanged: (v) => _update(provider, flags.copyWith(countdownEnabled: v)),
            ),
            _flagSwitch(
              title: 'Aquecimento',
              subtitle: '45 s sem nota antes do ensaio valendo',
              value: flags.warmupEnabled,
              onChanged: (v) => _update(provider, flags.copyWith(warmupEnabled: v)),
            ),
            _flagSwitch(
              title: 'Marcos de tempo',
              subtitle: 'Metade, meta e +1 min',
              value: flags.timeMilestonesEnabled,
              onChanged: (v) =>
                  _update(provider, flags.copyWith(timeMilestonesEnabled: v)),
            ),
            _flagSwitch(
              title: 'Sinal discreto (vibração)',
              subtitle: 'Muletas e ritmo fora da faixa',
              value: flags.hapticEnabled,
              onChanged: (v) => _update(provider, flags.copyWith(hapticEnabled: v)),
            ),
            _sectionTitle('Coach'),
            _flagSwitch(
              title: 'Pausa inteligente',
              subtitle: 'Sugere respirar após alertas repetidos',
              value: flags.smartPauseEnabled,
              onChanged: (v) =>
                  _update(provider, flags.copyWith(smartPauseEnabled: v)),
            ),
            _flagSwitch(
              title: 'Foco no próximo ensaio',
              subtitle: 'Salva a característica mais fraca',
              value: flags.carryOverFocusEnabled,
              onChanged: (v) =>
                  _update(provider, flags.copyWith(carryOverFocusEnabled: v)),
            ),
            _flagSwitch(
              title: 'Coach mínimo',
              subtitle: 'Só alertas importantes',
              value: flags.minimalCoachEnabled,
              onChanged: (v) =>
                  _update(provider, flags.copyWith(minimalCoachEnabled: v)),
            ),
            _flagSwitch(
              title: 'Filtrar coach',
              subtitle: 'Priorizar uma área',
              value: flags.coachFocusEnabled,
              onChanged: (v) =>
                  _update(provider, flags.copyWith(coachFocusEnabled: v)),
            ),
            if (flags.coachFocusEnabled)
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 8),
                child: Wrap(
                  spacing: 6,
                  children: CoachFocusMode.values.map((mode) {
                    return ChoiceChip(
                      label: Text(mode.label, style: const TextStyle(fontSize: 11)),
                      selected: flags.coachFocusMode == mode,
                      onSelected: (_) => _update(
                        provider,
                        flags.copyWith(coachFocusMode: mode),
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ),
            _sectionTitle('Esboço e roteiro'),
            _flagSwitch(
              title: 'Rolagem lenta do roteiro',
              subtitle: 'Teleprompter desliza durante o bloco ativo',
              value: flags.autoScrollTeleprompter,
              onChanged: (v) => _update(
                provider,
                flags.copyWith(autoScrollTeleprompter: v),
              ),
            ),
            _sectionTitle('Pós-ensaio e hábito'),
            _flagSwitch(
              title: 'Ouvir últimos 30 s',
              subtitle: 'Após gravar (.m4a)',
              value: flags.listenBackEnabled,
              onChanged: (v) =>
                  _update(provider, flags.copyWith(listenBackEnabled: v)),
            ),
            _flagSwitch(
              title: 'Meta semanal na home',
              subtitle: 'Progresso de ensaios na semana',
              value: flags.weeklyGoalEnabled,
              onChanged: (v) =>
                  _update(provider, flags.copyWith(weeklyGoalEnabled: v)),
            ),
          ],
        );
      },
    );
  }

  int _activeCount(VoiceRehearsalSmartFlags f) {
    var n = 0;
    if (f.warmupEnabled) n++;
    if (f.countdownEnabled) n++;
    if (f.hapticEnabled) n++;
    if (f.timeMilestonesEnabled) n++;
    if (f.smartPauseEnabled) n++;
    if (f.carryOverFocusEnabled) n++;
    if (f.coachFocusEnabled) n++;
    if (f.minimalCoachEnabled) n++;
    if (f.listenBackEnabled) n++;
    if (f.weeklyGoalEnabled) n++;
    if (f.autoScrollTeleprompter) n++;
    return n;
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _flagSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(title, style: const TextStyle(fontSize: 12)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 10)),
      value: value,
      onChanged: onChanged,
    );
  }

  void _update(VoiceRehearsalProvider provider, VoiceRehearsalSmartFlags flags) {
    provider.updateSmartFlags(flags);
  }
}

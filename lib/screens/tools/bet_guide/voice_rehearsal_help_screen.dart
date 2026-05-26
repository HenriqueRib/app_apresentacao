import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/voice_analysis_engine.dart';
import '../../../widgets/voice_rehearsal_online_help_toggle.dart';
import 'voice_filler_settings_screen.dart';
import 'voice_volume_test_screen.dart';

/// Guia das métricas e termos do Ensaio be-T.
class VoiceRehearsalHelpScreen extends StatelessWidget {
  const VoiceRehearsalHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Como funciona o ensaio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'O ensaio funciona localmente por padrão (sem internet obrigatória). '
            'Você pode ativar a ajuda online abaixo para solicitar análise '
            'aprofundada manualmente no histórico. Abaixo, o significado de '
            'cada indicador e dica que você vê durante o ensaio.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          const VoiceRehearsalOnlineHelpToggle(),
          const SizedBox(height: 20),
          _HelpSection(
            icon: Icons.chat_bubble_outline,
            title: 'O que são muletas?',
            color: AppTheme.warningColor,
            children: [
              const _HelpParagraph(
                'Muletas são palavras ou sons que você repete sem necessidade '
                'enquanto fala, para “ganhar tempo” ou pensar — mas que não '
                'acrescentam sentido à mensagem.',
              ),
              const _HelpParagraph(
                'Exemplos: é, então, tipo, né, aí, hum, ah, enfim.',
              ),
              const _HelpParagraph(
                'No be-T, muitas muletas prejudicam a fluência e a clareza. '
                'O app conta quantas vezes cada uma aparece e sugere trocar '
                'por uma pausa curta em vez de repetir o som.',
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const VoiceFillerSettingsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.tune),
                  label: const Text('Personalizar muletas'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HelpSection(
            icon: Icons.text_fields,
            title: 'O que significa “Palavras”?',
            color: AppTheme.primaryColor,
            children: const [
              _HelpParagraph(
                'É o total de palavras que o reconhecimento de voz entendeu '
                'no seu discurso até o momento — não é a quantidade de palavras '
                'diferentes ou únicas.',
              ),
              _HelpParagraph(
                'Exemplo: se você disser “Jeová nos ama” e depois repetir '
                '“Jeová” mais três vezes, “Palavras” sobe (cada palavra contada), '
                'e o app pode alertar repetição da palavra “jeová”.',
              ),
              _HelpParagraph(
                'Palavras diferentes / repetidas aparecem no resumo, na seção '
                '“Palavras mais repetidas”.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HelpSection(
            icon: Icons.speed,
            title: 'Ritmo e WPM',
            color: Colors.teal,
            children: [
              const _HelpParagraph(
                'WPM significa palavras por minuto (words per minute): '
                'quantas palavras você fala em um minuto, em média.',
              ),
              _HelpParagraph(
                'O app calcula: (total de palavras ÷ tempo em minutos). '
                'Faixa considerada confortável para proferimento: '
                '${VoiceAnalysisThresholds.wpmLow.toInt()} a '
                '${VoiceAnalysisThresholds.wpmHigh.toInt()} WPM.',
              ),
              const _HelpParagraph(
                'Muito lento: pode parecer hesitação. Muito rápido: a '
                'assistência pode ter dificuldade para acompanhar e absorver.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HelpSection(
            icon: Icons.grade_outlined,
            title: 'Nota ao vivo (0 a 10)',
            color: AppTheme.successColor,
            children: const [
              _HelpParagraph(
                'Nota estimada da entrega vocal neste ensaio. Começa em 0 e '
                'vai subindo conforme você melhora muletas, ritmo, volume e modulação.',
              ),
              _HelpParagraph(
                'A nota é suavizada para não pular a cada segundo; no resumo '
                'você vê o detalhamento (o que somou ou tirou pontos).',
              ),
              _HelpParagraph(
                'Não avalia conteúdo bíblico, gestos ou contato visual — '
                'apenas aspectos que o microfone consegue perceber.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HelpSection(
            icon: Icons.volume_up,
            title: 'Volume',
            color: Colors.indigo,
            children: [
              const _HelpParagraph(
                'Barra que reflete a intensidade da sua voz captada pelo '
                'microfone. Volume muito baixo ou muito alto gera alerta.',
              ),
              const _HelpParagraph(
                'No modo treino, o volume vem do nível de som do '
                'reconhecimento de voz; no modo gravar, também do gravador.',
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const VoiceVolumeTestScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.graphic_eq),
                  label: const Text('Testar volume da voz'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HelpSection(
            icon: Icons.lightbulb_outline,
            title: '“O que melhorar agora”',
            color: AppTheme.accentColor,
            children: const [
              _HelpParagraph(
                'Até três prioridades atuais, com mensagem específica '
                '(ex.: qual palavra repetiu) e uma sugestão prática.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HelpSection(
            icon: Icons.help_outline,
            title: 'Palavras vagas (diferente de muletas)',
            color: Colors.blueGrey,
            children: const [
              _HelpParagraph(
                'Termos genéricos como “coisa”, “negócio”, “tal” — não são '
                'sons de enchimento, mas falta de precisão. O app alerta quando '
                'aparecem várias vezes.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _HelpSection(
            icon: Icons.mic_none,
            title: 'Treino x Gravar ensaio',
            color: AppTheme.secondaryColor,
            children: const [
              _HelpParagraph(
                'Iniciar treino: só microfone e feedback ao vivo, sem salvar arquivo.',
              ),
              _HelpParagraph(
                'Gravar ensaio: igual ao treino, mas gera um áudio .m4a que '
                'fica na lista de Gravações para ouvir depois.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Referência pedagógica: características de oratória do '
                      'livro Beneficie-se da Escola do Ministério Teocrático (be-T). '
                      'Para gestos, Bíblia e conteúdo, use a autoavaliação be-T.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<Widget> children;

  const _HelpSection({
    required this.icon,
    required this.title,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _HelpParagraph extends StatelessWidget {
  final String text;

  const _HelpParagraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
    );
  }
}

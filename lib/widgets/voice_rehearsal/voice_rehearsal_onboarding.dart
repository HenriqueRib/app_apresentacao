import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/storage_service.dart';

/// Coach marks na primeira visita ao Ensaio be-T (3 passos).
Future<void> showVoiceRehearsalOnboardingIfNeeded(BuildContext context) async {
  final storage = await StorageService.getInstance();
  if (await storage.isVoiceRehearsalOnboardingDone()) return;
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _VoiceRehearsalOnboardingDialog(),
  );

  await storage.setVoiceRehearsalOnboardingDone(true);
}

class _VoiceRehearsalOnboardingDialog extends StatefulWidget {
  const _VoiceRehearsalOnboardingDialog();

  @override
  State<_VoiceRehearsalOnboardingDialog> createState() =>
      _VoiceRehearsalOnboardingDialogState();
}

class _VoiceRehearsalOnboardingDialogState
    extends State<_VoiceRehearsalOnboardingDialog> {
  final _controller = PageController();
  int _page = 0;

  static const _steps = [
    (
      icon: Icons.tune,
      title: 'Prepare o ensaio',
      body:
          'Escolha meta de tempo, modo foco e vincule um discurso para usar o roteiro do esboço.',
    ),
    (
      icon: Icons.mic_none,
      title: 'Treino ou Gravar',
      body:
          'Treino usa reconhecimento de voz ao vivo. Gravar salva .m4a e transcreve depois — ideal no iOS.',
    ),
    (
      icon: Icons.auto_awesome,
      title: 'Modo inteligente',
      body:
          'Recursos opcionais: countdown, marcos, carry-over e teleprompter. Ative só o que precisar.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= _steps.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ensaio be-T'),
      content: SizedBox(
        width: 320,
        height: 220,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _steps.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(step.icon, size: 40, color: AppTheme.primaryColor),
                      const SizedBox(height: 12),
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.body,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _page
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Pular'),
        ),
        FilledButton(
          onPressed: _next,
          child: Text(
            _page >= _steps.length - 1 ? 'Começar' : 'Próximo',
          ),
        ),
      ],
    );
  }
}

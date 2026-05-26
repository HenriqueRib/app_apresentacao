import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/voice_rehearsal_provider.dart';
import '../screens/tools/bet_guide/voice_volume_test_screen.dart';

/// Abre o teste de volume e atualiza a calibração no ensaio ao voltar.
Future<void> openVoiceVolumeTest(BuildContext context) async {
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const VoiceVolumeTestScreen()),
  );
  if (!context.mounted) return;
  await context.read<VoiceRehearsalProvider>().refreshVolumeCalibration();
}

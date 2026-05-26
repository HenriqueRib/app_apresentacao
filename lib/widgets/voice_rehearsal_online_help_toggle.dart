import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/storage_service.dart';

/// Toggle persistido para habilitar análise online manual no histórico do ensaio.
class VoiceRehearsalOnlineHelpToggle extends StatefulWidget {
  const VoiceRehearsalOnlineHelpToggle({super.key});

  @override
  State<VoiceRehearsalOnlineHelpToggle> createState() =>
      _VoiceRehearsalOnlineHelpToggleState();
}

class _VoiceRehearsalOnlineHelpToggleState
    extends State<VoiceRehearsalOnlineHelpToggle> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = await StorageService.getInstance();
    final enabled = await storage.getVoiceRehearsalOnlineHelpEnabled();
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _onChanged(bool value) async {
    setState(() => _enabled = value);
    final storage = await StorageService.getInstance();
    await storage.setVoiceRehearsalOnlineHelpEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: SwitchListTile(
        secondary: Icon(Icons.cloud_outlined, color: AppTheme.primaryColor),
        title: const Text('Ajuda online no ensaio'),
        subtitle: const Text(
          'Envia transcrição e métricas para análise aprofundada. '
          'Desligado = 100% local.',
        ),
        value: _enabled,
        onChanged: _onChanged,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/storage_service.dart';
import '../../../services/voice_filler_words_service.dart';
import '../../../widgets/voice_rehearsal_online_help_toggle.dart';

class VoiceFillerSettingsScreen extends StatefulWidget {
  const VoiceFillerSettingsScreen({super.key});

  @override
  State<VoiceFillerSettingsScreen> createState() =>
      _VoiceFillerSettingsScreenState();
}

class _VoiceFillerSettingsScreenState extends State<VoiceFillerSettingsScreen> {
  final _controller = TextEditingController();
  List<String> _custom = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final storage = await StorageService.getInstance();
    final words = await storage.getCustomFillerWords();
    if (mounted) {
      setState(() {
        _custom = words;
        _loading = false;
      });
    }
  }

  Future<void> _addWord() async {
    final word = _controller.text.trim();
    if (word.isEmpty) return;
    final updated = VoiceFillerWordsService.addCustom(_custom, word);
    final storage = await StorageService.getInstance();
    await storage.saveCustomFillerWords(updated);
    _controller.clear();
    setState(() => _custom = updated);
  }

  Future<void> _removeWord(String word) async {
    final updated = VoiceFillerWordsService.removeCustom(_custom, word);
    final storage = await StorageService.getInstance();
    await storage.saveCustomFillerWords(updated);
    setState(() => _custom = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muletas personalizadas'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Além das muletas padrão, você pode adicionar palavras ou sons '
                  'que costuma repetir sem perceber.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                const VoiceRehearsalOnlineHelpToggle(),
                const SizedBox(height: 16),
                Text(
                  'Padrão (be-T)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: VoiceFillerWordsService.defaultFillers
                      .map(
                        (w) => Chip(
                          label: Text(w, style: const TextStyle(fontSize: 12)),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Suas muletas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          labelText: 'Nova muleta',
                          hintText: 'Ex.: basicamente, olha',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addWord(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addWord,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_custom.isEmpty)
                  Text(
                    'Nenhuma muleta personalizada.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  ..._custom.map(
                    (w) => Dismissible(
                      key: ValueKey(w),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeWord(w),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: AppTheme.errorColor,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          title: Text(w),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeWord(w),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

import 'package:flutter/foundation.dart';
import '../models/timer_preset.dart';
import '../services/storage_service.dart';

class TimerProProvider extends ChangeNotifier {
  List<TimerPreset> _presets = [];
  TimerPreset? _activePreset;

  List<TimerPreset> get presets => List.unmodifiable(_presets);
  TimerPreset? get activePreset => _activePreset;

  Future<void> load() async {
    final storage = await StorageService.getInstance();
    _presets = await storage.getTimerPresets();
    _activePreset ??= _presets.first;
    notifyListeners();
  }

  void selectPreset(TimerPreset preset) {
    _activePreset = preset;
    notifyListeners();
  }

  Future<void> savePreset(TimerPreset preset) async {
    final index = _presets.indexWhere((p) => p.id == preset.id);
    if (index >= 0) {
      _presets[index] = preset;
    } else {
      _presets.add(preset);
    }
    final storage = await StorageService.getInstance();
    await storage.saveTimerPresets(_presets);
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import '../models/admin_discurso.dart';
import '../core/utils/api_http_helper.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class DiscursoAdminProvider extends ChangeNotifier {
  final _api = ApiService();
  List<AdminDiscurso> _discursos = [];
  bool _isLoading = false;
  String? _loadingAction;
  String _promptGeral = '';
  String _promptGuia = '';

  List<AdminDiscurso> get discursos => List.unmodifiable(_discursos);
  bool get isLoading => _isLoading;
  String? get loadingAction => _loadingAction;
  String get promptGeral => _promptGeral;
  String get promptGuia => _promptGuia;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final summaries = await _api.getSpeechHistory();
      _discursos = summaries
          .map(
            (s) => AdminDiscurso(
              id: s.id,
              tema: s.tema,
              objetivo: s.objetivo,
              createdAt: s.createdAt,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('DiscursoAdmin: erro ao listar: $e');
    }
    _isLoading = false;
    notifyListeners();

    await refreshSettings();
  }

  Future<void> refreshSettings() async {
    final storage = await StorageService.getInstance();
    final cached = await storage.getDiscursoSettings();
    _promptGeral = cached['prompt_discurso_geral'] ?? '';
    _promptGuia = cached['prompt_discurso_guia'] ?? '';

    try {
      final settings = await _api.getSpeechSettings();
      final geral = settings['prompt_discurso_geral'] ?? '';
      final guia = settings['prompt_discurso_guia'] ?? '';
      if (geral.trim().isNotEmpty) _promptGeral = geral;
      if (guia.trim().isNotEmpty) _promptGuia = guia;
      await storage.saveDiscursoSettings({
        'prompt_discurso_geral': _promptGeral,
        'prompt_discurso_guia': _promptGuia,
      });
      notifyListeners();
    } on ApiNotFoundException {
      debugPrint(
        'DiscursoAdmin: settings ainda não na API (404). Usando cache local.',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('DiscursoAdmin: erro settings: $e');
      notifyListeners();
    }
  }

  Future<AdminDiscurso?> loadDetail(int id) async {
    try {
      return await _api.fetchAdminDiscurso(id);
    } catch (e) {
      debugPrint('DiscursoAdmin: erro detalhe $id: $e');
      return null;
    }
  }

  Future<AdminDiscurso?> createDiscurso(AdminDiscurso draft) async {
    _isLoading = true;
    notifyListeners();
    try {
      final created = await _api.createBackendDiscurso(draft.toJson());
      _discursos.insert(0, created);
      _isLoading = false;
      notifyListeners();
      return created;
    } catch (e) {
      debugPrint('DiscursoAdmin: erro criar: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateDiscurso(AdminDiscurso discurso) async {
    try {
      await _api.updateBackendSpeech(
        discurso.id.toString(),
        discurso.toJson(),
      );
      final index = _discursos.indexWhere((d) => d.id == discurso.id);
      if (index >= 0) {
        _discursos[index] = discurso;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('DiscursoAdmin: erro atualizar: $e');
      return false;
    }
  }

  Future<void> deleteDiscurso(int id) async {
    try {
      await _api.deleteBackendDiscurso(id);
    } catch (e) {
      debugPrint('DiscursoAdmin: erro excluir backend: $e');
    }
    _discursos.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  Future<String?> generateManuscript(int id) async {
    _loadingAction = 'manuscrito';
    notifyListeners();
    try {
      final text = await _api.generateSpeechManuscriptBackend(id.toString());
      await _refreshItemManuscript(id, text);
      return text;
    } catch (e) {
      debugPrint('DiscursoAdmin: erro gerar manuscrito: $e');
      return null;
    } finally {
      _loadingAction = null;
      notifyListeners();
    }
  }

  Future<String?> generateGuide(int id) async {
    _loadingAction = 'guia';
    notifyListeners();
    try {
      final text = await _api.generateSpeechGuideBackend(id.toString());
      final index = _discursos.indexWhere((d) => d.id == id);
      if (index >= 0) {
        _discursos[index] = _discursos[index].copyWith(guide: text);
        notifyListeners();
      }
      return text;
    } catch (e) {
      debugPrint('DiscursoAdmin: erro gerar guia: $e');
      return null;
    } finally {
      _loadingAction = null;
      notifyListeners();
    }
  }

  Future<String?> improveManuscript(
    int id,
    String instructions,
    String currentText,
  ) async {
    _loadingAction = 'improve';
    notifyListeners();
    try {
      final text = await _api.improveSpeechManuscriptBackend(
        id.toString(),
        instructions,
        currentText,
      );
      await _refreshItemManuscript(id, text);
      return text;
    } catch (e) {
      debugPrint('DiscursoAdmin: erro melhorar manuscrito: $e');
      return null;
    } finally {
      _loadingAction = null;
      notifyListeners();
    }
  }

  Future<void> _refreshItemManuscript(int id, String text) async {
    final index = _discursos.indexWhere((d) => d.id == id);
    if (index >= 0) {
      _discursos[index] =
          _discursos[index].copyWith(manuscritoCompleto: text);
      notifyListeners();
    }
  }

  Future<void> saveSettings(String geral, String guia) async {
    _promptGeral = geral;
    _promptGuia = guia;
    notifyListeners();

    final storage = await StorageService.getInstance();
    await storage.saveDiscursoSettings({
      'prompt_discurso_geral': geral,
      'prompt_discurso_guia': guia,
    });

    try {
      await _api.saveSpeechSettings(geral, guia);
    } catch (e) {
      debugPrint('DiscursoAdmin: erro salvar settings: $e');
    }
  }
}

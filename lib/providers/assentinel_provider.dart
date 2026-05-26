import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/assentinel_study.dart';
import '../core/utils/api_http_helper.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AssentinelProvider extends ChangeNotifier {
  final _apiService = ApiService();
  final _uuid = const Uuid();
  List<AssentinelStudy> _studies = [];
  bool _isLoading = false;
  String? _syncError;
  Map<String, String> _settings = {
    'prompt_inicial': '',
    'prompt_final': '',
    'prompt_resumo': '',
  };

  List<AssentinelStudy> get studies {
    final list = List<AssentinelStudy>.from(_studies);
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  bool get isLoading => _isLoading;
  String? get syncError => _syncError;
  Map<String, String> get settings => _settings;

  AssentinelStudy? getStudyById(String id) {
    try {
      return _studies.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<AssentinelStudy> _ensureValidIds(List<AssentinelStudy> studies) {
    var changed = false;
    final fixed = studies.map((study) {
      if (study.id.trim().isNotEmpty) return study;
      changed = true;
      return study.copyWith(id: _uuid.v4());
    }).toList();
    if (changed) {
      debugPrint('Assentinel: estudos sem ID do servidor receberam ID local.');
    }
    return fixed;
  }

  Map<String, String> _normalizeSettings(Map<String, String> raw) {
    return {
      'prompt_inicial': raw['prompt_inicial'] ?? '',
      'prompt_final': raw['prompt_final'] ?? '',
      'prompt_resumo': raw['prompt_resumo'] ?? '',
    };
  }

  void _mergeSettings(Map<String, String> backend) {
    for (final entry in backend.entries) {
      if (entry.value.trim().isNotEmpty) {
        _settings[entry.key] = entry.value;
      }
    }
    _settings = _normalizeSettings(_settings);
  }

  Future<void> load() async {
    _isLoading = true;
    _syncError = null;
    notifyListeners();

    final storage = await StorageService.getInstance();
    final stored = await storage.getAssentinelStudies();
    final hadInvalidId = stored.any((s) => s.id.trim().isEmpty);
    _studies = _ensureValidIds(stored);
    if (hadInvalidId) {
      await storage.saveAssentinelStudies(_studies);
    }
    _mergeSettings(_normalizeSettings(await storage.getAssentinelSettings()));
    _isLoading = false;
    notifyListeners();

    try {
      final backendList = _ensureValidIds(
        await _apiService.getBackendAssentinelStudies(),
      );
      _studies = backendList;
      await storage.saveAssentinelStudies(_studies);
      _syncError = null;
      notifyListeners();
    } on ApiNotFoundException catch (e) {
      _syncError =
          'Assentinel ainda não publicado no servidor (aguardar deploy de /api/v1/assentinel). Dados locais disponíveis.';
      debugPrint('Assentinel: $e');
    } catch (e) {
      _syncError = 'Não foi possível sincronizar estudos: $e';
      debugPrint('Assentinel: $e');
    }

    await refreshSettings();
  }

  Future<void> refreshSettings() async {
    final storage = await StorageService.getInstance();
    _mergeSettings(_normalizeSettings(await storage.getAssentinelSettings()));

    try {
      final backend = _normalizeSettings(
        await _apiService.getAssentinelSettings(),
      );
      _mergeSettings(backend);
      await storage.saveAssentinelSettings(_settings);
      notifyListeners();
    } on ApiNotFoundException catch (e) {
      debugPrint('Assentinel: prompts não publicados — $e');
      notifyListeners();
    } catch (e) {
      debugPrint('Assentinel: Erro ao carregar prompts: $e');
      notifyListeners();
    }
  }

  Future<void> addStudy(String content) async {
    _isLoading = true;
    notifyListeners();

    final storage = await StorageService.getInstance();
    AssentinelStudy newStudy;

    try {
      newStudy = await _apiService.createBackendAssentinelStudy(content);
    } catch (e) {
      debugPrint('Assentinel: Falha ao criar no backend (criando local): $e');
      final now = DateTime.now();
      newStudy = AssentinelStudy(
        id: _uuid.v4(),
        conteudoEstudo: content,
        createdAt: now,
        updatedAt: now,
      );
    }

    _studies.add(newStudy);
    await storage.saveAssentinelStudies(_studies);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteStudy(String id) async {
    _studies.removeWhere((s) => s.id == id);
    final storage = await StorageService.getInstance();
    await storage.saveAssentinelStudies(_studies);
    notifyListeners();

    try {
      await _apiService.deleteBackendAssentinelStudy(id);
    } catch (e) {
      debugPrint('Assentinel: Erro ao deletar no backend (mantido localmente): $e');
    }
  }

  Future<void> generateComment(String studyId, String type) async {
    final id = studyId.trim();
    if (id.isEmpty) {
      _syncError =
          'Este estudo não tem identificador válido. Exclua-o e importe o texto novamente.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _syncError = null;
    notifyListeners();

    final index = _studies.indexWhere((s) => s.id == id);
    if (index == -1) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final generatedText =
          await _apiService.generateAssentinelComment(id, type);

      AssentinelStudy updated;
      if (type == 'comentario-inicial') {
        updated = _studies[index].copyWith(
          comentarioInicial: generatedText,
          updatedAt: DateTime.now(),
        );
      } else if (type == 'comentario-final') {
        updated = _studies[index].copyWith(
          comentarioFinal: generatedText,
          updatedAt: DateTime.now(),
        );
      } else {
        updated = _studies[index].copyWith(
          resumoComentarios: generatedText,
          updatedAt: DateTime.now(),
        );
      }

      _studies[index] = updated;
      final storage = await StorageService.getInstance();
      await storage.saveAssentinelStudies(_studies);
    } catch (e) {
      debugPrint('Assentinel: Erro ao gerar comentário: $e');
      final snippet = _studies[index].conteudoEstudo.length > 150
          ? '${_studies[index].conteudoEstudo.substring(0, 150)}...'
          : _studies[index].conteudoEstudo;
      final generatedText =
          'Comentário simulado ($type) — falha de conexão.\n\n$snippet';

      AssentinelStudy updated;
      if (type == 'comentario-inicial') {
        updated = _studies[index].copyWith(
          comentarioInicial: generatedText,
          updatedAt: DateTime.now(),
        );
      } else if (type == 'comentario-final') {
        updated = _studies[index].copyWith(
          comentarioFinal: generatedText,
          updatedAt: DateTime.now(),
        );
      } else {
        updated = _studies[index].copyWith(
          resumoComentarios: generatedText,
          updatedAt: DateTime.now(),
        );
      }

      _studies[index] = updated;
      final storage = await StorageService.getInstance();
      await storage.saveAssentinelStudies(_studies);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveSettings(Map<String, String> settings) async {
    _settings = _normalizeSettings(settings);
    notifyListeners();

    final storage = await StorageService.getInstance();
    await storage.saveAssentinelSettings(_settings);

    try {
      await _apiService.saveAssentinelSettings(_settings);
    } catch (e) {
      debugPrint('Assentinel: Erro ao salvar configurações no backend: $e');
    }
  }
}

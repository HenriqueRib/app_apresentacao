import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/parte.dart';
import '../core/utils/api_http_helper.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ParteProvider extends ChangeNotifier {
  final _apiService = ApiService();
  final _uuid = const Uuid();
  List<Parte> _partes = [];
  bool _isLoading = false;
  String _promptGeral = '';

  List<Parte> get partes {
    final list = List<Parte>.from(_partes);
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  bool get isLoading => _isLoading;
  String get promptGeral => _promptGeral;

  Parte? getParteById(String id) {
    try {
      return _partes.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    // 1. Carregar local primeiro
    final storage = await StorageService.getInstance();
    _partes = await storage.getPartes();
    _isLoading = false;
    notifyListeners();

    // 2. Sincronizar com backend (se possível)
    try {
      final backendList = await _apiService.getBackendPartes();
      _partes = backendList;
      await storage.savePartes(_partes);
      notifyListeners();
    } on ApiNotFoundException {
      debugPrint('Partes: API ainda não publicada (404). Usando dados locais.');
    } catch (e) {
      debugPrint('Partes: Erro ao sincronizar: $e');
    }

    await refreshSettings();
  }

  Future<void> refreshSettings() async {
    final storage = await StorageService.getInstance();
    final cached = await storage.getPartePromptGeral();
    if (cached.isNotEmpty) _promptGeral = cached;

    try {
      final prompt = await _apiService.getParteSettings();
      if (prompt.trim().isNotEmpty) {
        _promptGeral = prompt;
        await storage.savePartePromptGeral(_promptGeral);
      }
      notifyListeners();
    } on ApiNotFoundException {
      debugPrint('Partes: prompt ainda não na API (404). Usando cache local.');
      notifyListeners();
    } catch (e) {
      debugPrint('Partes: Erro ao carregar prompt: $e');
      notifyListeners();
    }
  }

  Future<void> createParte({
    required String tema,
    required List<ParteTopico> topicos,
    String? conteudoOriginal,
  }) async {
    _isLoading = true;
    notifyListeners();

    final storage = await StorageService.getInstance();
    Parte newParte;
    final now = DateTime.now();

    final tempParte = Parte(
      id: _uuid.v4(),
      tema: tema,
      topicos: topicos,
      conteudoOriginal: conteudoOriginal,
      createdAt: now,
      updatedAt: now,
    );

    try {
      newParte = await _apiService.createBackendParte(tempParte);
    } catch (e) {
      debugPrint('Partes: Falha ao criar no backend (criando local): $e');
      newParte = tempParte;
    }

    _partes.add(newParte);
    await storage.savePartes(_partes);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateParte(Parte parte) async {
    final index = _partes.indexWhere((p) => p.id == parte.id);
    if (index == -1) return;

    _partes[index] = parte.copyWith(updatedAt: DateTime.now());
    final storage = await StorageService.getInstance();
    await storage.savePartes(_partes);
    notifyListeners();

    try {
      await _apiService.updateBackendParte(parte.id, parte);
    } catch (e) {
      debugPrint('Partes: Erro ao atualizar no backend (mantido localmente): $e');
    }
  }

  Future<void> deleteParte(String id) async {
    _partes.removeWhere((p) => p.id == id);
    final storage = await StorageService.getInstance();
    await storage.savePartes(_partes);
    notifyListeners();

    try {
      await _apiService.deleteBackendParte(id);
    } catch (e) {
      debugPrint('Partes: Erro ao deletar no backend (mantido localmente): $e');
    }
  }

  Future<void> generateEsboco(String id) async {
    _isLoading = true;
    notifyListeners();

    final index = _partes.indexWhere((p) => p.id == id);
    if (index == -1) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final generatedText = await _apiService.generateParteEsboco(id);
      _partes[index] = _partes[index].copyWith(
        esbocoManuscrito: generatedText,
        updatedAt: DateTime.now(),
      );
      final storage = await StorageService.getInstance();
      await storage.savePartes(_partes);
    } catch (e) {
      debugPrint('Partes: Erro ao gerar esboço no backend: $e');
      // Mock Fallback
      String generatedText = "### Introdução\nSimulação de Introdução para o tema: ${_partes[index].tema}\n\n"
          "### Desenvolvimento\n";
      for (var t in _partes[index].topicos) {
        generatedText += "- **Tópico: ${t.descricao}**\n";
        if (t.texto != null && t.texto!.isNotEmpty) generatedText += "  *Versículo: ${t.texto}*\n";
        if (t.fonte != null && t.fonte!.isNotEmpty) generatedText += "  *Fonte: ${t.fonte}*\n";
        generatedText += "  Explicação simulada para o tópico da parte.\n\n";
      }
      generatedText += "### Conclusão\nResumo e aplicação prática simulados.";

      _partes[index] = _partes[index].copyWith(
        esbocoManuscrito: generatedText,
        updatedAt: DateTime.now(),
      );
      final storage = await StorageService.getInstance();
      await storage.savePartes(_partes);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> improveEsboco(String id, String instructions) async {
    _isLoading = true;
    notifyListeners();

    final index = _partes.indexWhere((p) => p.id == id);
    if (index == -1) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    final currentEsboco = _partes[index].esbocoManuscrito ?? '';

    try {
      final generatedText = await _apiService.improveParteEsboco(id, instructions, currentEsboco);
      _partes[index] = _partes[index].copyWith(
        esbocoManuscrito: generatedText,
        updatedAt: DateTime.now(),
      );
      final storage = await StorageService.getInstance();
      await storage.savePartes(_partes);
    } catch (e) {
      debugPrint('Partes: Erro ao melhorar esboço: $e');
      _partes[index] = _partes[index].copyWith(
        esbocoManuscrito: "$currentEsboco\n\n*[Melhoria Simulada]*: Trecho reescrito com instrução '$instructions'.",
        updatedAt: DateTime.now(),
      );
      final storage = await StorageService.getInstance();
      await storage.savePartes(_partes);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveSettings(String prompt) async {
    _promptGeral = prompt;
    notifyListeners();

    final storage = await StorageService.getInstance();
    await storage.savePartePromptGeral(prompt);

    try {
      await _apiService.saveParteSettings(prompt);
    } catch (e) {
      debugPrint('Partes: Erro ao salvar configurações no backend: $e');
    }
  }
}

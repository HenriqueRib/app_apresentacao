import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/api_routes.dart';
import '../models/weekly_comment_note.dart';
import '../models/resposta_gerada.dart';
import '../core/utils/api_http_helper.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class MeetingHubProvider extends ChangeNotifier {
  final _apiService = ApiService();
  final _uuid = const Uuid();
  List<WeeklyCommentNote> _notes = [];
  List<RespostaGerada> _respostas = [];
  bool _isLoaded = false;
  bool _isLoadingRespostas = false;

  List<WeeklyCommentNote> get notes => List.unmodifiable(_notes);
  List<RespostaGerada> get respostas {
    final list = List<RespostaGerada>.from(_respostas);
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }
  bool get isLoaded => _isLoaded;
  bool get isLoadingRespostas => _isLoadingRespostas;

  Future<void> load() async {
    final storage = await StorageService.getInstance();
    _notes = await storage.getWeeklyCommentNotes();
    _respostas = await storage.getRespostasGeradas();
    _isLoaded = true;
    notifyListeners();

    // Sincronizar respostas do backend
    _isLoadingRespostas = true;
    notifyListeners();
    try {
      final backendRespostas = await _apiService.getBackendRespostasGeradas();
      _respostas = backendRespostas;
      await storage.saveRespostasGeradas(_respostas);
    } on ApiNotFoundException {
      debugPrint(
        'MeetingHub: API de respostas ainda não publicada (404). Usando dados locais.',
      );
    } catch (e) {
      debugPrint('MeetingHub: Erro ao sincronizar respostas: $e');
    }
    _isLoadingRespostas = false;
    notifyListeners();
  }

  WeeklyCommentNote? getNote(String weekKey, int commentIndex) {
    try {
      return _notes.firstWhere(
        (n) => n.weekKey == weekKey && n.commentIndex == commentIndex,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> toggleFavorite(String weekKey, int commentIndex) async {
    final existing = getNote(weekKey, commentIndex);
    if (existing != null) {
      await _upsert(existing.copyWith(isFavorite: !existing.isFavorite));
    } else {
      await _upsert(WeeklyCommentNote(
        weekKey: weekKey,
        commentIndex: commentIndex,
        isFavorite: true,
      ));
    }
  }

  Future<void> setPersonalNote(
    String weekKey,
    int commentIndex,
    String note,
  ) async {
    final existing = getNote(weekKey, commentIndex);
    if (existing != null) {
      await _upsert(existing.copyWith(personalNote: note));
    } else {
      await _upsert(WeeklyCommentNote(
        weekKey: weekKey,
        commentIndex: commentIndex,
        personalNote: note,
      ));
    }
  }

  Future<void> _upsert(WeeklyCommentNote note) async {
    _notes.removeWhere(
      (n) => n.weekKey == note.weekKey && n.commentIndex == note.commentIndex,
    );
    if (note.isFavorite || note.personalNote.isNotEmpty) {
      _notes.add(note);
    }
    final storage = await StorageService.getInstance();
    await storage.saveWeeklyCommentNotes(_notes);
    notifyListeners();
  }

  List<WeeklyCommentNote> favoritesForWeek(String weekKey) =>
      _notes.where((n) => n.weekKey == weekKey && n.isFavorite).toList();

  // --- RESPOSTAS GERADAS METHODS ---
  Future<void> addResposta({
    String? pergunta,
    required String textoBase,
    required String fontePesquisa,
    String? promptEspecifico,
  }) async {
    _isLoadingRespostas = true;
    notifyListeners();

    final storage = await StorageService.getInstance();
    RespostaGerada newResposta;

    try {
      newResposta = await _apiService.generateRespostaGerada(
        pergunta: pergunta,
        textoBase: textoBase,
        fontePesquisa: fontePesquisa,
        promptEspecifico: promptEspecifico,
      );
    } catch (e) {
      debugPrint('MeetingHub: Erro ao gerar resposta no backend (fallback local): $e');
      final now = DateTime.now();
      String simulated = "Resposta Simulada por IA:\n\nCom base no texto '$textoBase' e na pesquisa em '$fontePesquisa', podemos concluir que a lição prática é de dedicação integral e preparação sincera.";
      newResposta = RespostaGerada(
        id: _uuid.v4(),
        pergunta: pergunta,
        textoBase: textoBase,
        fontePesquisa: fontePesquisa,
        promptEspecifico: promptEspecifico,
        respostaGerada: simulated,
        createdAt: now,
        updatedAt: now,
      );
    }

    _respostas.add(newResposta);
    await storage.saveRespostasGeradas(_respostas);
    _isLoadingRespostas = false;
    notifyListeners();
  }

  Future<void> improveResposta(String id, String instructions) async {
    _isLoadingRespostas = true;
    notifyListeners();

    final index = _respostas.indexWhere((r) => r.id == id);
    if (index == -1) {
      _isLoadingRespostas = false;
      notifyListeners();
      return;
    }

    final currentText = _respostas[index].respostaGerada;

    try {
      final updated = await _apiService.improveRespostaGerada(id, instructions);
      _respostas[index] = updated;
      final storage = await StorageService.getInstance();
      await storage.saveRespostasGeradas(_respostas);
    } catch (e) {
      debugPrint('MeetingHub: Erro ao melhorar resposta: $e');
      _respostas[index] = _respostas[index].copyWith(
        respostaGerada: "$currentText\n\n*[Melhoria Simulada]*: Resposta ajustada com foco em '$instructions'.",
        updatedAt: DateTime.now(),
      );
      final storage = await StorageService.getInstance();
      await storage.saveRespostasGeradas(_respostas);
    }

    _isLoadingRespostas = false;
    notifyListeners();
  }

  Future<void> deleteResposta(String id) async {
    _respostas.removeWhere((r) => r.id == id);
    final storage = await StorageService.getInstance();
    await storage.saveRespostasGeradas(_respostas);
    notifyListeners();

    try {
      await ApiHttpHelper.delete(
        '${ApiRoutes.respostasGeradas}/$id',
        timeout: const Duration(seconds: 10),
      );
    } catch (_) {}
  }
}


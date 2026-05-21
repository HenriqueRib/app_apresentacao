/// Rotas de produção — ver [doc/mobile/ROTAS-PRODUCAO.md].
///
/// Não usar `/api/wol/assentinela/*` (painel web com sessão, não API JSON).
class ApiRoutes {
  ApiRoutes._();

  // --- Central da Reunião (comentários) — publicado ---
  static const comentariosSemanal = '/v1/comentarios/semanal';
  static const comentariosHistorico = '/v1/comentarios/historico';
  /// Gerar comentários IA (legado em produção — IaController).
  static const wolComentariosGerar = '/wol/comentarios';

  // --- Discursos — parcial ---
  static const discursos = '/v1/discursos';
  static const discursosGerarManuscritoTotal =
      '/v1/discursos/gerar-manuscrito/total';
  static const discursosSugerirVersiculos = '/v1/discursos/sugerir-versiculos';

  // --- Assentinel — após deploy do backend (somente v1) ---
  static const assentinelEstudos = '/v1/assentinel/estudos';
  static const assentinelSettings = '/v1/assentinel/settings';

  // --- Ainda não publicados (sem fallback /wol) ---
  static const respostasGeradas = '/v1/respostas-geradas';
  static const partes = '/v1/partes';
  static const partesSettings = '/v1/partes/settings';
  static const discursosSettings = '/v1/discursos/settings';
}

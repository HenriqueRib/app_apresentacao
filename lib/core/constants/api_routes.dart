/// Rotas de produção — ver [doc/mobile/ROTAS-PRODUCAO.md].
///
/// Não usar `/api/wol/assentinela/*` (painel web com sessão, não API JSON).
/// Não usar `/oratoria/avaliar-conteudo` (substituída por `/v1/avaliar/esboco`).
class ApiRoutes {
  ApiRoutes._();

  // --- Central da Reunião (comentários) — publicado ---
  static const comentariosSemanal = '/v1/comentarios/semanal';
  static const comentariosHistorico = '/v1/comentarios/historico';
  /// Gerar comentários IA — rota legada (produção hoje).
  /// Migrar para [comentariosGerar] quando backend v1 publicar.
  static const wolComentariosGerar = '/wol/comentarios';
  static const comentariosGerar = '/v1/comentarios/gerar';

  // --- Discursos — parcial ---
  static const discursos = '/v1/discursos';
  static const discursosGerarManuscritoTotal =
      '/v1/discursos/gerar-manuscrito/total';
  static const discursosSugerirVersiculos = '/v1/discursos/sugerir-versiculos';
  static const discursosSettings = '/v1/discursos/settings';

  // --- Assentinel — canônico: comentario-inicial / comentario-final / resumo ---
  // Não usar `generate-initial` nem `/api/wol/assentinela`.
  static const assentinelEstudos = '/v1/assentinel/estudos';
  static const assentinelSettings = '/v1/assentinel/settings';

  // --- Partes (10 min) ---
  static const partes = '/v1/partes';
  static const partesSettings = '/v1/partes/settings';

  // --- Avaliação de esboço (P0) — rota canônica ---
  static const avaliarEsboco = '/v1/avaliar/esboco';

  // --- Respostas geradas ---
  static const respostasGeradas = '/v1/respostas-geradas';

  // --- Ensaio e Aprimorar (P1) ---
  static const ensaioRegistrar = '/v1/ensaio/registrar';
  static const ensaioMetasTempo = '/v1/ensaio/metas-tempo';
  static const aprimorarFeedback = '/v1/aprimorar/feedback';

  // --- Estudo guiado (P1) ---
  static const estudoPesquisa = '/v1/estudo/pesquisa';
  static const estudoMeditacao = '/v1/estudo/meditacao';
  static const estudoMemorizar = '/v1/estudo/memorizar';
  static const estudoProgresso = '/v1/estudo/progresso';

  // --- Avaliação de oradores S-315 (P2, auth ancião/avaliador) ---
  static const avaliacoesOrador = '/v1/avaliacoes-orador';
}

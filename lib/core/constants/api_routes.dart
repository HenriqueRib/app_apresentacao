/// Rotas de produção — ver [doc/mobile/ROTAS-PRODUCAO.md].
///
/// Não usar `/api/wol/assentinela/*` (painel web com sessão, não API JSON).
/// Não usar `/oratoria/avaliar-conteudo` (substituída por `/v1/avaliar/esboco`).
class ApiRoutes {
  ApiRoutes._();

  // --- Central da Reunião (comentários) — publicado ---
  static const comentariosSemanal = '/v1/comentarios/semanal';
  static const comentariosHistorico = '/v1/comentarios/historico';
  /// Gerar comentários IA — rota v1 (backend já publicou).
  static const comentariosGerar = '/v1/comentarios/gerar';
  /// Legado: usar [comentariosGerar] preferencialmente.
  static const wolComentariosGerar = '/wol/comentarios';

  // --- Discursos ---
  static const discursos = '/v1/discursos';
  static const discursosSettings = '/v1/discursos/settings';
  static const discursosGerarManuscritoTotal =
      '/v1/discursos/gerar-manuscrito/total';
  static const discursosSugerirVersiculos = '/v1/discursos/sugerir-versiculos';

  // --- Assentinel ---
  // Canônico: comentario-inicial / comentario-final / resumo
  // Não usar `generate-initial` nem `/api/wol/assentinela`.
  static const assentinelEstudos = '/v1/assentinel/estudos';
  static const assentinelSettings = '/v1/assentinel/settings';

  // --- Partes (10 min) ---
  static const partes = '/v1/partes';
  static const partesSettings = '/v1/partes/settings';

  // --- Avaliação de esboço (P0) — rota canônica ---
  static const avaliarEsboco = '/v1/avaliar/esboco';
  static const avaliarEsbocoHistorico = '/v1/avaliar/esboco/historico';

  // --- Respostas geradas ---
  static const respostasGeradas = '/v1/respostas-geradas';

  // --- Ensaio (P1) ---
  static const ensaioRegistrar = '/v1/ensaio/registrar';
  static const ensaioMetasTempo = '/v1/ensaio/metas-tempo';

  // --- Aprimorar (P1) ---
  static const aprimorarFeedback = '/v1/aprimorar/feedback';

  // --- Estudo guiado (P1) ---
  static const estudoPesquisa = '/v1/estudo/pesquisa';
  static const estudoMeditacao = '/v1/estudo/meditacao';
  static const estudoMemorizar = '/v1/estudo/memorizar';
  static const estudoProgresso = '/v1/estudo/progresso';

  // --- Avaliação de oradores S-315 (P2, auth ancião/avaliador) ---
  static const avaliacoesOrador = '/v1/avaliacoes-orador';
  static const avaliacoesOradorRascunho =
      '/v1/avaliacoes-orador/gerar-rascunho-observacoes';

  // --- Biblioteca be-T (53 características) ---
  static const bibliotecaBet = '/v1/biblioteca-bet';

  // --- Plano de Desenvolvimento do Orador ---
  static const planoDesenvolvimento = '/v1/plano-desenvolvimento';
  static const planoDesenvolvimentoAnalytics =
      '/v1/plano-desenvolvimento/analytics';
  static const planoDesenvolvimentoGerar = '/v1/plano-desenvolvimento/gerar';
  static const planoDesenvolvimentoCoaching =
      '/v1/plano-desenvolvimento/coaching';

  // --- Comparador de Esboços ---
  static const compararEsbocos = '/v1/comparar/esbocos';

  // --- Exercícios de Oratória ---
  static const exerciciosGerar = '/v1/exercicios/gerar';
  static const exerciciosAquecimento = '/v1/exercicios/aquecimento';
}

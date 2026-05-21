# Roadmap Flutter — Integração ensino + novas ferramentas

**Para:** implementação no app *Poder de Convencer*  
**Data:** 21/05/2026  
**Backend:** ver [briefing-backend-novas-rotas.md](./briefing-backend-novas-rotas.md)

---

## 1. Entendimento da dor (produto)

| Dor | Situação hoje | O que resolve |
|-----|---------------|---------------|
| Ciclo na home **sem cérebro no servidor** | 5 passos funcionam offline; IA só em poucas rotas | APIs de avaliar, ensaio, feedback |
| Esboço be-T vs manuscrito | Backend gera **prosa**; app pede **tópicos + LEIA** | `avaliar/esboco` + modo `esboco_topicos` em partes |
| Partes 10 min | UI Timer Pro local; geração de parte só no WOL | API partes + avaliação antes do ensaio |
| Aprimorar sem histórico nuvem | Feedback só em `SpeechProvider` local | Sync `aprimorar/feedback` |
| Instrutores / anciãos | Nada tipo S-315 | Módulo opcional “Avaliação de oradores” (P2) |

A home já exibe **Ciclo de Performance** em `home_screen_new.dart` — falta **ligar cada passo às novas rotas** quando o backend publicar.

---

## 2. Mapa de funcionalidades sugeridas (por contexto)

### Palestras e discursos públicos

1. **Avaliar esboço (Shinyashiki + be-T)** — botão em Preparar / Criar Esboço  
2. **Validar LEIA** por versículo (badge vermelho → chamar API)  
3. **Gerar guia de estudo** (`generate-guia`) antes do manuscrito  
4. **Proporção de tempo** (intro 10% / corpo 80% / conclusão 10%) com alerta visual  
5. **Avaliar manuscrito** (segunda passagem após expandir texto)

### Partes de reunião (10 min)

1. **Wizard parte**: tema → tópicos → gerar esboço tópicos (não corrido)  
2. **Avaliar esboço** com foco em **uma** característica be-T da designação  
3. **Timer Pro** já existe — registrar ensaio no backend  
4. **Checklist palco** + meta 1+7+2 sincronizada com `GET /ensaio/metas-tempo`

### Comentários e Sentinela

1. Expor **Assentinel** e **Respostas** (já preparado no contrato; 404 hoje)  
2. Central da Reunião: migrar gerar comentários para `/v1/comentarios/gerar`

### Instrução / anciãos (P2, feature flag)

1. Formulário inspirado **S-315**: triagem, DIS/ENT/INT, observações  
2. IA só **rascunha** observações; ancião edita e salva  
3. Export PDF local (sem enviar dados sensíveis a terceiros sem consentimento)

---

## 3. Ordem de implementação no Flutter

### Sprint 1 — Cliente API + Preparar (P0)

| # | Tarefa | Arquivos / notas |
|---|--------|------------------|
| 1 | `EnsinoApiService` central | `lib/services/ensino_api_service.dart` |
| 2 | Modelos `AvaliacaoEsboco`, `ProporcaoTempo` | `lib/models/avaliacao_esboco.dart` |
| 3 | Tela **Resultado da avaliação** | `lib/screens/preparation/outline_evaluation_screen.dart` |
| 4 | Botão “Avaliar com IA” no `OutlineEditorScreen` | Envia `Speech.outline.toJson()` |
| 5 | Tratamento offline: fila ou mensagem clara | Reutilizar padrão de `ApiService` existente |

**UX:** após avaliação, cards expansíveis: Estrutura be-T | LEIA | Pilares | Características | Próximos passos.

### Sprint 2 — Partes + Ciclo (P1)

| # | Tarefa |
|---|--------|
| 1 | `ParteProvider` + telas lista/edição |
| 2 | Hub: card “Minha Parte (10 min)” |
| 3 | Vincular `Speech` ↔ `parte_id` opcional no metadata |
| 4 | Passo Treinar: `POST ensaio/registrar` ao salvar sessão |
| 5 | Passo Aprimorar: sync feedback |

### Sprint 3 — Estudo guiado (P1)

| # | Tarefa |
|---|--------|
| 1 | Aba “Pesquisa” em Planejar (perguntas IA) |
| 2 | Meditação: bottom sheet com perguntas por ponto |
| 3 | Memorizar: integrar com flashcards do Estúdio de Esboços |

### Sprint 4 — Avaliação oradores (P2, flag)

| # | Tarefa |
|---|--------|
| 1 | `lib/screens/tools/speaker_evaluation/` |
| 2 | Formulário multi-step (triagem → notas → observações) |
| 3 | `SpeakerEvaluationProvider` — só se `FeatureFlags.s315` |

---

## 4. Esboço de código — `EnsinoApiService`

```dart
class EnsinoApiService {
  final String baseUrl; // AppConstants.apiBaseUrl

  Future<AvaliacaoEsboco> avaliarEsboco({
    required String tipo,
    required String objetivoCentral,
    required Map<String, dynamic> esboco,
    int? caracteristicaFocoId,
    int duracaoMinutos = 10,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/avaliar/esboco'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tipo': tipo,
        'objetivo_central': objetivoCentral,
        'esboco': esboco,
        'duracao_minutos': duracaoMinutos,
        if (caracteristicaFocoId != null)
          'caracteristica_foco_id': caracteristicaFocoId,
      }),
    );
    // unwrap data, parse AvaliacaoEsboco.fromJson
  }
}
```

Mapear `Speech` → payload:

```dart
Map<String, dynamic> outlinePayload(Speech speech) => {
  'introducao': speech.outline.introduction,
  'pontos_principais': speech.outline.mainPoints.map((p) => {
    'titulo': p.title,
    'ideias': p.keyIdeas,
    'textos_biblicos': p.biblicalTexts.map((t) => {
      'referencia': t.reference,
      'ler': t.read,
      'explicar': t.explain,
      'ilustrar': t.illustrate,
      'aplicar': t.apply,
    }),
    'ilustracoes': p.illustrations,
  }).toList(),
  'conclusao': speech.outline.conclusion,
};
```

---

## 5. Pontos de entrada na UI (Ciclo de Performance)

| Passo | Ação nova |
|-------|-----------|
| **Planejar** | “Pesquisa guiada” + manter objetivo/audiência |
| **Preparar** | **Avaliar esboço** (principal) + sugerir versículos (já existe API) |
| **Treinar** | Salvar ensaio → API |
| **Executar** | Sem mudança obrigatória |
| **Aprimorar** | Sync feedback + histórico de avaliações de esboço |

**Tools Hub** (`tools_hub_section.dart`):

- Novo card: **“Avaliar esboço”** (atalho se não houver discurso ativo)  
- P2: **“Avaliação de oradores”** (oculto por padrão)

---

## 6. Dependências do backend (bloqueantes)

| Rota | Sprint Flutter |
|------|----------------|
| `POST /v1/avaliar/esboco` | Sprint 1 |
| `POST /v1/partes/*` | Sprint 2 |
| `POST /v1/ensaio/registrar` | Sprint 2 |
| `POST /v1/aprimorar/feedback` | Sprint 2 |
| `POST /v1/avaliacoes-orador` | Sprint 4 |

Enquanto 404: manter mock local em `assets/data/mock_avaliacao_esboco.json` para UI review.

---

## 7. Testes

| Tipo | O quê |
|------|-------|
| Unit | `AvaliacaoEsboco.fromJson`, `outlinePayload` |
| Widget | tela resultado com mock |
| Integration | chamada real staging quando rota existir |

---

## 8. Documentação a atualizar após cada sprint

- [PROGRESSO.md](../PROGRESSO.md) — backlog IA  
- [contrato-json-backend-flutter.md](../mobile/contrato-json-backend-flutter.md)  
- README — ferramentas aditivas  

---

## 9. Informações que ainda ajudariam (do produto)

Responder quando possível — não bloqueia o briefing:

1. **Auth:** Sanctum, JWT ou API key fixa no app de palestra?  
2. **Público S-315:** só anciãos internos ou também instrutores de escola?  
3. **OCR:** prioridade real ou só texto digitado/foto manual?  
4. **Idiomas:** só pt-BR ou avaliação em segundo idioma (como S-315)?  
5. **Privacidade:** avaliações de orador ficam só no servidor da congregação ou sync por usuário?

---

## 10. Resumo em uma frase

O Flutter já tem o **ciclo completo local**; o próximo salto é **Preparar com avaliação IA** e **Aprimorar/Treinar persistidos**, depois **partes na API** e, se fizer sentido, **formulário tipo S-315** para instrutores.

# Contrato — Análise online do Ensaio be-T

Documento para o time backend implementar a rota consumida pelo app Flutter quando o usuário **ativa a ajuda online** e solicita **análise manual** no histórico de ensaio.

**App:** offline-first — ensaio, métricas, histórico e S-315 heurístico funcionam **sem internet**. Esta rota é **opcional** e **nunca bloqueia** o fluxo local.

**Referência geral:** [contrato-json-backend-flutter.md](./contrato-json-backend-flutter.md)

---

## Rota canônica

| Método | Rota | Prioridade | Auth |
|--------|------|------------|------|
| `POST` | `/v1/ensaio/analisar` | P1 | Recomendado (Bearer) — app ainda não envia token |

**Base URL:** mesma de `AppConstants.apiBaseUrl` (produção Laravel).

---

## Quando o app chama

1. Preferência local `voice_rehearsal_online_help_enabled = true` (toggle nas configurações do ensaio).
2. Usuário abre **Relatório do ensaio** no histórico.
3. Usuário toca **Análise online** (ou **Reanalisar**).
4. App valida localmente: transcrição não vazia e `word_count >= 20`.
5. App envia `POST /v1/ensaio/analisar` com transcrição + métricas já calculadas no dispositivo.
6. App persiste a resposta em `onlineAnalysis` no histórico local (não exige persistência no servidor).

**Não chama automaticamente** ao encerrar sessão (v1).

---

## Request

`Content-Type: application/json`

```json
{
  "ensaio_id": "uuid-gerado-no-app",
  "modo": "treino",
  "topico": "esperança bíblica",
  "duracao_segundos": 612,
  "nota_local": 7.8,
  "transcricao": {
    "texto": "transcrição corrida completa...",
    "texto_formatado": "parágrafos opcionais..."
  },
  "metricas_locais": {
    "wpm": 118.5,
    "word_count": 245,
    "filler_count": 12,
    "long_pause_count": 3,
    "vague_word_count": 2,
    "avg_amplitude_db": -28.4,
    "amplitude_variance": 4.2,
    "live_score": 7.8
  },
  "estrutura_local": {
    "introScore": 2,
    "conclusionScore": 1,
    "timeScore": 2,
    "segments": []
  },
  "caracteristicas_be_t": [
    { "id": 38, "score": 2 },
    { "id": 39, "score": 1 },
    { "id": 4, "score": 3 }
  ],
  "insights_locais": [
    {
      "category": "muletas",
      "message": "Palavra \"é\" repetida 8 vezes",
      "suggestion": "Faça pausa curta em vez de repetir.",
      "characteristic_id": 9,
      "severity_rank": 3
    }
  ],
  "s315_local": {
    "notas": { "DIS": "B+", "ENT": "NR" },
    "bullets": ["Clareza bíblica", "Introdução envolvente"]
  },
  "idioma": "pt-BR"
}
```

### Validação (backend)

| Campo | Regra |
|-------|-------|
| `transcricao.texto` | Obrigatório, mínimo ~20 palavras |
| `duracao_segundos` | Obrigatório, > 0 |
| `modo` | `treino` ou `gravacao` |
| `idioma` | Default `pt-BR` |
| Demais | Opcionais; usar como contexto para IA |

**Importante:** o app **não envia áudio** nesta versão. O backend **não deve** tentar re-transcrever; use `transcricao.texto` como fonte da fala.

---

## Response `200`

Envelope padrão Laravel:

```json
{
  "data": {
    "pontos_fortes": [
      "Introdução com pergunta que prende a atenção",
      "Tom respeitoso ao citar textos bíblicos"
    ],
    "pontos_melhorar": [
      "Conclusão termina sem chamada clara à ação",
      "Excesso de muletas no meio do discurso"
    ],
    "proximos_passos": [
      "Reescrever a conclusão em 2 frases com aplicação prática",
      "Ensaiar pausas no lugar de \"é\" e \"então\""
    ],
    "estrutura": {
      "introducao": {
        "status": "ok",
        "comentario": "Gancho inicial eficaz."
      },
      "corpo": {
        "status": "atencao",
        "comentario": "Transições entre pontos poderiam ser mais explícitas."
      },
      "conclusao": {
        "status": "falta",
        "comentario": "Falta resumo e convite à ação."
      }
    },
    "caracteristicas_be_t": [
      {
        "id": 38,
        "titulo": "Introdução",
        "nota": "B+",
        "evidencia": "Pergunta retórica nos primeiros 30 segundos.",
        "sugestao": "Manter esse estilo de abertura."
      },
      {
        "id": 39,
        "titulo": "Conclusão",
        "nota": "C",
        "evidencia": "Encerramento genérico sem aplicação.",
        "sugestao": "Indique o que a assistência pode fazer esta semana."
      }
    ],
    "s315_enriquecido": {
      "habilidade_orador": "Texto expandido para item (9) — clareza, organização, tom ao falar...",
      "personalidade": "Texto expandido para item (10) — humildade, equilíbrio, zelo...",
      "aspectos": [
        {
          "label": "Clareza bíblica",
          "status": "ok",
          "detail": "Referências explicadas de forma acessível."
        },
        {
          "label": "Fluência",
          "status": "atencao",
          "detail": "Muletas frequentes no segundo terço."
        }
      ]
    },
    "disclaimer": "Rascunho auxiliar gerado por IA. Não substitui a avaliação do corpo de anciãos.",
    "backend_version": "2026.05.1"
  }
}
```

### Campos de `status` (estrutura e aspectos S-315)

Valores aceitos pelo app: `ok`, `atencao`, `falta`.

### Notas be-T (características)

Formato sugerido: `A+`, `A`, `A-`, `B+`, `B`, `B-`, `C`, `NR`.

---

## Comportamento esperado do backend

1. **Receber contexto local** — transcrição, métricas, scores be-T, insights e rascunho S-315 local (`s315_local`) já calculados no app.
2. **Gerar feedback enriquecido** — usar LLM (ou regras + LLM) para produzir observações mais contextualizadas que a heurística local, citando trechos da transcrição quando possível.
3. **Enriquecer S-315** — expandir itens (9) e (10) com base em `s315_local.notas` + transcrição. Pode reutilizar internamente `POST /v1/avaliacoes-orador/gerar-rascunho-observacoes`; o app **só chama** `/v1/ensaio/analisar`.
4. **Não persistir avaliação oficial S-315** — resposta é rascunho auxiliar; incluir `disclaimer` obrigatório.
5. **Idioma** — responder em `pt-BR` quando `idioma = pt-BR`.
6. **Não exigir `discurso_id`** — v1 não compara com esboço do discurso.
7. **Performance** — meta de resposta ≤ 90 s (timeout do app).

---

## Erros

| HTTP | Quando | Body sugerido |
|------|--------|---------------|
| `400` | Transcrição ausente ou curta | `{ "message": "Transcrição insuficiente." }` |
| `404` | Rota não publicada | App exibe: *Recurso ainda não disponível no servidor* |
| `422` | Validação Laravel | `{ "message": "...", "errors": { ... } }` |
| `503` | IA indisponível | `{ "message": "Serviço temporariamente indisponível." }` |

O app **não remove** análise local em caso de erro.

---

## Fora de escopo (v1)

| Rota | Uso futuro |
|------|------------|
| `POST /v1/ensaio/transcrever` | Upload de áudio para transcrição server-side |
| `POST /v1/avaliar/esboco` | Comparar fala com esboço do discurso |
| `POST /v1/ensaio/registrar` | Sync de sessões no servidor |
| `GET /v1/ensaio/metas-tempo` | Metas intro/corpo/conclusão do backend |

---

## Changelog

| Data | Alteração |
|------|-----------|
| 25/05/2026 | Contrato inicial v1 — análise pós-ensaio manual, sem áudio |

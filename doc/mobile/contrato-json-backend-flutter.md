# Contrato JSON — Backend Laravel × Flutter (*Poder de Convencer*)

**Versão:** 1.1 (alinhado ao briefing mobile 21/05/2026)  
**Base URL:** `https://codeline43.com.br/api/v1` (dev: `http://localhost:8001/api/v1`)

---

## Convenções gerais

### Headers

```http
Accept: application/json
Content-Type: application/json
Authorization: Bearer {token}
```

Timeout recomendado em rotas de IA: **60s**.

### Envelope de resposta

O backend pode retornar qualquer um destes formatos; o **Flutter normaliza**:

| Formato | Exemplo |
|---------|---------|
| Laravel `data` | `{ "data": { ... } }` |
| Legado `success` | `{ "success": true, "content": "..." }` |
| Objeto direto | Manuscrito JSON em `gerar-manuscrito/total` |

**Recomendação backend (novas rotas):** usar sempre `{ "data": ... }` em sucesso.

### Erros

| HTTP | Body |
|------|------|
| `422` | `{ "message": "...", "errors": { "campo": ["..."] } }` |
| `500` | `{ "success": false, "error": "mensagem amigável" }` ou `{ "message": "..." }` |
| `401` / `403` | Auth / papel insuficiente (S-315) |

### Modos de saída IA

Parâmetro ou campo `modo` / `tipo_resposta`:

| Valor | Uso |
|-------|-----|
| `esboco_topicos` | Tópicos de ideias (be-T) |
| `manuscrito` | Prosa para leitura |
| `guia_estudo` | Guia prático (`guide`) |
| `avaliacao` | Feedback pedagógico (não reescreve texto) |

---

## Mapeamento de modelos Flutter

| Classe / asset Flutter | Request / response API |
|------------------------|-------------------------|
| `Speech` | `discursos` CRUD |
| `Speech.outline` | `esboco` em `avaliar/esboco` ou campos `esboco_original` |
| `MainPoint` | `pontos_principais[].titulo`, `ideias[]` |
| `BiblicalText` | `textos_biblicos[]` com `ler`, `explicar`, `ilustrar`, `aplicar` |
| Ciclo de Performance | `passo_atual` em `discursos.metadados` ou `estudo/progresso` |
| `caracteristicas_oratoria.json` | `caracteristicas_be_t[]`, `caracteristica_foco_id`, `aprimorar/feedback` |
| Assentinel study | `assentinel/estudos` |
| Comentário reunião | `comentarios/semanal` |

---

## Status das rotas (matriz)

Legenda: ✅ implementado no repo · 🟡 parcial · ❌ planejado · 🔒 auth obrigatória

### Já disponíveis

| Rota | Status | Notas |
|------|--------|-------|
| `GET/POST/GET{id}/DELETE /discursos` | ✅ | |
| `POST /discursos/gerar-manuscrito/total` | ✅ | Não persiste; JSON estruturado |
| `POST /discursos/sugerir-versiculos` | ✅ | LEIA |
| `GET /comentarios/semanal` | ✅ | Produção |
| `GET /comentarios/historico` | ✅ | Produção |
| `GET/POST/GET{id}/DELETE /assentinel/estudos` | ✅ | Deploy necessário |
| `POST /assentinel/estudos/{id}/comentario-inicial` | ✅ | |
| `POST /assentinel/estudos/{id}/comentario-final` | ✅ | |
| `POST /assentinel/estudos/{id}/resumo` | ✅ | |
| `GET/PUT /assentinel/settings` | ✅ | |

### Fase A — P0

| Rota | Status |
|------|--------|
| CRUD `/partes` + `generate-esboco` + `esboco/improve` + settings | ❌ |
| `PUT /discursos/{id}` | ❌ |
| `POST /discursos/{id}/generate-guia` | ❌ |
| `POST /discursos/{id}/gerar-manuscrito` | ❌ |
| `POST /discursos/{id}/manuscrito/improve` | ❌ |
| `GET/PUT /discursos/settings` | ❌ |
| CRUD `/respostas-geradas` + improve | ❌ |
| `POST /comentarios/gerar` | ❌ (hoje: `/api/wol/comentarios`) |

### Fase B — P0

| Rota | Status |
|------|--------|
| `POST /avaliar/esboco` | ❌ |
| `POST /avaliar/esboco/ocr` | ❌ P2 |

### Fases C–E

| Rota | Status |
|------|--------|
| `POST /estudo/pesquisa`, `meditacao`, `memorizar` | ❌ P1 |
| `GET /estudo/progresso/{id}` | ❌ P1 |
| `POST /ensaio/registrar` | ❌ P1 |
| `GET /ensaio/metas-tempo` | ❌ P1 |
| `POST /ensaio/analisar` | ❌ P1 — ver [contrato-ensaio-analise-online.md](./contrato-ensaio-analise-online.md) |
| `POST /aprimorar/feedback` | ❌ P1 |
| `POST/GET /avaliacoes-orador` | ❌ P2 🔒 |

---

## POST `/avaliar/esboco`

**Prioridade:** P0 · **Auth:** recomendado 🔒

### Request

```json
{
  "tipo": "parte_10min | discurso_publico | discurso_estudante",
  "titulo": "string opcional",
  "objetivo_central": "string",
  "esboco": {
    "introducao": "texto ou tópicos",
    "pontos_principais": [
      {
        "titulo": "Ponto 1",
        "ideias": ["..."],
        "textos_biblicos": [
          {
            "referencia": "João 3:16",
            "ler": "...",
            "explicar": "...",
            "ilustrar": "...",
            "aplicar": "..."
          }
        ],
        "ilustracoes": ["..."]
      }
    ],
    "conclusao": "texto ou tópicos"
  },
  "esboco_texto_livre": "alternativa: esboço corrido ou pós-OCR",
  "duracao_minutos": 10,
  "caracteristica_foco_id": 12,
  "idioma": "pt-BR"
}
```

**Validação:** `esboco` **ou** `esboco_texto_livre` obrigatório; `tipo` obrigatório.

### Response `200`

```json
{
  "data": {
    "nota_geral": "A|B|C|NR",
    "passo_shinyashiki": "preparar",
    "objetivo_claro": true,
    "proporcao_tempo": {
      "introducao_pct": 12,
      "corpo_pct": 78,
      "conclusao_pct": 10,
      "dentro_do_ideal_10min": true,
      "comentario": "Introdução um pouco longa para parte de 10 min."
    },
    "estrutura_bet": {
      "introducao": { "status": "ok|atencao|falta", "itens": [] },
      "corpo": { "status": "ok", "transicoes": "ok|atencao", "pontos": [] },
      "conclusao": { "status": "ok", "chama_acao": true }
    },
    "leia": [
      {
        "referencia": "João 3:16",
        "completo": false,
        "faltando": ["ilustrar"],
        "sugestao": "..."
      }
    ],
    "pilares_shinyashiki": [
      { "id": "credibilidade", "nota": "B+", "observacao": "..." },
      { "id": "empatia", "nota": "B", "observacao": "..." },
      { "id": "entusiasmo", "nota": "A-", "observacao": "..." }
    ],
    "caracteristicas_be_t": [
      {
        "id": 7,
        "titulo": "Ênfase nas ideias principais",
        "nota": "B",
        "evidencia": "...",
        "sugestao": "..."
      }
    ],
    "pontos_fortes": ["..."],
    "pontos_melhorar": ["..."],
    "proximos_passos": [
      "Reescrever introdução em 2 frases",
      "Completar LEIA no segundo texto"
    ],
    "persistido_id": "uuid-opcional"
  }
}
```

### Integração Flutter

1. Montar body a partir de `Speech.outline` (`toJson()`).
2. Exibir `proximos_passos` na tela **Preparar** do Ciclo.
3. Se `caracteristica_foco_id` veio da tela de foco be-T, enviar no request.
4. Opcional: salvar `persistido_id` no histórico local.

---

## Partes — CRUD e geração

### POST `/partes`

```json
{
  "tema": "obrigatório",
  "topicos": [
    { "descricao": "obrigatório", "texto": "Jo 3:16", "fonte": "opcional" }
  ],
  "conteudo_original": "opcional",
  "duracao_minutos": 10
}
```

### POST `/partes/{id}/generate-esboco`

```json
{
  "modo": "esboco_topicos | manuscrito"
}
```

**Response:** `{ "data": { "content": "...", "modo": "esboco_topicos" } }` — persistir em `esboco_manuscrito`.

### POST `/partes/{id}/esboco/improve`

```json
{
  "secao": "introducao | ponto_1 | conclusao | texto_completo",
  "instrucoes": "obrigatório"
}
```

---

## Discursos — metadados Ciclo

### PUT `/discursos/{id}` — campo sugerido

```json
{
  "metadados": {
    "passo_atual": "planejar | preparar | treinar | executar | aprimorar",
    "esboco_validado": false,
    "ultima_avaliacao_id": "uuid-opcional"
  }
}
```

Backend: coluna JSON `metadados` em `discursos` (migration) ou reutilizar campo existente se houver.

---

## Ensaio

### POST `/ensaio/registrar`

```json
{
  "discurso_id": "1",
  "parte_id": null,
  "tipo": "parte | discurso",
  "duracao_segundos": 612,
  "meta_minutos": 10,
  "nivel_energia": 4,
  "checklist_palco": {
    "microfone": true,
    "agua": true
  },
  "notas": "texto livre",
  "audio_url": "opcional"
}
```

### GET `/ensaio/metas-tempo?tipo=parte_10min`

```json
{
  "data": {
    "intro": 1,
    "corpo": 7,
    "conclusao": 2,
    "unidade": "minutos"
  }
}
```

### POST `/ensaio/analisar`

Análise online pós-ensaio (transcrição + métricas locais). Contrato completo: [contrato-ensaio-analise-online.md](./contrato-ensaio-analise-online.md).

---

## POST `/aprimorar/feedback`

```json
{
  "discurso_id": "1",
  "parte_id": null,
  "objetivo_alcancado": true,
  "engajamento_audiencia": 4,
  "competencias": [
    { "id": "clareza", "nota": 4 },
    { "id": "aplicacao", "nota": 5 }
  ],
  "caracteristicas_ids": [7, 14, 22],
  "pontos_fortes": "...",
  "pontos_melhorar": "...",
  "licoes_aprendidas": "..."
}
```

**Response:** `{ "data": { "id": 1, "created_at": "..." } }`

---

## Avaliação orador (S-315)

🔒 Requer papel `anciao` ou `avaliador`.

### POST `/avaliacoes-orador`

```json
{
  "avaliado": {
    "nome": "Irmão X",
    "congregacao": "...",
    "idioma_avaliacao": "pt-BR",
    "contato": { "email": "...", "telefone": "..." },
    "etnia": "opcional",
    "jw_hub": true
  },
  "triagem_bloqueio": {
    "ideias_sempre_melhores": false,
    "reputacao_rigido": false,
    "impoe_suas_ideias": false,
    "procrastinador": false,
    "aparencia_desconfortavel": false,
    "ofensa_assistencia": false,
    "bloqueado": false
  },
  "notas": {
    "DIS": "A+",
    "ENT": "B",
    "INT": "NR"
  },
  "observacoes": {
    "habilidade_orador": "...",
    "personalidade": "...",
    "familia": "...",
    "recomenda_parte_familia": true
  },
  "recomendado_ano_anterior": true,
  "nao_recomendado_motivo": "",
  "avaliadores_count": 3,
  "avaliado_ausente_durante_votacao": true
}
```

### POST `/avaliacoes-orador/gerar-rascunho-observacoes`

```json
{
  "notas": { "DIS": "A+", "ENT": "B", "INT": "NR" },
  "bullets_avaliador": ["clareza bíblica", "tom bondoso"]
}
```

**Response:** rascunhos para itens (9)–(11); avaliador **revisa** antes de salvar.

---

## Respostas geradas (Central da Reunião)

### POST `/respostas-geradas`

```json
{
  "pergunta": "opcional",
  "texto_base": "obrigatório",
  "fonte_pesquisa": "w23.01 pág. 5 par. 3",
  "prompt_especifico": "opcional"
}
```

### POST `/respostas-geradas/{id}/improve`

```json
{
  "instrucao_melhoria": "obrigatório"
}
```

---

## Assentinel — nomes de rotas

| Briefing mobile (alias) | Rota canônica no repo |
|-------------------------|----------------------|
| `generate-initial` | `comentario-inicial` ✅ usar esta |
| `generate-final` | `comentario-final` |
| `generate-summary` | `resumo` |

---

## Changelog de contrato

| Data | Alteração |
|------|-----------|
| 21/05/2026 | Documento inicial alinhado ao briefing Flutter; rotas `/avaliar/esboco`, `/aprimorar/feedback` como canônicas |
| 25/05/2026 | Adicionada rota `POST /ensaio/analisar` (análise online ensaio be-T) |

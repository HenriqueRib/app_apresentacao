# Contrato JSON — App Flutter × API v1

Documento para o time de **backend** alinhar respostas com o que o app mobile já consome em `https://codeline43.com.br/api`.

**Fonte de verdade para URLs em produção:** [ROTAS-PRODUCAO.md](./ROTAS-PRODUCAO.md) — o app **não** usa mais fallback `/api/wol/assentinela/*`.

O app aceita **envelope Laravel** (`{ "data": ... }`) ou **objeto/lista na raiz**, mas os campos abaixo devem existir com os nomes indicados.

---

## Estado atual do `routes/api.php` (produção)

Base: `https://codeline43.com.br/api`

| Status | Método | Caminho | Uso no app |
|--------|--------|---------|------------|
| ✅ Existe | `GET` | `/v1/discursos` | Lista discursos (funciona — log “9 discursos”) |
| ✅ Existe | `GET` | `/v1/comentarios/semanal` | Aba Comentários |
| ✅ Existe | `POST` | `/wol/comentarios` | **Gerar comentários** (não usar `/v1/comentarios/gerar` até existir) |
| ✅ Existe | `GET` | `/wol/reuniao` | Scraping WOL (opcional) |
| ❌ 404 | `GET/POST` | `/v1/respostas-geradas` | Respostas — só no painel web hoje |
| ❌ 404 | `GET` | `/v1/assentinel/estudos` | Sentinela — **cadastrar no Laravel** |
| ❌ 404 | `GET` | `/v1/assentinel/settings` | Prompts Sentinela |
| ❌ 404 | `GET` | `/v1/partes` | Partes |
| ❌ 404 | `GET` | `/v1/discursos/settings` | Prompts discursos |

O prefixo **`/v1` existe**, mas só para **discursos** e **comentarios/semanal**. Os 404 não são “falta de v1” e sim **rotas que ainda não foram adicionadas** ao grupo `Route::prefix('v1')`.

HTTP **404** no app significa “recurso ainda não publicado no backend”, não URL errada do cliente. Ver [ROTAS-PRODUCAO.md](./ROTAS-PRODUCAO.md).

Snippet sugerido para o backend (dentro do `prefix('v1')` existente):

```php
Route::prefix('respostas-geradas')->group(function () {
    Route::get('/', [RespostaGeradaController::class, 'index']);
    Route::post('/', [RespostaGeradaController::class, 'store']);
    Route::post('/{id}/improve', [RespostaGeradaController::class, 'improve']);
});

Route::prefix('assentinel')->group(function () {
    Route::get('estudos', [AssentinelController::class, 'index']);
    Route::post('estudos', [AssentinelController::class, 'store']);
    Route::get('settings', [AssentinelController::class, 'getSettings']);
    Route::put('settings', [AssentinelController::class, 'saveSettings']);
    // ...
});

Route::prefix('partes')->group(function () { /* ... */ });
Route::get('discursos/settings', [DiscursoController::class, 'settings']);
Route::put('discursos/settings', [DiscursoController::class, 'saveSettings']);
```

---

## Regras gerais

| Regra | Detalhe |
|-------|---------|
| Content-Type | `application/json` |
| Listagens | Preferir `{ "data": [ {...}, ... ] }` |
| Listas vazias | Retornar `[]` em `data`, não omitir a chave |
| Settings | Objeto plano com chaves string → valor string (não array de `{key,value}` sem documentar) |
| IDs | Enviar como string ou número; o app normaliza para string nos modelos de ferramentas |
| Erros | HTTP 4xx/5xx com corpo JSON e mensagem legível |

---

## 1. Central da Reunião — Comentários

### GET `/api/v1/comentarios/semanal`

**Resposta esperada (200):**

```json
{
  "data": {
    "semana": "2026-W21",
    "reuniao": {
      "texto_joia_espiritual": "Provérbios 21",
      "livro": "Provérbios",
      "capitulo": 21,
      "capitulo_texto": "Texto completo do capítulo..."
    },
    "comentarios": [
      {
        "id": 101,
        "comentario": "Texto do comentário (~30s)...",
        "tags": [{ "name": "Conselho" }]
      }
    ]
  }
}
```

Alternativa aceita: mesmo objeto **sem** envelope `data`.

| Campo | Obrigatório | Uso no app |
|-------|-------------|------------|
| `reuniao.texto_joia_espiritual` | Recomendado | Título na aba Comentários |
| `reuniao.capitulo_texto` | Para gerar IA | Se vazio, app mostra “Cadastrar texto do capítulo” |
| `comentarios[].comentario` | Sim | Texto exibido no card |
| `comentarios[].id` | Recomendado | Melhorar comentário (futuro) |
| `comentarios[].tags[].name` | Opcional | Chips na lista |

### POST `/api/v1/reuniao/texto`

**Body:**

```json
{
  "livro": "Provérbios",
  "capitulo": 21,
  "texto": "Texto completo do capítulo"
}
```

**Resposta:** `200` ou `201` (corpo opcional).

### POST `/api/v1/comentarios/gerar`

**Body:** vazio `{}` ou sem body.

**Resposta esperada:**

```json
{
  "success": true,
  "generated_count": 3
}
```

Após gerar, o app chama novamente `GET .../semanal` para atualizar a lista.

> Se a rota ainda não existir em v1, expor equivalente autenticado ao `POST /api/wol/comentarios` do painel web.

---

## 2. A Sentinela (Assentinel)

### GET `/api/v1/assentinel/estudos`

```json
{
  "data": [
    {
      "id": "42",
      "conteudo_estudo": "Texto colado...",
      "comentario_inicial": null,
      "comentario_final": null,
      "resumo_comentarios": null,
      "created_at": "2026-05-01T10:00:00Z",
      "updated_at": "2026-05-02T12:00:00Z"
    }
  ]
}
```

Aceito também: lista na raiz `[...]` ou `{ "estudos": [...] }`.

| Campo | Obrigatório |
|-------|-------------|
| `id` | Sim |
| `conteudo_estudo` | Sim |
| `comentario_inicial`, `comentario_final`, `resumo_comentarios` | Opcional (null se vazio) |
| `created_at`, `updated_at` | Recomendado (ISO 8601) |

### GET `/api/v1/assentinel/settings`

**Resposta esperada (objeto plano, não aninhado em outro objeto sem ser `data`):**

```json
{
  "data": {
    "prompt_inicial": "Instrução para comentário inicial...",
    "prompt_final": "Instrução para comentário final...",
    "prompt_resumo": "Instrução para resumo-ponte..."
  }
}
```

Ou na raiz:

```json
{
  "prompt_inicial": "...",
  "prompt_final": "...",
  "prompt_resumo": "..."
}
```

### PUT `/api/v1/assentinel/settings`

Mesmo body do GET (três chaves acima).

### POST `/api/v1/assentinel/estudos/{id}/comentario-inicial` (e `comentario-final`, `resumo`)

**Resposta:** texto gerado em um destes campos (o app lê todos):

- `content`
- `comment`
- `data` (string ou objeto com `content`)

---

## 3. Discursos (admin no app)

### GET `/api/v1/discursos`

```json
{
  "data": [
    {
      "id": 1,
      "tema": "Tema",
      "objetivo": "Objetivo",
      "created_at": "2026-05-01T10:00:00Z"
    }
  ]
}
```

### GET `/api/v1/discursos/settings`

```json
{
  "prompt_discurso_geral": "Prompt manuscrito...",
  "prompt_discurso_guia": "Prompt guia..."
}
```

Aliases aceitos pelo app: `prompt_geral` → manuscrito, `prompt_guia` → guia.

### PUT `/api/v1/discursos/settings`

```json
{
  "prompt_geral": "...",
  "prompt_guia": "..."
}
```

---

## 4. Partes da reunião

### GET `/api/v1/partes`

```json
{
  "data": [
    {
      "id": "7",
      "tema": "Tema da parte",
      "topicos": [{ "descricao": "...", "texto": "Jo 1:1", "fonte": "..." }],
      "esboco_manuscrito": null,
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

### GET `/api/v1/partes/settings`

```json
{
  "prompt_geral": "Instrução global para esboço..."
}
```

Alias aceito: `prompt_parte_geral`.

### PUT `/api/v1/partes/settings`

```json
{
  "prompt_geral": "..."
}
```

---

## 5. Respostas geradas (Central — aba Respostas)

### GET `/api/v1/respostas-geradas`

```json
{
  "data": [
    {
      "id": "uuid-ou-int",
      "pergunta": "opcional",
      "texto_base": "...",
      "fonte_pesquisa": "w23.01 pág. 5",
      "prompt_especifico": "Resposta simples e objetiva",
      "resposta_gerada": "Texto completo...",
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

---

## Checklist para o backend

- [ ] `GET comentarios/semanal` inclui `reuniao.capitulo_texto` quando o texto já foi salvo
- [ ] `POST reuniao/texto` e `POST comentarios/gerar` expostos em v1 (autenticados como o web)
- [ ] `GET assentinel/estudos` retorna **todos** os estudos em `data` (array, mesmo vazio)
- [ ] `GET assentinel/settings` retorna as 3 chaves `prompt_*` com valores já cadastrados no painel
- [ ] `GET discursos/settings` e `GET partes/settings` retornam prompts não vazios quando existem no banco
- [ ] Respostas de geração (comentários, sentinela, partes, discursos) usam `content` ou campo documentado acima

---

## Referências no repositório

- Requisitos completos: [backend-requisitos-api.md](./backend-requisitos-api.md)
- UI Comentários: [central-da-reuniao.md](./central-da-reuniao.md)
- UI Sentinela: [assentinel.md](./assentinel.md)
- Código de parse: `lib/core/utils/api_json_helpers.dart`

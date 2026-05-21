# Requisitos de API para o app Flutter

> **Atualizado 21/05/2026:** prioridades e rotas novas (avaliar esboco, aprimorar, S-315) estão no briefing mobile.  
> **Use como fonte de verdade:** [briefing-backend-ensino.md](./briefing-backend-ensino.md) · [contrato-json-backend-flutter.md](./contrato-json-backend-flutter.md) · [plano-api-ensino.md](./plano-api-ensino.md)

Documento para o **time de backend**: o que existe hoje no painel `/wol` e o que precisa ser exposto em JSON (prefixo `/api/v1`).

---

## Prioridade sugerida

| P | Módulo | Motivo |
|---|--------|--------|
| P0 | Respostas geradas (Central da Reunião) | Funcionalidade pedida para o app |
| P0 | Assentinel | Página dedicada no app |
| P1 | Partes (CRUD + gerar esboço) | Partes 10 min |
| P1 | Discursos (completar v1) | Guia, gerar por id, improve |
| P2 | Comentários reunião (gerar/melhorar) | Segunda aba da Central |

---

## Padrão de resposta recomendado

### Sucesso (geração IA)

```json
{
  "success": true,
  "content": "texto gerado ou atualizado"
}
```

Assentinel usa `comment` em vez de `content` no web — **padronizar para `content`** no mobile.

### Erro

```json
{
  "success": false,
  "error": "Mensagem amigável",
  "message": "Detalhe técnico opcional"
}
```

### Validação Laravel

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "campo": ["mensagem"]
  }
}
```

HTTP: `422`

---

## 1. Respostas geradas (`respostas_geradas`)

**Model:** `RespostaGerada`  
**Web hoje:** `POST /wol/respostas-geradas`, `POST /wol/respostas-geradas/{id}/improve` (redirect HTML)

### Rotas propostas

| Método | URL | Ação |
|--------|-----|------|
| `GET` | `/api/v1/respostas-geradas` | Listar (ordenar `created_at desc`) |
| `POST` | `/api/v1/respostas-geradas` | Gerar nova resposta |
| `POST` | `/api/v1/respostas-geradas/{id}/improve` | Melhorar com instrução |
| `DELETE` | `/api/v1/respostas-geradas/{id}` | Excluir (opcional; web não tem) |

### POST gerar — body

```json
{
  "pergunta": "opcional",
  "texto_base": "obrigatório",
  "fonte_pesquisa": "obrigatório, ex: w23.01 pág. 5 par. 3",
  "prompt_especifico": "opcional, default pode ser 'Resposta simples e objetiva'"
}
```

**Resposta 201:**

```json
{
  "success": true,
  "resposta": {
    "id": 1,
    "pergunta": "...",
    "texto_base": "...",
    "fonte_pesquisa": "...",
    "prompt_especifico": "...",
    "resposta_gerada": "...",
    "created_at": "..."
  }
}
```

Reutilizar lógica de `RespostaGeradaController@store`.

### POST improve — body

```json
{
  "instrucao_melhoria": "obrigatório"
}
```

**Resposta 200:** objeto `resposta` atualizado (mesmo shape do create).

Reutilizar `RespostaGeradaController@improve` retornando JSON em vez de `redirect`.

---

## 2. Assentinel (`assentinel_studies`)

**Web hoje:** CRUD + 3 generates + settings (JSON)

### Rotas propostas

| Método | URL | Ação |
|--------|-----|------|
| `GET` | `/api/v1/assentinel/estudos` | Listar estudos |
| `POST` | `/api/v1/assentinel/estudos` | Adicionar estudo |
| `GET` | `/api/v1/assentinel/estudos/{id}` | Detalhe |
| `DELETE` | `/api/v1/assentinel/estudos/{id}` | Excluir |
| `POST` | `/api/v1/assentinel/estudos/{id}/comentario-inicial` | Gerar/melhorar inicial |
| `POST` | `/api/v1/assentinel/estudos/{id}/comentario-final` | Gerar/melhorar final |
| `POST` | `/api/v1/assentinel/estudos/{id}/resumo` | Gerar/melhorar resumo-ponte |
| `GET` | `/api/v1/assentinel/settings` | Ler prompts globais |
| `PUT` | `/api/v1/assentinel/settings` | Salvar prompts |

### POST estudo — body

```json
{
  "conteudo_estudo": "texto completo colado pelo usuário"
}
```

### POST generate comentário — body

```json
{
  "id": 1
}
```

Ou usar apenas `{id}` na URL (preferível REST).

**Resumo:** exige `comentario_inicial` e `comentario_final` preenchidos; senão `422` com mensagem: *"É necessário gerar os comentários inicial e final antes de criar o resumo."*

### Settings — body PUT

```json
{
  "prompt_inicial": "...",
  "prompt_final": "...",
  "prompt_resumo": "..."
}
```

Chaves em `settings`: `prompt_inicial`, `prompt_final`, `prompt_resumo`.

---

## 3. Discursos (estender v1 existente)

**Já existe:** `GET/POST/GET{id}/DELETE`, `gerar-manuscrito/total`, `sugerir-versiculos`

### Rotas a adicionar

| Método | URL | Espelha web |
|--------|-----|-------------|
| `PUT` | `/api/v1/discursos/{id}` | `discursos.update` |
| `POST` | `/api/v1/discursos/{id}/gerar-manuscrito` | `generate-manuscrito` (usa `esboco_original` + prompts) |
| `POST` | `/api/v1/discursos/{id}/gerar-guia` | `generate-guia` |
| `POST` | `/api/v1/discursos/{id}/manuscrito/improve` | `improveManuscrito` — body: `instructions`, `manuscript` |
| `GET` | `/api/v1/discursos/settings` | prompts |
| `PUT` | `/api/v1/discursos/settings` | body: `prompt_geral`, `prompt_guia` |

### PUT discurso — campos

` tema`, `data`, `numero`, `cantico`, `objetivo`, `esboco_original`, `manuscrito_completo`, `fonte_materias`, `guide`

### POST gerar-manuscrito / gerar-guia — body

```json
{
  "id": 1
}
```

**Resposta:** `{ "success": true, "content": "..." }` e persistir no campo correspondente.

**Nota:** `gerar-manuscrito/total` (já existente) é fluxo **diferente**: não persiste, retorna JSON estruturado a partir de `conteudo_bruto`.

---

## 4. Partes (`partes`)

**Web hoje:** CRUD completo + `generate-esboco` + `esboco/improve`

### Rotas propostas

| Método | URL | Ação |
|--------|-----|------|
| `GET` | `/api/v1/partes` | Listar |
| `POST` | `/api/v1/partes` | Criar |
| `GET` | `/api/v1/partes/{id}` | Detalhe |
| `PUT` | `/api/v1/partes/{id}` | Editar |
| `DELETE` | `/api/v1/partes/{id}` | Excluir |
| `POST` | `/api/v1/partes/{id}/gerar-esboco` | IA → `esboco_manuscrito` |
| `POST` | `/api/v1/partes/{id}/esboco/improve` | body: `instructions`, `esboco` |
| `GET/PUT` | `/api/v1/partes/settings` | `prompt_geral` |

### POST criar — body

```json
{
  "tema": "obrigatório",
  "topicos": [
    {
      "descricao": "obrigatório",
      "texto": "opcional, ex: Jo 1:1",
      "fonte": "opcional"
    }
  ],
  "conteudo_original": "opcional"
}
```

`topicos` é array JSON no banco (`casts` array).

---

## 5. Central da Reunião — comentários (opcional P2)

| Método | URL | Web |
|--------|-----|-----|
| `GET` | `/api/v1/comentarios/semanal` | já existe |
| `POST` | `/api/v1/reuniao/texto` | `POST /wol/comentarios/texto` |
| `POST` | `/api/v1/comentarios/gerar` | `POST /api/wol/comentarios` |
| `POST` | `/api/v1/comentarios/{id}/improve` | `POST /wol/comentarios/{id}/improve` |

### POST reuniao/texto

```json
{
  "livro": "Provérbios",
  "capitulo": 21,
  "texto": "texto completo do capítulo"
}
```

### POST gerar comentários

Sem body; usa semana corrente + texto salvo. Resposta:

```json
{
  "success": true,
  "generated_count": 3
}
```

---

## Autenticação

Hoje `/wol` exige sessão admin. Para o app:

- Definir middleware (`auth:sanctum`, JWT existente do app, ou `auth:api`).
- Documentar header: `Authorization: Bearer {token}`.
- Rate limit em rotas de IA (`throttle`).

---

## Implementação mínima (checklist backend)

- [ ] `Api\RespostaGeradaController` + rotas v1
- [ ] `Api\AssentinelController` + rotas v1
- [ ] `Api\ParteController` + rotas v1
- [ ] Estender `Api\DiscursoController` (PUT, gerar por id, settings, improve)
- [ ] Converter redirects de `improve` para JSON quando `Accept: application/json`
- [ ] Atualizar `docs/api_documentacao_v1.md`
- [ ] Testes Feature PHPUnit por endpoint

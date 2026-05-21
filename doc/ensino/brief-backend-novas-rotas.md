# Brief técnico — Novas rotas API v1 (Ensino / Oratória)

**Para:** time backend Laravel  
**Fonte de verdade (produto mobile):** [../mobile/briefing-backend-ensino.md](../mobile/briefing-backend-ensino.md)  
**Contrato JSON:** [../mobile/contrato-json-backend-flutter.md](../mobile/contrato-json-backend-flutter.md)  
**Plano Flutter:** [../mobile/plano-api-ensino.md](../mobile/plano-api-ensino.md)

> **Nota:** Rotas de avaliação usam o prefixo **`/avaliar/esboco`** (acordado com Flutter), não `/oratoria/avaliar-conteudo`.

---

## Resumo executivo

| Fase | Prioridade | Escopo |
|------|------------|--------|
| **A** | P0 | Espelhar `/wol` → `/api/v1` (partes, discursos, respostas, comentários/gerar) |
| **B** | P0 | `POST /avaliar/esboco` (Shinyashiki + be-T + LEIA) |
| **C** | P1 | Estudo guiado (pesquisa, meditação, memorizar, progresso) |
| **D** | P1 | `ensaio/registrar`, `aprimorar/feedback`, `metas-tempo` |
| **E** | P2 | `avaliacoes-orador` (S-315) + OCR |

---

## Fase A — Implementação

Reutilizar `Wol\*` controllers; wrappers `Api\*` retornando `{ "data": ... }`.

Detalhes de URLs e bodies: [briefing-backend-ensino.md §3](../mobile/briefing-backend-ensino.md).

**Assentinel:** já em `Api\AssentinelController` — rotas `comentario-inicial`, `comentario-final`, `resumo` (não renomear para `generate-*` sem alias).

---

## Fase B — `POST /api/v1/avaliar/esboco`

### Controller

`App\Http\Controllers\Api\AvaliarEsbocoController@store`

### Request / Response

Schema completo: [contrato-json-backend-flutter.md](../mobile/contrato-json-backend-flutter.md#post-apiv1avaliaresboco).

### Prompt

- Settings key: `prompt_avaliar_esboco`
- Regras: ver briefing mobile §4
- Saída: **JSON estruturado** (`modo: avaliacao`), sem reescrever esboço
- Se `caracteristica_foco_id`: 40% peso no feedback

### Persistência (P1 opcional)

Tabela `avaliacoes_esboco`: `user_id`, `discurso_id`, `payload_request`, `payload_response`, `created_at`.

### Testes

- Payload espelhando `Speech.outline` do Flutter
- `parte_10min` sem `ilustrar` → `leia[].faltando` contém `ilustrar`

---

## Fase C — Estudo

| Rota | Controller sugerido |
|------|---------------------|
| `POST /estudo/pesquisa` | `Api\EstudoController@pesquisa` |
| `POST /estudo/meditacao` | `Api\EstudoController@meditacao` |
| `POST /estudo/memorizar` | `Api\EstudoController@memorizar` |
| `GET /estudo/progresso/{id}` | `Api\EstudoController@progresso` |

Metadados em `discursos.metadados` (migration JSON):

```json
{
  "passo_atual": "preparar",
  "esboco_validado": true
}
```

---

## Fase D — Ensaio e aprimorar

- `POST /ensaio/registrar` → tabela `ensaios`
- `GET /ensaio/metas-tempo`
- `POST /aprimorar/feedback` → tabela `feedbacks_apresentacao`

Schemas: [contrato-json-backend-flutter.md](../mobile/contrato-json-backend-flutter.md).

---

## Fase E — S-315

- `POST/GET /avaliacoes-orador` 🔒 middleware papel `anciao|avaliador`
- `POST /avaliacoes-orador/gerar-rascunho-observacoes` — IA não inventa fatos
- Tabelas: `avaliacoes_orador` (+ itens se normalizar)

Schema: [contrato-json-backend-flutter.md § S-315](../mobile/contrato-json-backend-flutter.md#avaliação-orador-s-315).

---

## Settings (novas chaves)

Ver [briefing-backend-ensino.md §9](../mobile/briefing-backend-ensino.md).

---

## Checklist backend

- [ ] Fase A: partes, discursos (PUT, guia, manuscrito, improve), respostas, `comentarios/gerar`
- [ ] Fase B: `AvaliarEsbocoController` + `prompt_avaliar_esboco`
- [ ] Fase C: `EstudoController` + migration `metadados`
- [ ] Fase D: ensaio + aprimorar
- [ ] Fase E: avaliacoes-orador + auth papel
- [ ] `docs/api_documentacao_v1.md`
- [ ] `docs/ensino/mapeamento-rotas.md` § API v1
- [ ] Feature tests + [ROTAS-PRODUCAO.md](../mobile/ROTAS-PRODUCAO.md)

---

## Script terminal

```bash
./scripts/ensino/brief-backend.sh
```

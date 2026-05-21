# Rotas em produção — o que o app pode chamar hoje

**Base:** `https://codeline43.com.br/api`  
**Headers:** `Accept: application/json`, `Content-Type: application/json`

Última atualização: 21/05/2026 — alinhado ao `routes/api.php` do repositório backend.

---

## Status geral

| Módulo | Status | Notas |
|--------|--------|-------|
| Discursos (CRUD + geração) | ✅ Completo | Todas as rotas implementadas |
| Partes (CRUD + geração) | ✅ Completo | |
| Comentários (semanal + histórico + gerar) | ✅ Completo | |
| Assentinel (CRUD + settings) | 🟡 Parcial | **Faltam**: DELETE, comentario-inicial, comentario-final, resumo |
| Respostas geradas | ✅ Completo | |
| Avaliar esboço | ✅ Completo | + historico + show |
| Avaliações orador (S-315) | ✅ Completo | Requer middleware `checkPapelOrador` |
| Biblioteca be-T | ✅ Completo | |
| Plano de Desenvolvimento | ✅ Completo | + analytics, gerar, coaching |
| Comparador de esboços | ✅ Completo | |
| Exercícios de oratória | ✅ Completo | + aquecimento |
| Aprimorar/Feedback | ✅ Completo | |
| Ensaio | ✅ Completo | registrar + metas-tempo |
| Estudo guiado | ✅ Completo | pesquisa, meditação, memorizar, progresso |

---

## ⚠️ GAP: Assentinel — rotas de geração de comentários

O backend implementa CRUD de estudos e settings, mas **NÃO registra** no `routes/api.php`:

| Rota esperada pelo mobile | Status no backend |
|---------------------------|-------------------|
| `DELETE /v1/assentinel/estudos/{id}` | ❌ Não registrada |
| `POST /v1/assentinel/estudos/{id}/comentario-inicial` | ❌ Não registrada |
| `POST /v1/assentinel/estudos/{id}/comentario-final` | ❌ Não registrada |
| `POST /v1/assentinel/estudos/{id}/resumo` | ❌ Não registrada |

**Ação backend:** Adicionar ao grupo `v1/assentinel`:

```php
Route::delete('/estudos/{id}', [AssentinelController::class, 'destroy'])->where('id', '[0-9]+');
Route::post('/estudos/{id}/comentario-inicial', [AssentinelController::class, 'comentarioInicial'])->where('id', '[0-9]+')->middleware('throttle:10,1');
Route::post('/estudos/{id}/comentario-final', [AssentinelController::class, 'comentarioFinal'])->where('id', '[0-9]+')->middleware('throttle:10,1');
Route::post('/estudos/{id}/resumo', [AssentinelController::class, 'resumo'])->where('id', '[0-9]+')->middleware('throttle:10,1');
```

---

## ✅ Discursos — completo

| Método | URL | Status |
|--------|-----|--------|
| `GET` | `/api/v1/discursos` | ✅ |
| `POST` | `/api/v1/discursos` | ✅ |
| `GET` | `/api/v1/discursos/{id}` | ✅ |
| `PUT` | `/api/v1/discursos/{id}` | ✅ |
| `DELETE` | `/api/v1/discursos/{id}` | ✅ |
| `GET` | `/api/v1/discursos/settings` | ✅ |
| `PUT` | `/api/v1/discursos/settings` | ✅ |
| `POST` | `/api/v1/discursos/gerar-manuscrito/total` | ✅ |
| `POST` | `/api/v1/discursos/sugerir-versiculos` | ✅ |
| `POST` | `/api/v1/discursos/{id}/generate-guia` | ✅ throttle:10,1 |
| `POST` | `/api/v1/discursos/{id}/gerar-manuscrito` | ✅ throttle:10,1 |
| `POST` | `/api/v1/discursos/{id}/manuscrito/improve` | ✅ throttle:10,1 |

---

## ✅ Partes — completo

| Método | URL | Status |
|--------|-----|--------|
| `GET` | `/api/v1/partes` | ✅ |
| `POST` | `/api/v1/partes` | ✅ |
| `GET` | `/api/v1/partes/settings` | ✅ |
| `PUT` | `/api/v1/partes/settings` | ✅ |
| `GET` | `/api/v1/partes/{id}` | ✅ |
| `PUT` | `/api/v1/partes/{id}` | ✅ |
| `DELETE` | `/api/v1/partes/{id}` | ✅ |
| `POST` | `/api/v1/partes/{id}/generate-esboco` | ✅ throttle:10,1 |
| `POST` | `/api/v1/partes/{id}/esboco/improve` | ✅ throttle:10,1 |

---

## ✅ Comentários — completo

| Método | URL | Status |
|--------|-----|--------|
| `GET` | `/api/v1/comentarios/semanal` | ✅ |
| `GET` | `/api/v1/comentarios/historico` | ✅ |
| `POST` | `/api/v1/comentarios/gerar` | ✅ throttle:10,1 |

Legado (ainda funcional): `POST /api/wol/comentarios` — preferir v1.

---

## 🟡 Assentinel — parcial

| Método | URL | Status |
|--------|-----|--------|
| `GET` | `/api/v1/assentinel/estudos` | ✅ |
| `POST` | `/api/v1/assentinel/estudos` | ✅ |
| `GET` | `/api/v1/assentinel/estudos/{id}` | ✅ |
| `DELETE` | `/api/v1/assentinel/estudos/{id}` | ❌ Falta no routes |
| `POST` | `/api/v1/assentinel/estudos/{id}/comentario-inicial` | ❌ Falta no routes |
| `POST` | `/api/v1/assentinel/estudos/{id}/comentario-final` | ❌ Falta no routes |
| `POST` | `/api/v1/assentinel/estudos/{id}/resumo` | ❌ Falta no routes |
| `GET` | `/api/v1/assentinel/settings` | ✅ |
| `PUT` | `/api/v1/assentinel/settings` | ✅ |

---

## ✅ Respostas geradas

| Método | URL | Status |
|--------|-----|--------|
| `GET` | `/api/v1/respostas-geradas` | ✅ |
| `POST` | `/api/v1/respostas-geradas` | ✅ throttle:10,1 |
| `POST` | `/api/v1/respostas-geradas/{id}/improve` | ✅ throttle:10,1 |

---

## ✅ Avaliar esboço (P0)

| Método | URL | Status |
|--------|-----|--------|
| `POST` | `/api/v1/avaliar/esboco` | ✅ throttle:10,1 |
| `GET` | `/api/v1/avaliar/esboco/historico` | ✅ |
| `GET` | `/api/v1/avaliar/esboco/{id}` | ✅ |

---

## ✅ Avaliações orador S-315 (P2)

🔒 Middleware: `checkPapelOrador` (requer papel `anciao` / `avaliador`).

| Método | URL | Status |
|--------|-----|--------|
| `GET` | `/api/v1/avaliacoes-orador` | ✅ |
| `POST` | `/api/v1/avaliacoes-orador` | ✅ |
| `GET` | `/api/v1/avaliacoes-orador/{id}` | ✅ |
| `PUT` | `/api/v1/avaliacoes-orador/{id}` | ✅ |
| `DELETE` | `/api/v1/avaliacoes-orador/{id}` | ✅ |
| `POST` | `/api/v1/avaliacoes-orador/gerar-rascunho-observacoes` | ✅ throttle:10,1 |

---

## ✅ Biblioteca be-T (53 características)

| Método | URL | Status |
|--------|-----|--------|
| `GET` | `/api/v1/biblioteca-bet` | ✅ |
| `GET` | `/api/v1/biblioteca-bet/{id}` | ✅ |
| `GET` | `/api/v1/biblioteca-bet/categoria/{categoria}` | ✅ |
| `POST` | `/api/v1/biblioteca-bet/{id}/dicas` | ✅ throttle:10,1 |

---

## ✅ Plano de Desenvolvimento

| Método | URL | Status |
|--------|-----|--------|
| `GET` | `/api/v1/plano-desenvolvimento` | ✅ |
| `POST` | `/api/v1/plano-desenvolvimento` | ✅ |
| `GET` | `/api/v1/plano-desenvolvimento/analytics` | ✅ |
| `POST` | `/api/v1/plano-desenvolvimento/gerar` | ✅ throttle:10,1 |
| `POST` | `/api/v1/plano-desenvolvimento/coaching` | ✅ throttle:10,1 |
| `GET` | `/api/v1/plano-desenvolvimento/{id}` | ✅ |
| `PUT` | `/api/v1/plano-desenvolvimento/{id}` | ✅ |
| `DELETE` | `/api/v1/plano-desenvolvimento/{id}` | ✅ |

---

## ✅ Comparador de esboços

| Método | URL | Status |
|--------|-----|--------|
| `POST` | `/api/v1/comparar/esbocos` | ✅ throttle:10,1 |

---

## ✅ Exercícios de oratória

| Método | URL | Status |
|--------|-----|--------|
| `POST` | `/api/v1/exercicios/gerar` | ✅ throttle:10,1 |
| `POST` | `/api/v1/exercicios/aquecimento` | ✅ throttle:10,1 |

---

## ✅ Aprimorar/Feedback (P1)

| Método | URL | Status |
|--------|-----|--------|
| `POST` | `/api/v1/aprimorar/feedback` | ✅ |

---

## ✅ Ensaio (P1)

| Método | URL | Status |
|--------|-----|--------|
| `POST` | `/api/v1/ensaio/registrar` | ✅ |
| `GET` | `/api/v1/ensaio/metas-tempo` | ✅ |

---

## ✅ Estudo guiado (P1)

| Método | URL | Status |
|--------|-----|--------|
| `POST` | `/api/v1/estudo/pesquisa` | ✅ throttle:10,1 |
| `POST` | `/api/v1/estudo/meditacao` | ✅ throttle:10,1 |
| `POST` | `/api/v1/estudo/memorizar` | ✅ throttle:10,1 |
| `GET` | `/api/v1/estudo/progresso/{discurso_id}` | ✅ |

---

## Outras rotas fora do módulo ensino

| Módulo | Rota | Nota |
|--------|------|------|
| Ranking | `GET/POST /api/ranking` | Timeflow |
| Auth | `/api/auth/*` | Login, registro, etc. |
| Frases | `/api/frase` | BestOfWord |
| Doc API | `GET /api/wol/doc` | Documentação |

---

## Checklist para o time Flutter

1. ✅ Não usar fallbacks `/api/wol/assentinela` — sempre 404.
2. ✅ Central da Reunião usa `GET /api/v1/comentarios/semanal` + `POST .../gerar`.
3. ⚠️ Assentinel: comentario-inicial/final/resumo — **aguardar backend registrar rotas**.
4. ✅ Tratar `404` como "feature não publicada".
5. ✅ Usar `POST /v1/avaliar/esboco` (não `/oratoria/avaliar-conteudo`).
6. ✅ Novos módulos (biblioteca-bet, plano-desenvolvimento, exercicios) integrados.

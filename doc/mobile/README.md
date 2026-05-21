# Documentação Mobile — *Poder de Convencer* / Palestrante

Especificação para o time **Flutter** e **Backend**, espelhando as telas Blade em `resources/views/wol/` e o contrato acordado em **21/05/2026**.

---

## Documentos principais (comece aqui)

| Documento | Para quem | Conteúdo |
|-----------|-----------|----------|
| **[plano-api-ensino.md](./plano-api-ensino.md)** | **Flutter** | Tudo que será feito: fases, telas, sprints, checklist QA |
| **[contrato-json-backend-flutter.md](./contrato-json-backend-flutter.md)** | Flutter + Backend | Request/response JSON, mapeamento `Speech.outline`, matriz de status |
| **[briefing-backend-ensino.md](./briefing-backend-ensino.md)** | Backend | Pedido formal do produto mobile (copiar para Laravel) |
| [ROTAS-PRODUCAO.md](./ROTAS-PRODUCAO.md) | Flutter | O que responde hoje em `codeline43.com.br` |
| [backend-requisitos-api.md](./backend-requisitos-api.md) | Backend | Backlog legado (espelho WOL) — ver plano para prioridades atuais |

---

## Navegação por tela do app

| Tela no app | Equivalente web | Doc |
|-------------|-----------------|-----|
| **Home — Ciclo de Performance** | Fluxo Shinyashiki (local + API) | [plano-api-ensino.md §3.1](./plano-api-ensino.md) |
| **Central da Reunião** | `comentarios.blade.php` | [central-da-reuniao.md](./central-da-reuniao.md) |
| **A Sentinela** | `assentinela.blade.php` | [assentinel.md](./assentinel.md) |
| **Discursos** | `discursos.blade.php` | [discursos.md](./discursos.md) |
| **Partes** | `partes.blade.php` | [partes.md](./partes.md) |
| **Avaliação oradores (S-315)** | — (novo, P2) | [plano-api-ensino.md §3.6](./plano-api-ensino.md) |

---

## Convenções

- **Base URL API:** `{APP_URL}/api` (ex.: `https://codeline43.com.br/api`)
- **Base URL API v1:** `{APP_URL}/api/v1`
- **Admin web (hoje):** `{APP_URL}/wol/...` — sessão Laravel + `auth` + `checkAdmin`
- **Timeout IA:** 60s
- **Envelope:** backend deve preferir `{ "data": ... }`; Flutter normaliza legado `{ "success", "content" }`

---

## Prioridades atuais (resumo)

| P | Entrega |
|---|---------|
| **P0** | Espelhar WOL em v1 + **`POST /avaliar/esboco`** |
| **P1** | Partes, ensaio, `aprimorar/feedback`, estudo guiado |
| **P2** | S-315 oradores + OCR esboco |

Detalhe completo: [plano-api-ensino.md](./plano-api-ensino.md).

---

## Status da API hoje

| Módulo | API pronta para Flutter? |
|--------|-------------------------|
| Discursos (parcial) | CRUD parcial + manuscrito total + LEIA — falta PUT, guia, improve, **avaliar/esboco** |
| Comentários semana | `GET semanal/historico` — falta `comentarios/gerar` |
| Assentinel | **Repo:** rotas v1 prontas — **deploy** em produção |
| Respostas geradas | **Não** |
| Partes | **Não** |
| Ciclo (ensaio, feedback, progresso) | **Não** (app local hoje) |

---

## ⚠️ Produção e 404

**Leia:** [ROTAS-PRODUCAO.md](./ROTAS-PRODUCAO.md)

- **Não usar** fallbacks `/api/wol/assentinela/*`
- Assentinel: `/api/v1/assentinel/estudos/{id}/comentario-inicial` (não `generate-initial`)

---

## Referências ensino (metodologia)

- [docs/ensino/relatorio-metodologico.md](../ensino/relatorio-metodologico.md) — Shinyashiki, be-T, lacunas
- [docs/ensino/mapeamento-rotas.md](../ensino/mapeamento-rotas.md) — mapa técnico URLs
- [docs/api_documentacao_v1.md](../api_documentacao_v1.md) — contrato v1 publicado (atualizar após implementação)

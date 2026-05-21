# Módulo de Ensino / Oratória (WOL + API Flutter)

Documentação técnica do backend Laravel voltado a **estudo teocrático**, **partes de reunião**, **discursos** e **geração assistida por IA**.

## Índice

| Documento | Conteúdo |
|-----------|----------|
| [mapeamento-rotas.md](./mapeamento-rotas.md) | URLs, métodos HTTP, autenticação, payloads e o que cada rota gera |
| [relatorio-metodologico.md](./relatorio-metodologico.md) | Shinyashiki (5 passos), be-T, LEIA, 53 características, lacunas e roadmap |
| [briefing-backend-novas-rotas.md](./briefing-backend-novas-rotas.md) | **Script para o time backend** — novas rotas (avaliar esboço, partes, S-315, ensaio) |
| [roadmap-integracao-flutter.md](./roadmap-integracao-flutter.md) | **Script para o app Flutter** — sprints, telas, `EnsinoApiService` |
| [../api_documentacao_v1.md](../api_documentacao_v1.md) | Contrato JSON da API v1 para o app Flutter |

## Visão rápida: dois “mundos” de acesso

```mermaid
flowchart TB
    subgraph flutter [Flutter / API pública]
        API["/api/v1/discursos/*"]
        COM["/api/v1/comentarios/*"]
        IA["/api/ia/{pergunta}"]
    end
    subgraph admin [Admin Blade /auth + checkAdmin]
        WOL["/wol/*"]
    end
    API --> DiscursoCtrl[Api\DiscursoController]
    COM --> ComentarioCtrl[Api\ComentarioController]
    WOL --> WolDisc[Wol\DiscursoController]
    WOL --> WolParte[Wol\ParteController]
    WOL --> WolAss[AssentinelController]
    WOL --> IaCtrl[IaController]
```

- **Flutter** consome principalmente `routes/api.php` (`/api/v1/...`).
- **Painel WOL** usa `routes/web.php` com prefixo `/wol` (sessão Laravel + middleware `checkAdmin`).

## Entidades principais

| Modelo | Uso |
|--------|-----|
| `Discurso` | Discurso público: esboço, manuscrito, guia (`guide`), metadados |
| `Parte` | Parte de reunião (tópicos JSON, esboço manuscrito) |
| `AssentinelStudy` | Estudo Sentinela: comentário inicial/final + resumo |
| `Reuniao` + `Comentario` | Comentários da leitura semanal (Joia Espiritual) |
| `RespostaGerada` | Respostas a perguntas sobre fonte de pesquisa |
| `Setting` | Prompts globais editáveis (`prompt_discurso_geral`, etc.) |

## Serviço de IA

Toda geração passa por `App\Services\AiServiceInterface` (implementação configurável em `/wol/configuracao-ia`). Controllers WOL antigos de discurso ainda usam **Gemini direto** em `improveManuscrito`.

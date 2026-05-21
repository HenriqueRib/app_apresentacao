# Documentação Mobile — Palestrante / Central da Reunião

Especificação para o time **Flutter** e **Backend**, espelhando as telas Blade em `resources/views/wol/`.

## Navegação sugerida no app

| Tela no app | Equivalente web | Doc |
|-------------|-----------------|-----|
| **Central da Reunião** | `comentarios.blade.php` (abas Comentários + Gerador de Respostas) | [central-da-reuniao.md](./central-da-reuniao.md) |
| **A Sentinela** | `assentinela.blade.php` | [assentinel.md](./assentinel.md) |
| **Discursos** | `discursos.blade.php` + edição/apresentação | [discursos.md](./discursos.md) |
| **Partes** | `partes.blade.php` + edição/apresentação | [partes.md](./partes.md) |
| **Contrato API (backlog)** | Rotas a criar/estender | [backend-requisitos-api.md](./backend-requisitos-api.md) |

## Convenções

- **Base URL API:** `{APP_URL}/api` (ex.: `https://seu-dominio.com/api`)
- **Base URL API v1:** `{APP_URL}/api/v1`
- **Admin web (hoje):** `{APP_URL}/wol/...` — sessão Laravel + `auth` + `checkAdmin`
- **Timeout IA:** 60s (gerações levam 15–30s)
- **Content-Type:** `application/json` nas rotas JSON; charset UTF-8

## Legenda de ações (todas as telas)

| Ação | Significado no app |
|------|-------------------|
| **Listar** | Carregar coleção ou item salvo no servidor |
| **Adicionar** | Criar recurso novo (POST) |
| **Editar** | Atualizar campos manualmente (PUT/PATCH) |
| **Gerar** | IA cria conteúdo pela primeira vez |
| **Melhorar (lista)** | IA **regenera** o bloco inteiro (mesma rota de Gerar) |
| **Melhorar (editor)** | IA refina **trecho** com instrução do usuário (rota `improve` separada) |
| **Visualizar** | Tela/modal de leitura integral (dados já no cliente ou GET por id) |
| **Apresentar** | Modo palco: texto grande + timer (partes: 10 min) |
| **Copiar** | Apenas cliente (clipboard) |
| **Excluir** | DELETE |

## Status da API hoje

| Módulo | API pronta para Flutter? |
|--------|-------------------------|
| Discursos (parcial) | `GET/POST/DELETE` + gerar manuscrito JSON + LEIA — **falta** guia, generate-manuscrito por id, improve |
| Comentários semana | `GET semanal/historico` — **falta** gerar/melhorar |
| Respostas geradas | **Não** (só web `/wol`) |
| Assentinel | **Não** (só web `/wol`) |
| Partes | **Não** (só web `/wol`) |

Detalhe do que o backend deve implementar: [backend-requisitos-api.md](./backend-requisitos-api.md).

## Referências

- [docs/ensino/mapeamento-rotas.md](../ensino/mapeamento-rotas.md) — mapa técnico completo
- [docs/api_documentacao_v1.md](../api_documentacao_v1.md) — contrato v1 já publicado

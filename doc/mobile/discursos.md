# Discursos (app)

Espelha `resources/views/wol/discursos.blade.php` e telas filhas (`edit`, `edit-manuscrito`, `apresentacao`).

---

## Tela principal — ações do topo

| Botão web | App | Descrição |
|-----------|-----|-----------|
| **Adicionar Novo Discurso** | Form criar | Todos os campos do discurso |
| **Editar Instrução de Geração** | Settings | 2 prompts globais |

---

## Adicionar discurso

| Campo | Obrigatório | Observação |
|-------|-------------|------------|
| `tema` | Sim | Título |
| `data` | Não | `date` ISO |
| `numero` | Não | Número do discurso |
| `cantico` | Não | Texto |
| `objetivo` | Não | Textarea |
| `esboco_original` | Não | Esboço / notas |
| `manuscrito_completo` | Não | Pode vir vazio e gerar depois |
| `fonte_materias` | Não | Referências |

**Web:** `POST /wol/discursos`  
**App hoje:** `POST /api/v1/discursos` (parcial — mesmo payload)  
**App:** falta `PUT` para editar

---

## Editar instruções globais

| Campo | Chave settings |
|-------|----------------|
| Prompt manuscrito | `prompt_discurso_geral` |
| Prompt guia prático | `prompt_discurso_guia` |

| Ação | Web | App proposto |
|------|-----|--------------|
| Ler | `GET /wol/discursos/settings` | `GET /api/v1/discursos/settings` |
| Salvar | `POST` body `{ prompt_geral, prompt_guia }` | `PUT /api/v1/discursos/settings` |

---

## Lista — card por discurso

### Coluna esquerda — detalhes

- Data, número, cântico, objetivo (somente leitura na lista)

### Coluna direita — conteúdos gerados

#### Esboço original

| Ação | Descrição |
|------|-----------|
| **Visualizar completo** | Modal com `esboco_original` |
| (sem Gerar na lista) | Esboço é entrada manual ou via editar |

#### Manuscrito completo

| Estado | Botões |
|--------|--------|
| Vazio | **Gerar Conteúdo Manuscrito** |
| Preenchido | **Visualizar**, **Copiar**, **Melhorar**, **Editar** |

#### Guia prático (`guide`)

| Estado | Botões |
|--------|--------|
| Vazio | **Gerar Guia Prático** |
| Preenchido | **Visualizar**, **Copiar**, **Melhorar**, **Editar** |

### Rodapé do card

| Botão | Navegação |
|-------|-----------|
| **Editar Discurso** | Tela edição completa |
| **Apresentar** | Modo apresentação (manuscrito) |

### Excluir

Ícone X no header → confirmação → `DELETE`

---

## Gerar / Melhorar (na lista)

**Importante:** no card da lista, **Melhorar = regenerar tudo** (mesma rota que Gerar).

| Conteúdo | Web POST | Body |
|----------|----------|------|
| Manuscrito | `/wol/discursos/generate-manuscrito` | `{ "id": 5 }` |
| Guia | `/wol/discursos/generate-guia` | `{ "id": 5 }` |

**Resposta:**

```json
{
  "success": true,
  "content": "texto longo..."
}
```

Persiste em `manuscrito_completo` ou `guide`.

**Lógica manuscrito:** `prompt_discurso_geral` + se `guide` preenchido, anexa como diretriz + `esboco_original`.

**Lógica guia:** `prompt_discurso_guia` + `esboco_original`.

**App proposto:**

- `POST /api/v1/discursos/{id}/gerar-manuscrito`
- `POST /api/v1/discursos/{id}/gerar-guia`

---

## Editar discurso (tela completa)

Campos editáveis (web `discursos.edit`):

`tema`, `data`, `numero`, `cantico`, `objetivo`, `esboco_original`, `manuscrito_completo`, `fonte_materias`, `guide`

| Ação | Web | App |
|------|-----|-----|
| Salvar | `PUT /wol/discursos/{id}` | `PUT /api/v1/discursos/{id}` ❌ criar |

---

## Editar manuscrito (tela dedicada)

Web: `discursos.manuscrito.edit`

| Recurso | Descrição |
|---------|-----------|
| Textarea | `manuscrito_completo` |
| Salvar | `PUT /wol/discursos/{id}/manuscrito` |
| Controles de fonte | Cliente only |
| Pomodoro | Cliente only |
| **Melhorar com IA** | Diferente do card! |

### Melhorar com IA (editor) — por instrução

Rota: `POST /wol/discursos/{id}/manuscrito/improve`

```json
{
  "instructions": "Melhore apenas a introdução, mais curta",
  "manuscript": "texto completo atual do textarea"
}
```

**Resposta:**

```json
{
  "success": true,
  "content": "apenas o trecho reescrito (markdown)"
}
```

O app deve **mesclar** o trecho retornado na posição indicada pelo usuário (web mostra em modal — UX a definir no Flutter).

**App proposto:** `POST /api/v1/discursos/{id}/manuscrito/improve`

---

## Apresentar

Web: `GET /wol/discursos/{id}/apresentacao` — exibe `manuscrito_completo` em tela cheia.

App: tela local com dados do `GET /api/v1/discursos/{id}` — controles de fonte no cliente (sem timer 10 min no web de discurso).

---

## Fluxo alternativo — Manuscrito a partir de ideias (API já existe)

Para **criar estrutura** sem salvar discurso:

`POST /api/v1/discursos/gerar-manuscrito/total`

```json
{ "conteudo_bruto": "notas soltas" }
```

**Resposta estruturada** (não é o mesmo que manuscrito longo do admin):

```json
{
  "titulo": "...",
  "objetivo_central": "...",
  "introducao": "...",
  "conclusao": "...",
  "pontos_principais": [{ "titulo": "...", "conteudo": "..." }]
}
```

UX sugerida: wizard “Rascunho rápido” → usuário revisa → `POST /api/v1/discursos` persiste campos mapeados.

---

## Versículos LEIA (API existente)

`POST /api/v1/discursos/sugerir-versiculos` — ver [api_documentacao_v1.md](../api_documentacao_v1.md).

Pode ser botão auxiliar na tela de criar/editar discurso.

---

## API v1 — status

| Ação | Endpoint atual | Status |
|------|----------------|--------|
| Listar | `GET /api/v1/discursos` | ✅ |
| Adicionar | `POST /api/v1/discursos` | ✅ |
| Detalhe | `GET /api/v1/discursos/{id}` | ✅ |
| Excluir | `DELETE /api/v1/discursos/{id}` | ✅ |
| Editar | `PUT` | ❌ |
| Gerar manuscrito (por id) | — | ❌ |
| Gerar guia | — | ❌ |
| Improve manuscrito | — | ❌ |
| Settings | — | ❌ |
| Rascunho JSON | `gerar-manuscrito/total` | ✅ |
| LEIA | `sugerir-versiculos` | ✅ |

Backend: [backend-requisitos-api.md](./backend-requisitos-api.md) §3.

---

## Matriz de ações (resumo)

| Ação | Onde no app | Rota proposta |
|------|-------------|---------------|
| Listar | Lista discursos | `GET /discursos` |
| Adicionar | Form novo | `POST /discursos` |
| Editar | Tela edição | `PUT /discursos/{id}` |
| Excluir | Card | `DELETE /discursos/{id}` |
| Visualizar esboço/guia/manuscrito | Modal | dados do GET |
| Gerar manuscrito | Card | `POST .../gerar-manuscrito` |
| Melhorar manuscrito (lista) | Card | mesmo POST gerar |
| Melhorar manuscrito (editor) | Tela manuscrito | `POST .../manuscrito/improve` |
| Gerar guia | Card | `POST .../gerar-guia` |
| Melhorar guia (lista) | Card | mesmo POST gerar |
| Editar instruções | Settings | `GET/PUT .../settings` |
| Apresentar | Tela palco | cliente + GET id |
| Copiar | Qualquer texto | cliente |

# Partes da Reunião (app)

Espelha `resources/views/wol/partes.blade.php`, `partes/edit`, `partes/edit-esboco`, `partes/apresentacao`.

Foco: partes de **~10 minutos** com esboço manuscrito gerado por IA.

---

## Tela principal — ações do topo

| Botão web | App |
|-----------|-----|
| **Adicionar Nova Parte** | Form criar com tópicos dinâmicos |
| **Editar Instrução de Geração** | Settings — 1 prompt (`prompt_parte_geral`) |

---

## Adicionar parte

| Campo | Obrigatório | Observação |
|-------|-------------|------------|
| `tema` | Sim | Título da parte |
| `topicos[]` | Sim (≥1) | Array de objetos |
| `topicos[].descricao` | Sim | Nome do tópico |
| `topicos[].texto` | Não | Ref. bíblica — ex.: `Jo 1:1` (backend busca em bible-api.com) |
| `topicos[].fonte` | Não | Publicação — ex.: `w15 15/12` |
| `conteudo_original` | Não | Texto base / matéria |

**UI tópicos:** lista dinâmica — botão “Adicionar tópico”, remover linha.

**Web:** `POST /wol/partes` (form urlencoded com `topicos[0][descricao]`…)  
**App:** `POST /api/v1/partes` (JSON) — **a criar no backend**

Exemplo body:

```json
{
  "tema": "Por que a oração é importante",
  "topicos": [
    {
      "descricao": "Jeová ouve",
      "texto": "Salmo 65:2",
      "fonte": "lv cap. 10"
    }
  ],
  "conteudo_original": "Parágrafos colados da matéria..."
}
```

---

## Editar instruções globais

| Campo | Chave |
|-------|-------|
| Prompt geral para esboço | `prompt_parte_geral` |

Default no código se vazio: *"Seja claro, objetivo e use uma linguagem simples e respeitosa."*

| Ação | Web | App proposto |
|------|-----|--------------|
| GET | `/wol/partes/settings` | `GET /api/v1/partes/settings` |
| POST | `{ "prompt_geral": "..." }` | `PUT /api/v1/partes/settings` |

---

## Lista — card por parte

### Bloco esquerdo

- Lista de tópicos: `descricao`, `texto`, `fonte`
- Preview `conteudo_original` (200 chars)

### Bloco direito — Esboço manuscrito

| Estado | Botões |
|--------|--------|
| Vazio | **Gerar Esboço** |
| Preenchido | **Visualizar**, **Copiar**, **Melhorar** |

### Rodapé

| Botão | Destino |
|-------|---------|
| **Editar** | Tela edição (tema, tópicos, conteúdo, esboço) |
| **Editar Esboço** | Tela só esboço + timer + improve IA |
| **Apresentar** | Modo palco + **timer 10 min** |

### Excluir

`DELETE /wol/partes/{id}`

---

## Gerar / Melhorar esboço (na lista)

Mesma rota para **Gerar** e **Melhorar (regenerar)**.

**Web:** `POST /wol/partes/generate-esboco`

```json
{ "id": 3 }
```

**Resposta:**

```json
{
  "success": true,
  "content": "manuscrito palavra por palavra..."
}
```

**Backend interno:**

1. Busca textos bíblicos via `https://bible-api.com/{texto}?translation=almeida`
2. Monta prompt com Introdução / Tópicos / Conclusão
3. Aplica `prompt_parte_geral`
4. Salva em `esboco_manuscrito`

**App:** `POST /api/v1/partes/{id}/gerar-esboco`  
**Timeout:** 60s (vários versículos + IA).

---

## Editar parte (tela completa)

Campos: `tema`, `topicos[]`, `conteudo_original`, `esboco_manuscrito`

| Ação | Web | App |
|------|-----|-----|
| Salvar | `PUT /wol/partes/{id}` | `PUT /api/v1/partes/{id}` |

---

## Editar esboço (tela dedicada)

Web: `partes.esboco.edit`

| Recurso | Descrição |
|---------|-----------|
| Textarea | `esboco_manuscrito` |
| Salvar | `PUT /wol/partes/{id}/esboco` body `{ esboco_manuscrito }` |
| Timer | Persistido em `localStorage` no web — no app usar estado local |
| **Melhorar com IA** | Rota separada |

### Melhorar com IA (editor)

`POST /wol/partes/{id}/esboco/improve`

```json
{
  "instructions": "Encurte o parágrafo sobre o primeiro tópico",
  "esboco": "texto completo atual"
}
```

**Resposta:** `{ "success": true, "content": "trecho reescrito em markdown" }`

IA retorna **apenas a seção** pedida, não o esboço inteiro.

**App:** `POST /api/v1/partes/{id}/esboco/improve`

---

## Apresentar (10 minutos)

Web: `GET /wol/partes/{id}/apresentacao`

| Recurso | Implementação web | App |
|---------|-------------------|-----|
| Texto | `esboco_manuscrito` | Tela cheia |
| Fonte +/- | localStorage | Preferências locais |
| **Timer** | 10 × 60 segundos, barra de progresso | Obrigatório replicar |
| Alerta fim | “A apresentação de 10 minutos terminou!” | Dialog ou vibração |
| Cores timer | Verde >5min, amarelo 2–5min, vermelho <2min | Igual |

Não há endpoint de timer — **100% cliente**.

---

## API — status

| Ação | Web | API v1 |
|------|-----|--------|
| Listar | GET index blade | ❌ |
| Adicionar | POST | ❌ |
| Editar | PUT | ❌ |
| Excluir | DELETE | ❌ |
| Gerar esboço | POST generate-esboco | ❌ |
| Improve esboco | POST esboco/improve | ❌ |
| Settings | GET/POST | ❌ |
| Apresentar | GET view | Cliente |

Tudo em [backend-requisitos-api.md](./backend-requisitos-api.md) §4.

---

## Matriz de ações (resumo)

| Ação | UI | Método proposto |
|------|-----|-----------------|
| Listar | Lista partes | `GET /api/v1/partes` |
| Adicionar | Form + tópicos | `POST /api/v1/partes` |
| Editar | Tela edição | `PUT /api/v1/partes/{id}` |
| Excluir | Card | `DELETE /api/v1/partes/{id}` |
| Visualizar esboço | Modal | GET detalhe |
| Gerar esboço | Card | `POST .../gerar-esboco` |
| Melhorar (lista) | Card | mesmo POST gerar |
| Melhorar (editor) | Tela esboço | `POST .../esboco/improve` |
| Salvar esboço manual | Editor | `PUT .../esboco` ou PUT parte |
| Editar instruções | Modal | `GET/PUT .../settings` |
| Apresentar | Tela palco + timer 10min | local |
| Copiar | Botão | local |

---

## Estrutura do modelo `Parte`

```json
{
  "id": 1,
  "tema": "string",
  "topicos": [
    { "descricao": "string", "texto": "string|null", "fonte": "string|null" }
  ],
  "conteudo_original": "string|null",
  "esboco_manuscrito": "string|null",
  "created_at": "...",
  "updated_at": "..."
}
```

`topicos` é JSON array no MySQL.

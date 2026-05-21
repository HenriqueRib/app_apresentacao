# Rotas em produção — o que o app pode chamar hoje

**Base:** `https://codeline43.com.br/api`  
**Headers:** `Accept: application/json`, `Content-Type: application/json`

Última atualização: alinhado ao `routes/api.php` do repositório.

---

## Resumo do problema (404 no Assentinel)

O app estava correto em **tentar** `/api/v1/assentinel/...`, mas essas rotas **ainda não estavam publicadas** no servidor (eram apenas proposta em `backend-requisitos-api.md`).

Os **fallbacks** para `/api/wol/assentinela/...` **nunca vão funcionar**:

| URL tentada pelo app | Por que falha |
|----------------------|---------------|
| `/api/v1/assentinel/estudos` | Existia só no doc; **implementado no repo** — precisa **deploy** |
| `/api/wol/assentinela/estudos` | **Não existe** em `routes/api.php` |
| `/api/wol/assentinela` | **Não existe** |
| `/api/wol/assentinela/settings` | **Não existe** |

O painel admin usa **`/wol/assentinela`** (sem `/api`, com login de sessão), não é API JSON pública.

---

## ✅ Rotas que funcionam em produção (confirmado nos logs)

### Central da Reunião — comentários da semana

```http
GET /api/v1/comentarios/semanal
```

**Status:** `200` — OK.

**Resposta (campos principais):**

```json
{
  "semana": "18-24 DE MAIO",
  "reuniao": {
    "id": 16,
    "semana_texto": "18-24 DE MAIO",
    "texto_joia_espiritual": "Isaías 65",
    "capitulo_texto": "..."
  },
  "comentarios": [
    {
      "id": 1,
      "comentario": "Em Isaías 65:1...",
      "tags": [{ "id": 1, "name": "Humildade", "slug": "humildade" }]
    }
  ]
}
```

Também disponível:

```http
GET /api/v1/comentarios/historico
```

---

## ✅ Assentinel (após deploy da versão com `Api\AssentinelController`)

**Remover fallbacks** `/api/wol/assentinela*`. Usar **somente**:

| Ação | Método | URL |
|------|--------|-----|
| Listar estudos | `GET` | `/api/v1/assentinel/estudos` |
| Criar estudo | `POST` | `/api/v1/assentinel/estudos` |
| Detalhe | `GET` | `/api/v1/assentinel/estudos/{id}` |
| Excluir | `DELETE` | `/api/v1/assentinel/estudos/{id}` |
| Gerar comentário inicial | `POST` | `/api/v1/assentinel/estudos/{id}/comentario-inicial` |
| Gerar comentário final | `POST` | `/api/v1/assentinel/estudos/{id}/comentario-final` |
| Gerar resumo-ponte | `POST` | `/api/v1/assentinel/estudos/{id}/resumo` |
| Ler prompts | `GET` | `/api/v1/assentinel/settings` |
| Salvar prompts | `PUT` | `/api/v1/assentinel/settings` |

### POST criar estudo

```json
{ "conteudo_estudo": "texto colado do estudo" }
```

### POST gerar comentário / resumo

Sem body (id na URL). Timeout recomendado: **60s**.

**Resposta:**

```json
{
  "success": true,
  "content": "texto gerado",
  "comment": "texto gerado",
  "estudo": { "...": "objeto atualizado" }
}
```

(`comment` mantido por compatibilidade com o painel web.)

### Resumo — erro 422

Se faltar inicial ou final:

```json
{
  "success": false,
  "error": "É necessário gerar os comentários inicial e final antes de criar o resumo."
}
```

---

## ❌ Rotas que o app NÃO deve chamar (ainda 404)

| Recurso | URL que o app não deve usar | Situação |
|---------|----------------------------|----------|
| Assentinel fallbacks | `/api/wol/assentinela/**` | Inexistente |
| Respostas geradas | `/api/v1/respostas-geradas` | Não implementado |
| Partes | `/api/v1/partes/**` | Não implementado |
| Discursos — guia / gerar por id | `/api/v1/discursos/{id}/gerar-guia` etc. | Não implementado |
| Comentários — gerar IA | `POST /api/wol/comentarios` | Existe, mas é outro fluxo (sem auth app) |

Até o backend publicar cada módulo: **ocultar a tela** ou mostrar “Em breve”, sem cadeia de fallback.

---

## ✅ Discursos (parcial)

| Método | URL | Status |
|--------|-----|--------|
| `GET` | `/api/v1/discursos` | ✅ |
| `POST` | `/api/v1/discursos` | ✅ |
| `GET` | `/api/v1/discursos/{id}` | ✅ |
| `DELETE` | `/api/v1/discursos/{id}` | ✅ |
| `POST` | `/api/v1/discursos/gerar-manuscrito/total` | ✅ |
| `POST` | `/api/v1/discursos/sugerir-versiculos` | ✅ |
| `PUT` | `/api/v1/discursos/{id}` | ❌ |
| `POST` | `/api/v1/discursos/{id}/gerar-manuscrito` | ❌ |
| `POST` | `/api/v1/discursos/{id}/gerar-guia` | ❌ |

---

## Outras rotas `/api` (fora do módulo ensino)

| Método | URL |
|--------|-----|
| `GET` | `/api/ia/{pergunta}` — chat (URL-encode da pergunta) |
| `POST` | `/api/wol/comentarios` — gerar comentários da semana (legado) |

---

## Checklist para o time Flutter

1. **Parar fallbacks** para `/api/wol/assentinela` — sempre 404.
2. **Central da Reunião (aba comentários):** usar só `GET /api/v1/comentarios/semanal` — já OK.
3. **Assentinel:** usar tabela acima; aguardar **deploy** do backend com rotas `v1/assentinel`.
4. Tratar **404** como “feature não publicada”, não como erro de path do cliente.
5. Não confundir com **`/wol/*`** — isso é site admin (cookie/sessão), não API do app.

---

## Deploy

Após merge/deploy, validar:

```bash
curl -s -H "Accept: application/json" https://codeline43.com.br/api/v1/assentinel/estudos
curl -s -H "Accept: application/json" https://codeline43.com.br/api/v1/assentinel/settings
```

Esperado: JSON `200`, não mensagem `"The route ... could not be found"`.

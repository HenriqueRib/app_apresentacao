# Briefing para o time Backend — Novas rotas de ensino (oratória)

**Para:** time Laravel / API v1 (`codeline43.com.br`)  
**De:** produto Flutter *Poder de Convencer*  
**Data:** 21/05/2026  
**Contexto:** O app mobile já implementa o **Ciclo de Performance** (Planejar → Preparar → Treinar → Executar → Aprimorar) e as **53 características be-T** localmente. O backend hoje é forte em **geração de texto** (manuscrito, LEIA, comentários WOL), mas fraco em **avaliação metodológica**, **partes**, **ensaio** e **formulários estruturados** — ver [relatorio-metodologico.md](./relatorio-metodologico.md) e [mapeamento-rotas.md](./mapeamento-rotas.md).

---

## 1. Resumo executivo (o que pedimos)

| Prioridade | Entrega | Por quê |
|------------|---------|---------|
| **P0** | Expor na API v1 o que já existe no `/wol` | Flutter não pode depender de Blade |
| **P0** | `POST /avaliar/esboco` (Shinyashiki + be-T) | Diferencial pedido pelo produto |
| **P1** | CRUD + geração de **partes** (10 min) | Uso semanal em reunião |
| **P1** | `POST /aprimorar/feedback` + ensaio | Fecha o ciclo Shinyashiki no servidor |
| **P2** | Módulo **avaliação de oradores** (inspirado S-315) | Anciãos / circuito — uso restrito |
| **P2** | OCR opcional de esboço manuscrito | Foto → texto → mesma rota de avaliação |

---

## 2. Princípios de design da API

1. **Modo de saída explícito** em rotas de IA: `esboco_topicos` | `manuscrito` | `guia_estudo` | `avaliacao` (nunca só texto corrido sem estrutura).
2. **Envelope Laravel** aceito: `{ "data": ... }` — o Flutter normaliza.
3. **Metadados Shinyashiki** em `discursos.metadados` (JSON) ou tabela `discurso_etapas`:
   - `passo_atual`: `planejar|preparar|treinar|executar|aprimorar`
   - `esboco_validado`: boolean (opcional gate antes de gerar manuscrito)
4. **Prompts** continuam em `settings`; novas chaves sugeridas no final deste documento.
5. **Privacidade (S-315):** rotas de avaliação de orador exigem `auth` + papel `anciao` / `avaliador`; logs sem expor avaliações a terceiros.

---

## 3. Fase A — Espelhar admin em `/api/v1` (P0)

Reutilizar controllers WOL existentes; criar thin wrappers em `Api\*` se necessário.

### 3.1 Partes de reunião

| Método | URL | Body / notas |
|--------|-----|----------------|
| `GET` | `/api/v1/partes` | Lista |
| `POST` | `/api/v1/partes` | `{ tema, topicos[], conteudo_original?, duracao_minutos: 10 }` |
| `GET` | `/api/v1/partes/{id}` | Detalhe |
| `PUT` | `/api/v1/partes/{id}` | Atualiza |
| `DELETE` | `/api/v1/partes/{id}` | Remove |
| `POST` | `/api/v1/partes/{id}/generate-esboco` | Igual WOL; aceitar `modo: "esboco_topicos" \| "manuscrito"` |
| `POST` | `/api/v1/partes/{id}/esboco/improve` | `{ secao, instrucoes }` |
| `GET` | `/api/v1/partes/settings` | `prompt_parte_geral` |
| `PUT` | `/api/v1/partes/settings` | Salva prompt |

### 3.2 Discursos — guia e melhoria

| Método | URL | Body / notas |
|--------|-----|----------------|
| `POST` | `/api/v1/discursos/{id}/generate-guia` | Esboço → campo `guide` |
| `POST` | `/api/v1/discursos/{id}/manuscrito/improve` | `{ trecho, instrucoes }` |
| `GET` | `/api/v1/discursos/settings` | `prompt_discurso_geral`, `prompt_discurso_guia` |
| `PUT` | `/api/v1/discursos/settings` | Salva |

### 3.3 Assentinel + respostas (já no contrato Flutter)

| Método | URL |
|--------|-----|
| `GET/POST` | `/api/v1/assentinel/estudos` |
| `POST` | `/api/v1/assentinel/estudos/{id}/generate-initial` |
| `POST` | `/api/v1/assentinel/estudos/{id}/generate-final` |
| `POST` | `/api/v1/assentinel/estudos/{id}/generate-summary` |
| `GET/PUT` | `/api/v1/assentinel/settings` |
| `GET/POST` | `/api/v1/respostas-geradas` |
| `POST` | `/api/v1/respostas-geradas/{id}/improve` |

### 3.4 Comentários — gerar via v1

| Método | URL | Nota |
|--------|-----|------|
| `POST` | `/api/v1/comentarios/gerar` | Migrar de `POST /api/wol/comentarios` para grupo v1 autenticado |

---

## 4. Fase B — Avaliar esboço manuscrito (Shinyashiki + be-T) — **P0**

Esta é a rota central pedida pelo produto: o usuário envia esboço (texto digitado, JSON do app ou OCR) e recebe **avaliação pedagógica**, não um novo discurso.

### `POST /api/v1/avaliar/esboco`

**Request:**

```json
{
  "tipo": "parte_10min | discurso_publico | discurso_estudante",
  "titulo": "string opcional",
  "objetivo_central": "string",
  "esboco": {
    "introducao": "texto ou tópicos",
    "pontos_principais": [
      {
        "titulo": "Ponto 1",
        "ideias": ["..."],
        "textos_biblicos": [
          {
            "referencia": "João 3:16",
            "ler": "...",
            "explicar": "...",
            "ilustrar": "...",
            "aplicar": "..."
          }
        ],
        "ilustracoes": ["..."]
      }
    ],
    "conclusao": "texto ou tópicos"
  },
  "esboco_texto_livre": "alternativa: colar esboço manuscrito corrido",
  "duracao_minutos": 10,
  "caracteristica_foco_id": 12,
  "idioma": "pt-BR"
}
```

**Response (200):**

```json
{
  "data": {
    "nota_geral": "A|B|C|NR",
    "passo_shinyashiki": "preparar",
    "objetivo_claro": true,
    "proporcao_tempo": {
      "introducao_pct": 12,
      "corpo_pct": 78,
      "conclusao_pct": 10,
      "dentro_do_ideal_10min": true,
      "comentario": "Introdução um pouco longa para parte de 10 min."
    },
    "estrutura_bet": {
      "introducao": { "status": "ok|atencao|falta", "itens": [] },
      "corpo": { "status": "ok", "transicoes": "atencao", "pontos": [] },
      "conclusao": { "status": "ok", "chama_acao": true }
    },
    "leia": [
      {
        "referencia": "João 3:16",
        "completo": false,
        "faltando": ["ilustrar"],
        "sugestao": "..."
      }
    ],
    "pilares_shinyashiki": [
      { "id": "credibilidade", "nota": "B+", "observacao": "..." },
      { "id": "empatia", "nota": "B", "observacao": "..." },
      { "id": "entusiasmo", "nota": "A-", "observacao": "..." }
    ],
    "caracteristicas_be_t": [
      { "id": 7, "titulo": "Ênfase nas ideias principais", "nota": "B", "evidencia": "...", "sugestao": "..." }
    ],
    "pontos_fortes": ["..."],
    "pontos_melhorar": ["..."],
    "proximos_passos": [
      "Reescrever introdução em 2 frases",
      "Completar LEIA no segundo texto"
    ],
    "persistido_id": "uuid-opcional-se-salvar-historico"
  }
}
```

**Regras do prompt (sugestão `prompt_avaliar_esboco` em settings):**

- Avaliar como **instrutor be-T**, não reescrever o esboço inteiro.
- Validar: objetivo central, intro/corpo/conclusão, transições, LEIA por versículo, ilustrações, tempo.
- Cruzar com **3 pilares Shinyashiki** (credibilidade, empatia, entusiasmo).
- Se `caracteristica_foco_id` vier preenchido, dar 40% do peso do feedback a essa característica.
- Para `parte_10min`: penalizar manuscrito palavra-a-palavra excessivo; valorizar tópicos de ideias.
- Tom: construtivo, discreto, sem linguagem de julgamento pessoal.

**Persistência (opcional P1):**

Tabela `avaliacoes_esboco`: `id`, `user_id`, `discurso_id|null`, `payload_request`, `payload_response`, `created_at`.

### `POST /api/v1/avaliar/esboco/ocr` (P2)

Multipart: `imagem` (jpg/png). Pipeline: OCR → normalizar → chamar mesma lógica de `avaliar/esboco` com `esboco_texto_livre`.

---

## 5. Fase C — Estudo guiado (pesquisa, meditação, memorização) — P1

| Método | URL | Objetivo |
|--------|-----|----------|
| `POST` | `/api/v1/estudo/pesquisa` | Perguntas + citações a partir de `fonte` + trecho (sem gerar manuscrito) |
| `POST` | `/api/v1/estudo/meditacao` | 3–5 perguntas por tópico do esboco |
| `POST` | `/api/v1/estudo/memorizar` | Cartões frente/verso a partir do esboco |
| `GET` | `/api/v1/estudo/progresso/{discurso_id}` | Checklist por passo Shinyashiki |

---

## 6. Fase D — Treinar e aprimorar (fecha o ciclo) — P1

### Ensaio

`POST /api/v1/ensaio/registrar`

```json
{
  "discurso_id": "1",
  "tipo": "parte|discurso",
  "duracao_segundos": 612,
  "meta_minutos": 10,
  "nivel_energia": 4,
  "checklist_palco": { "microfone": true, "agua": true },
  "notas": "texto livre",
  "audio_url": "opcional S3"
}
```

`GET /api/v1/ensaio/metas-tempo?tipo=parte_10min` → split sugerido `{ intro: 1, corpo: 7, conclusao: 2 }` (minutos).

### Feedback pós-apresentação (autoavaliação + terceiros)

`POST /api/v1/aprimorar/feedback`

```json
{
  "discurso_id": "1",
  "objetivo_alcancado": true,
  "engajamento_audiencia": 4,
  "competencias": [
    { "id": "clareza", "nota": 4 },
    { "id": "aplicacao", "nota": 5 }
  ],
  "caracteristicas_ids": [7, 14, 22],
  "pontos_fortes": "...",
  "pontos_melhorar": "...",
  "licoes_aprendidas": "..."
}
```

Alinha com `competencies_feedback` do JSON be-T no Flutter.

---

## 7. Fase E — Avaliação de oradores e intérpretes (inspirado S-315) — P2

**Uso:** formulário interno para corpo de anciãos (não é feature pública da loja). Requer autenticação e perfil autorizado.

### Modelo sugerido

Tabelas: `avaliacoes_orador`, `avaliacoes_orador_itens`, `avaliadores` (quem preencheu).

### `POST /api/v1/avaliacoes-orador`

```json
{
  "avaliado": {
    "nome": "Irmão X",
    "congregacao": "...",
    "idioma_avaliacao": "pt-BR",
    "contato": { "email": "...", "telefone": "..." },
    "etnia": "opcional conforme formulário oficial",
    "jw_hub": true
  },
  "triagem_bloqueio": {
    "ideias_sempre_melhores": false,
    "reputacao_rigido": false,
    "impoe_suas_ideias": false,
    "procrastinador": false,
    "aparencia_desconfortavel": false,
    "ofensa_assistencia": false,
    "bloqueado": false
  },
  "notas": {
    "DIS": "A+",
    "ENT": "B",
    "INT": "NR"
  },
  "legenda_notas": "A excelente, B acima da média, C mediano, NR não recomendado",
  "observacoes": {
    "habilidade_orador": "texto longo — estilo, voz, clareza bíblica...",
    "personalidade": "humilde, zeloso...",
    "familia": "exemplo, filhos, recomenda_parte_familia: true"
  },
  "recomendado_ano_anterior": true,
  "nao_recomendado_motivo": "texto se NR em todas categorias",
  "avaliadores_count": 3,
  "avaliado_ausente_durante_votacao": true
}
```

### `GET /api/v1/avaliacoes-orador?congregacao=...&ano=2026`

Lista para exportação (PDF/CSV futuro no admin).

### `POST /api/v1/avaliacoes-orador/gerar-rascunho-observacoes` (IA assistida)

Entrada: notas DIS/ENT/INT + bullets do avaliador → IA redige parágrafos nos moldes dos itens (9)–(11) do S-315, **sem inventar fatos**; avaliador revisa antes de salvar.

**Importante:** produto deve deixar claro que isso é **ferramenta de apoio** às instruções oficiais da organização, não substituto do formulário S-315 impresso, salvo orientação local.

---

## 8. Outras rotas de alto valor (backlog)

| Rota | Descrição |
|------|-----------|
| `POST /avaliar/manuscrito` | Avaliar prosa final (fluência, repetição, tempo de leitura estimado) |
| `POST /avaliar/ensaio-audio` | Transcrição + métricas (velocidade, muletillas) — P3 |
| `POST /discursos/validar-leia` | Valida só textos bíblicos de um esboço JSON |
| `POST /partes/sugerir-topicos` | Matéria da apostila → array de tópicos |
| `GET /reuniao/designacoes` | Integração futura com designações (se houver fonte) |

---

## 9. Novas chaves em `settings`

| Chave | Uso |
|-------|-----|
| `prompt_avaliar_esboco` | Avaliação Shinyashiki + be-T |
| `prompt_avaliar_manuscrito` | Avaliação de texto corrido |
| `prompt_esboco_topicos_parte` | Forçar saída em tópicos, não prosa |
| `prompt_avaliacao_orador_rascunho` | Rascunho observações S-315 |
| `prompt_meditacao_topico` | Perguntas de meditação |
| `prompt_cartoes_memorizacao` | Flashcards |

---

## 10. Checklist de implementação (para o backend)

- [ ] Grupo `Route::prefix('v1')` com partes, assentinel, respostas, settings (espelhar WOL)
- [ ] `POST /avaliar/esboco` + prompt + testes com payload do Flutter (`SpeechOutline`)
- [ ] Tabela histórico `avaliacoes_esboco` (opcional)
- [ ] `POST /ensaio/registrar` + `POST /aprimorar/feedback`
- [ ] Auth Bearer / Sanctum em rotas de avaliação e orador
- [ ] Documentar em `docs/api_documentacao_v1.md`
- [ ] Atualizar [../mobile/contrato-json-backend-flutter.md](../mobile/contrato-json-backend-flutter.md)

---

## 11. Exemplo de teste rápido (curl)

```bash
curl -X POST https://codeline43.com.br/api/v1/avaliar/esboco \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN" \
  -d '{
    "tipo": "parte_10min",
    "objetivo_central": "Mostrar por que confiar em Jeová traz paz",
    "duracao_minutos": 10,
    "esboco": {
      "introducao": "Pergunta sobre ansiedade",
      "pontos_principais": [{
        "titulo": "Deus cuida de nós",
        "ideias": ["Salmo 55:22"],
        "textos_biblicos": [{
          "referencia": "Salmo 55:22",
          "ler": "Lança sobre Jeová o teu fardo",
          "explicar": "Confiar na direção de Deus",
          "ilustrar": "",
          "aplicar": "Orar antes de decisões"
        }]
      }],
      "conclusao": "Convite a ação"
    }
  }'
```

---

## 12. Referências no monorepo / app

| Artefato Flutter | Campo equivalente na API |
|------------------|-------------------------|
| `Speech.outline` | `esboco` |
| `MainPoint` + `BiblicalText` | `pontos_principais[]` + LEIA |
| `assets/data/caracteristicas_oratoria.json` | `caracteristicas_be_t[]` |
| Autoavaliação be-T (ferramenta) | `POST /aprimorar/feedback` |

Dúvidas de contrato: alinhar com o responsável pelo app antes de alterar nomes de campos.

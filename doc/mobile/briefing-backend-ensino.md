# Briefing para o time Backend — Novas rotas de ensino (oratória)

**Para:** time Laravel / API v1 (`codeline43.com.br`)  
**De:** produto Flutter *Poder de Convencer*  
**Data:** 21/05/2026  
**Status:** acordado com produto mobile — fonte de verdade para contrato e prioridades  

**Documentos relacionados:**

| Público | Documento |
|---------|-----------|
| Flutter | [plano-api-ensino.md](./plano-api-ensino.md) — o que o app vai consumir |
| Flutter ↔ API | [contrato-json-backend-flutter.md](./contrato-json-backend-flutter.md) |
| Backend (resumo técnico) | [../ensino/brief-backend-novas-rotas.md](../ensino/brief-backend-novas-rotas.md) |
| Metodologia | [../ensino/relatorio-metodologico.md](../ensino/relatorio-metodologico.md) |

**Contexto:** O app mobile já implementa o **Ciclo de Performance** (Planejar → Preparar → Treinar → Executar → Aprimorar) e as **53 características be-T** localmente. O backend hoje é forte em **geração de texto** (manuscrito, LEIA, comentários WOL), mas fraco em **avaliação metodológica**, **partes**, **ensaio** e **formulários estruturados** — ver [relatorio-metodologico.md](../ensino/relatorio-metodologico.md) e [mapeamento-rotas.md](../ensino/mapeamento-rotas.md).

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
4. **Prompts** continuam em `settings`; novas chaves sugeridas na §9.
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
| `PUT` | `/api/v1/discursos/{id}` | Edição manual (faltava na v1) |
| `POST` | `/api/v1/discursos/{id}/generate-guia` | Esboço → campo `guide` |
| `POST` | `/api/v1/discursos/{id}/gerar-manuscrito` | Esboço + prompts → `manuscrito_completo` |
| `POST` | `/api/v1/discursos/{id}/manuscrito/improve` | `{ trecho, instrucoes }` |
| `GET` | `/api/v1/discursos/settings` | `prompt_discurso_geral`, `prompt_discurso_guia` |
| `PUT` | `/api/v1/discursos/settings` | Salva |

> **Já em produção (repo):** `GET/POST/DELETE discursos`, `POST gerar-manuscrito/total`, `POST sugerir-versiculos`.

### 3.3 Assentinel + respostas

| Método | URL | Nota implementação |
|--------|-----|-------------------|
| `GET/POST` | `/api/v1/assentinel/estudos` | ✅ no repo |
| `POST` | `/api/v1/assentinel/estudos/{id}/comentario-inicial` | ✅ (mobile pode chamar `generate-initial` como alias futuro) |
| `POST` | `/api/v1/assentinel/estudos/{id}/comentario-final` | ✅ |
| `POST` | `/api/v1/assentinel/estudos/{id}/resumo` | ✅ |
| `GET/PUT` | `/api/v1/assentinel/settings` | ✅ |
| `GET/POST` | `/api/v1/respostas-geradas` | ❌ a implementar |
| `POST` | `/api/v1/respostas-geradas/{id}/improve` | ❌ a implementar |

### 3.4 Comentários — gerar via v1

| Método | URL | Nota |
|--------|-----|------|
| `GET` | `/api/v1/comentarios/semanal` | ✅ produção |
| `GET` | `/api/v1/comentarios/historico` | ✅ produção |
| `POST` | `/api/v1/comentarios/gerar` | Migrar de `POST /api/wol/comentarios` para v1 autenticado |

---

## 4. Fase B — Avaliar esboço manuscrito (Shinyashiki + be-T) — **P0**

Rota central: o usuário envia esboço (texto digitado, JSON do app ou OCR) e recebe **avaliação pedagógica**, não um novo discurso.

### `POST /api/v1/avaliar/esboco`

Ver payload e response completos em [contrato-json-backend-flutter.md](./contrato-json-backend-flutter.md#post-apiv1avaliaresboco).

**Regras do prompt (`prompt_avaliar_esboco` em settings):**

- Avaliar como **instrutor be-T**, não reescrever o esboço inteiro.
- Validar: objetivo central, intro/corpo/conclusão, transições, LEIA por versículo, ilustrações, tempo.
- Cruzar com **3 pilares Shinyashiki** (credibilidade, empatia, entusiasmo).
- Se `caracteristica_foco_id` vier preenchido, dar 40% do peso do feedback a essa característica.
- Para `parte_10min`: penalizar manuscrito palavra-a-palavra excessivo; valorizar tópicos de ideias.
- Tom: construtivo, discreto, sem linguagem de julgamento pessoal.

**Persistência (opcional P1):** tabela `avaliacoes_esboco`.

### `POST /api/v1/avaliar/esboco/ocr` (P2)

Multipart: `imagem` (jpg/png). Pipeline: OCR → `esboco_texto_livre` → mesma lógica de `avaliar/esboco`.

---

## 5. Fase C — Estudo guiado — P1

| Método | URL | Objetivo |
|--------|-----|----------|
| `POST` | `/api/v1/estudo/pesquisa` | Perguntas + citações a partir de `fonte` + trecho |
| `POST` | `/api/v1/estudo/meditacao` | 3–5 perguntas por tópico do esboco |
| `POST` | `/api/v1/estudo/memorizar` | Cartões frente/verso |
| `GET` | `/api/v1/estudo/progresso/{discurso_id}` | Checklist por passo Shinyashiki |

---

## 6. Fase D — Treinar e aprimorar — P1

### Ensaio

`POST /api/v1/ensaio/registrar` — ver [contrato-json-backend-flutter.md](./contrato-json-backend-flutter.md#ensaio).

`GET /api/v1/ensaio/metas-tempo?tipo=parte_10min` → `{ intro: 1, corpo: 7, conclusao: 2 }` (minutos).

### Feedback pós-apresentação

`POST /api/v1/aprimorar/feedback` — alinha com `competencies_feedback` e autoavaliação be-T no Flutter.

---

## 7. Fase E — Avaliação de oradores (S-315) — P2

Uso interno (ancianato). Auth + papel `anciao` / `avaliador`.

- `POST /api/v1/avaliacoes-orador`
- `GET /api/v1/avaliacoes-orador?congregacao=...&ano=2026`
- `POST /api/v1/avaliacoes-orador/gerar-rascunho-observacoes` (IA assistida, sem inventar fatos)

Ver schema em [contrato-json-backend-flutter.md](./contrato-json-backend-flutter.md#avaliacao-orador-s-315).

---

## 8. Backlog de alto valor

| Rota | Descrição | Prioridade |
|------|-----------|------------|
| `POST /avaliar/manuscrito` | Fluência, repetição, tempo de leitura | P2 |
| `POST /avaliar/ensaio-audio` | Transcrição + muletillas | P3 |
| `POST /discursos/validar-leia` | Valida LEIA no esboço JSON | P2 |
| `POST /partes/sugerir-topicos` | Matéria → tópicos | P2 |
| `GET /reuniao/designacoes` | Designações (fonte futura) | P3 |

---

## 9. Novas chaves em `settings`

| Chave | Uso |
|-------|-----|
| `prompt_avaliar_esboco` | Avaliação Shinyashiki + be-T |
| `prompt_avaliar_manuscrito` | Avaliação de texto corrido |
| `prompt_esboco_topicos_parte` | Saída em tópicos, não prosa |
| `prompt_avaliacao_orador_rascunho` | Rascunho observações S-315 |
| `prompt_meditacao_topico` | Meditação |
| `prompt_cartoes_memorizacao` | Flashcards |

---

## 10. Checklist de implementação (backend)

- [ ] Grupo `v1`: partes, respostas-geradas, discursos (completar)
- [ ] `POST /avaliar/esboco` + prompt + testes (`SpeechOutline`)
- [ ] Tabela `avaliacoes_esboco` (opcional)
- [ ] `POST /ensaio/registrar` + `POST /aprimorar/feedback`
- [ ] Auth Bearer em avaliação e orador
- [ ] `docs/api_documentacao_v1.md` + [contrato-json-backend-flutter.md](./contrato-json-backend-flutter.md)
- [ ] Deploy: [ROTAS-PRODUCAO.md](./ROTAS-PRODUCAO.md)

---

## 11. Exemplo curl

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

## 12. Referências Flutter

| Artefato Flutter | Campo API |
|------------------|-----------|
| `Speech.outline` | `esboco` |
| `MainPoint` + `BiblicalText` | `pontos_principais[]` + LEIA |
| `assets/data/caracteristicas_oratoria.json` | `caracteristicas_be_t[]` |
| Autoavaliação be-T | `POST /aprimorar/feedback` |
| Ciclo de Performance (home) | `estudo/progresso` + metadados `passo_atual` |

Dúvidas de contrato: alinhar com responsável Flutter antes de renomear campos.

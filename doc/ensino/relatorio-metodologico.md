# Relatório metodológico — Oratória Shinyashiki × be-T

Análise do que o backend **já implementa** versus os manuais *Os Segredos das Apresentações Poderosas* (Shinyashiki) e *Beneficie-se da Escola do Ministério Teocrático* (be-T), com foco em preparação de **partes de 10 minutos** e **discursos**.

---

## 1. Arquitetura atual (“sob o capô”)

### 1.1 Camadas

| Camada | Responsabilidade |
|--------|------------------|
| **Rotas** | `routes/api.php` (Flutter), `routes/web.php` prefixo `/wol` (admin) |
| **Controllers** | `Api\DiscursoController`, `Wol\DiscursoController`, `Wol\ParteController`, `Wol\AssentinelController`, `IaController`, `RespostaGeradaController` |
| **Persistência** | MySQL: `discursos`, `partes`, `assentinel_studies`, `reunioes`, `comentarios`, `settings` |
| **IA** | `AiServiceInterface` + prompts em `settings` ou embutidos no código |
| **Bíblia externa** | `bible-api.com` (Almeida) em partes e geração por capítulo |

### 1.2 Modelo mental do produto hoje

O sistema é predominantemente um **gerador e editor de texto final**, não um **fluxo de estudo guiado**:

1. Usuário cola esboço / tópicos / texto da matéria.
2. IA expande para manuscrito ou guia.
3. Usuário edita, copia ou entra em modo apresentação.

Não há etapas formais de pesquisa documentada, fichas de meditação, cartões de memorização nem checklist be-T por característica.

---

## 2. Mapeamento metodológico — 5 passos de Shinyashiki

| Passo Shinyashiki | Significado usual | O que o sistema cobre hoje | Evidência no código |
|-------------------|-------------------|----------------------------|---------------------|
| **1. Planejar** | Tema, público, objetivo, estrutura macro, tempo | **Parcial** | API `gerar-manuscrito/total` define `objetivo_central` e estrutura JSON; CRUD de `Discurso` com `tema`, `objetivo`, `data`, `cantico`; partes com `tema` + `topicos[]` |
| **2. Preparar** | Pesquisa, esboço, argumentos, ilustrações | **Forte na geração, fraco no processo** | `generate-guia`, `generate-manuscrito`, `generate-esboco`; `RespostaGerada` com `fonte_pesquisa`; Assentinel a partir de `conteudo_estudo` |
| **3. Treinar** | Ensaios, tempo, voz, gestos | **Mínimo** | Modo apresentação + timer 10 min em `partes/apresentacao`; Pomodoro na UI de manuscrito (sem rota); `improve*` para refinar trechos |
| **4. Executar** | Entrega ao público | **UI apenas** | `discursos.apresentacao`, `partes.apresentacao` (texto grande, controles de fonte) |
| **5. Aprimorar** | Feedback, revisão, lições | **Pontual** | Re-gerar (“Melhorar”), `improveManuscrito` / `improveEsboco`; sem gravação, autoavaliação nem histórico de ensaios |

### Diagrama de cobertura

```mermaid
quadrantChart
    title Cobertura Shinyashiki (estimativa)
    x Baixa automação
    x Alta automação
    y Pouco suporte metodológico
    y Muito suporte metodológico
    quadrant-1 Ideal futuro
    quadrant-2 Geração atual
    quadrant-3 Manual do usuário
    quadrant-4 Execução UI
    Planejar: [0.55, 0.45]
    Preparar: [0.75, 0.35]
    Treinar: [0.25, 0.2]
    Executar: [0.15, 0.5]
    Aprimorar: [0.4, 0.25]
```

**Conclusão:** o backend **ancora-se em Preparar (texto)** e toca **Executar** na interface. **Treinar** e **Aprimorar** sistemáticos quase não existem como rotas ou entidades.

---

## 3. Alinhamento teocrático (be-T) — Introdução, Corpo, Conclusão

### 3.1 O que o be-T exige (resumo operacional)

- **Introdução:** prender atenção, apresentar assunto, mostrar por que é importante.
- **Corpo (discurso principal):** blocos lógicos; uso de textos; transições; aplicação.
- **Conclusão:** resumo breve, reforço do objetivo, incentivo à ação.

### 3.2 Discursos (`Wol\DiscursoController` + API)

| Elemento be-T | Implementado? | Como |
|---------------|---------------|------|
| Introdução | **Sim (por prompt)** | API: item `introducao` no JSON; seed manuscrito: “Inclua introdução…” |
| Corpo | **Sim como pontos** | API: `pontos_principais[]`; manuscrito expande esboço em prosa |
| Conclusão | **Sim (por prompt)** | API: `conclusao`; seed e prompts pedem fechamento |
| Esboço vs manuscrito | **Sim** | `esboco_original` → `manuscrito_completo`; `guide` como etapa intermediária configurável |

**Limitação:** não há validação automática de proporção de tempo (ex.: 10% intro / 80% corpo / 10% conclusão) nem campos separados “principal argumento” / “texto de apoio” como no formulário be-T.

### 3.3 Partes de reunião (`Wol\ParteController`)

O prompt de `generateEsboco` **explicita** a tríade:

```147:154:app/Http/Controllers/Wol/ParteController.php
        **Estrutura a Seguir:**
        1.  **Introdução:** Comece com uma introdução cativante que apresente o tema principal.
        2.  **Desenvolvimento dos Tópicos:** Desenvolva cada um dos tópicos listados abaixo. Para cada tópico:
            -   Leia o texto bíblico associado.
            -   Explique o texto de forma clara.
        3.  **Conclusão:** Termine com uma conclusão poderosa que resuma os pontos principais e incentive a aplicação prática.
```

Porém a saída é **manuscrito corrido** (“NÃO FAÇA UM RESUMO OU UM ESBOÇO EM TÓPICOS”), o que **afasta** o esboço conciso recomendado no be-T para partes — favorece leitura literal, não cartões de ideias.

### 3.4 Guia prático vs guia de estudo

- Campo **`guide`**: texto gerado por `prompt_discurso_guia` (conteúdo livre, definido pelo admin).
- Coluna **`guia_estudo`**: migration antiga, **não usada** no model/controller atual.

Ou seja: “guia de estudo” no sentido be-T (perguntas para meditação, pesquisa, esboço em tópicos) **depende 100% do texto do prompt** em `settings`, não de regras fixas no código.

---

## 4. Identificação de regras — LEIA e 53 características

### 4.1 Método LEIA

| Onde | Implementação |
|------|----------------|
| `POST /api/v1/discursos/sugerir-versiculos` | Prompt com quatro campos JSON: `ler`, `explicar`, `ilustrar`, `aplicar` |
| `ParteController@generateEsboco` | Instrui “Leia / Explique” por tópico, mas **não** nomeia LEIA nem gera JSON por versículo |
| Discurso manuscrito API | Não aplica LEIA nos pontos principais |

**LEIA está formalizado apenas na rota de sugestão de versículos da API v1.**

### 4.2 53 características de oratória (be-T / materiais relacionados)

**Não há** referência no repositório a:

- checklist das 53 características,
- scoring,
- prompts por característica (ex.: “34 — Contato visual”),
- relatório pós-apresentação.

A única lista fixa no código é de **tags** para comentários de reunião (12 temas espirituais), não características de fala.

### 4.3 Outras regras embutidas

| Regra | Onde |
|-------|------|
| Comentário ~30 segundos | `IaController::criarComentariosComGemini` |
| Máx. 3 versículos por lote | Mesmo prompt |
| Tags fechadas (12) | Comentários semanais |
| Duração 10 min | Timer JS em `partes/apresentacao.blade.php` |
| Objetivo central único | API manuscrito |
| Impacto em <30s na intro | API manuscrito |

---

## 5. Gap analysis — Estudar a matéria vs texto pronto

### 5.1 Três pilares be-T de estudo

| Pilar | Estado atual | Lacuna |
|-------|--------------|--------|
| **Pesquisa** | `fonte_materias` no discurso; `fonte_pesquisa` em respostas; tópicos com `fonte` em partes | Sem rota de “ficha de pesquisa”, sem ligação a publicações JW, sem perguntas guiadas por parágrafo |
| **Meditação** | Assentinel: estudo → comentários inicial/final/resumo | Não há perguntas de meditação por seção do esboço; `guide` não é estruturado |
| **Memorização** | Nenhum | Sem cartões, sem modo “esboço só tópicos”, sem revisão espaçada |

### 5.2 Comportamento “texto pronto”

Várias rotas pedem explicitamente **manuscrito palavra por palavra**:

- Partes: “texto corrido, pronto para ser lido em voz alta”.
- Discurso: seed “roteiro completo para ser lida ou apresentada”.

Isso **pula** o esboço enxuto que o estudante deveria dominar antes do manuscrito — adequado para quem já estudou, mas **contrário** ao objetivo de “ferramenta de estudo” se usado como primeiro passo.

### 5.3 Ferramentas de estudo existentes (não metodológicas)

Na view `edit-manuscrito.blade.php`:

- Controle de fonte (+/- A, família).
- Widget Pomodoro (client-side).
- “Melhorar com IA” por instrução livre.

Nenhuma dessas funcionalidades possui endpoint dedicado no Flutter.

### 5.4 Partes de 10 minutos

| Recurso | Status |
|---------|--------|
| Timer 10 min | **Só** em apresentação de partes (Blade) |
| Cálculo de palavras / WPM | Ausente |
| Divisão sugerida intro/corpo/conclusão por tempo | Ausente |
| API para Flutter replicar timer | Ausente |

---

## 6. Matriz funcional — Rotas desejadas vs existentes

Legenda: ✅ existe | ⚠️ parcial | ❌ ausente

| Funcionalidade | Admin `/wol` | API `/api/v1` |
|----------------|-------------|---------------|
| Esboço em tópicos (be-T) | ⚠️ entrada manual; IA gera prosa | ❌ |
| Guia de estudo estruturado | ⚠️ `generate-guia` (prompt livre) | ❌ |
| Manuscrito longo | ✅ | ✅ (JSON estruturado) |
| LEIA por versículo | ❌ | ✅ |
| Comentários reunião | ✅ | ✅ leitura |
| Assentinel estudo | ✅ | ❌ |
| Ensaio / cronômetro | ⚠️ UI parte | ❌ |
| Autoavaliação 53 características | ❌ | ❌ |
| Pesquisa guiada | ⚠️ respostas-geradas | ❌ |
| Memorização / flashcards | ❌ | ❌ |
| Pós-apresentação (aprimorar) | ⚠️ improve | ❌ |

---

## 7. Recomendações para novas ferramentas (roadmap técnico)

Prioridade sugerida para alinhar Shinyashiki + be-T + Flutter + partes 10 min.

### Fase A — Expor e estruturar o que já existe

1. **API v1** espelhar rotas admin críticas:
   - `POST /partes/generate-esboco`
   - `POST /discursos/generate-guia`
   - `GET/PUT` partes e settings de prompt
2. Padronizar resposta: modo `esboco_topicos` | `manuscrito` | `guia_estudo` no body (evitar só texto corrido).
3. Documentar `guide` vs deprecar `guia_estudo` no banco.

### Fase B — Estudo real (pesquisa, meditação, memorização)

| Nova rota (sugestão) | Objetivo |
|----------------------|----------|
| `POST /estudo/pesquisa` | Perguntas + citações a partir de `fonte` + trecho (sem gerar manuscrito) |
| `POST /estudo/meditacao` | 3–5 perguntas por tópico do esboço |
| `POST /estudo/memorizar` | Cartões (frente/verso) a partir do esboço |
| `GET /estudo/progresso/{id}` | Checklist por etapa Shinyashiki |

Prompts devem citar seções be-T (intro/corpo/conclusão) **sem** substituir o manual — como checklist, não como discurso final.

### Fase C — Treinar e aprimorar (10 min)

| Nova rota / recurso | Objetivo |
|---------------------|----------|
| `POST /ensaio/registrar` | Tempo, notas, áudio opcional |
| `GET /ensaio/metas-tempo` | Split 1–2 min intro, 7–8 corpo, 1 min conclusão |
| `POST /aprimorar/avaliacao` | Formulário das 53 características (subset por tipo de parte) |
| WebSocket ou polling | Timer sincronizado no Flutter |

### Fase D — Metodologia explícita no código

- Enum `MetodologiaPasso`: `planejar|preparar|treinar|executar|aprimorar`.
- Tabela `discurso_etapas` ou JSON em `discursos.metadados`.
- Validação: não permitir `generate-manuscrito` sem `esboco_validado` (flag opcional).

---

## 8. Resumo executivo

| Pergunta | Resposta curta |
|----------|----------------|
| Encaixa nos 5 passos de Shinyashiki? | **Preparar** (geração) e um pouco de **Planejar**/**Executar**; **Treinar** e **Aprimorar** quase só na UI |
| Respeita Intro / Corpo / Conclusão be-T? | **Sim nos prompts**, principalmente partes e API de manuscrito; saída muitas vezes é **prosa completa**, não esboço be-T |
| LEIA implementado? | **Sim**, rota `sugerir-versiculos`; **não** integrado à geração de partes/discurso completo |
| 53 características? | **Não** |
| Estuda vs texto pronto? | Hoje é **gerador de texto pronto**; guia e Assentinel são passos intermediários **configuráveis**, não fluxo obrigatório de estudo |

O mapa completo de URLs está em [mapeamento-rotas.md](./mapeamento-rotas.md).

---

## 9. Referências no repositório

| Arquivo | Relevância |
|---------|------------|
| `routes/web.php` (grupo `wol`) | Todas as rotas admin de ensino |
| `routes/api.php` | API Flutter |
| `app/Http/Controllers/Api/DiscursoController.php` | LEIA + manuscrito JSON |
| `app/Http/Controllers/Wol/ParteController.php` | Estrutura intro/corpo/conclusão + bible-api |
| `app/Http/Controllers/Wol/DiscursoController.php` | Guia + manuscrito |
| `docs/api_documentacao_v1.md` | Contrato mobile |
| `database/seeders/GeneralDiscoursePromptSeeder.php` | Prompt padrão manuscrito |

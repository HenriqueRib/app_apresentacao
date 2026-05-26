# Prompt mestre — Ensaio be-T (melhorias e evolução)

Use este documento como **prompt único** para agentes de IA ou para planejar sprints no repositório `app_apresentacao`. Cole o bloco **“PROMPT PARA O AGENTE”** no início da conversa.

Documentação de referência obrigatória:

- [ensaio-be-t-funcionalidades.md](./ensaio-be-t-funcionalidades.md) — o que já existe
- [contrato-ensaio-analise-online.md](./contrato-ensaio-analise-online.md) — API opcional
- [contrato-json-backend-flutter.md](./contrato-json-backend-flutter.md) — contrato geral

---

## PROMPT PARA O AGENTE

```
Você é um engenheiro Flutter sênior trabalhando no app Palestrante de Sucesso
(repositório app_apresentacao), módulo Ensaio be-T — tela "Ensaie. Treine. Evolua."

OBJETIVO
Evoluir o Ensaio be-T com foco em: qualidade pedagógica, performance em sessões
longas, UX clara para publicadores do be-T, e integração com o ciclo Planejar →
Preparar → Treinar → Executar do app — sem quebrar o princípio offline-first.

LEIA ANTES DE CODAR
1. doc/mobile/ensaio-be-t-funcionalidades.md
2. Os arquivos que você for tocar (provider, engine, layouts)
3. Testes existentes em test/voice_*

PRINCÍPIOS INEGOCIÁVEIS
- Offline-first: treino, métricas, histórico, relatório e S-315 heurístico SEM internet.
- Análise online: só manual, no histórico, se o usuário ativou a preferência.
- Escopo vocal: ritmo, muletas, volume, modulação, repetição, estrutura temporal.
- NÃO julgar doutrina, gestos, contato visual, uso da Bíblia (isso é Autoavaliação be-T).
- Modo inteligente: novos comportamentos como FLAGS opt-in (VoiceRehearsalSmartFlags).
- Respostas e UI em português (Brasil).
- Diff mínimo: reutilizar VoiceRehearsalProvider, StorageService, padrões do projeto.
- Não criar commits/PRs sem pedido explícito do usuário.

ARQUITETURA ATUAL (resumo)
VoiceRehearsalScreen
  → VoiceRehearsalProvider (metricsListenable + contentListenable, debounce)
  → VoiceAnalysisEngine + VoiceCoachingBuilder + VoiceSpeechStructureAnalyzer
  → Layouts: VoiceRehearsalLiveMinimalLayout | VoiceRehearsalLiveVisualLayout
  → Modo inteligente: VoiceRehearsalSmartFlags + fases (countdown, warmup, recording)
  → Persistência: SharedPreferences via StorageService
  → Histórico: VoiceRehearsalAttempt (seriesName, linkedSpeechId, summary JSON)

ARQUIVOS-CHAVE
- lib/screens/tools/bet_guide/voice_rehearsal_screen.dart
- lib/providers/voice_rehearsal_provider.dart
- lib/services/voice_analysis_engine.dart
- lib/services/voice_coaching_builder.dart
- lib/models/voice_rehearsal_smart_flags.dart
- lib/widgets/voice_rehearsal_live/* (cockpit, layouts, context)
- lib/widgets/voice_rehearsal_prepare_card.dart
- lib/widgets/voice_rehearsal_smart_flags_panel.dart
- doc/mobile/ensaio-be-t-funcionalidades.md

BUGS / ARMADILHAS JÁ CONHECIDAS (não reintroduzir)
- LinearProgressIndicator com value: null = animação "carregando" eterna → usar 0.0.
- Cockpit não deve aparecer no idle (só durante gravação).
- Idle: card Preparar ensaio deve estar em SingleChildScrollView (não Column fixa).
- iOS modo Gravar: não usar STT + gravador em paralelo; transcrição pós-arquivo.
- Dois AudioRecorder (Ensaio + Teste volume): evitar conflito se ambos abertos.

QUANDO IMPLEMENTAR
1. Descreva em 2–3 frases o que vai fazer e por quê.
2. Implemente com testes unitários se tocar engine, filtros, export, teleprompter builder.
3. Rode flutter analyze nos arquivos alterados.
4. Atualize ensaio-be-t-funcionalidades.md se mudar comportamento visível.

TAREFA ATUAL DO USUÁRIO
[O usuário preenche aqui, ex.: "Implementar comparativo de 3 ensaios" ou "Refinar teleprompter"]
```

---

## 1. Estado atual (baseline — o que já está pronto)

### Produto
- Coach vocal ao vivo: nota 0–10, WPM, muletas, pausas, volume, modulação, repetição.
- Modos **Treino** (STT) e **Gravar** (.m4a).
- Layout **minimalista** e **dinâmico** (abas Métricas | Dicas | Transcrição).
- Cockpit fixo, pills be-T, foco sticky, modo foco (gauge).
- Card **Preparar ensaio**: meta de tempo, modo foco, tema, recorde.
- **Modo inteligente** (10 flags opt-in): countdown, aquecimento, marcos, haptic, pausa inteligente, carry-over, filtro coach, coach mínimo, listen-back, meta semanal.
- Vincular **Speech** + teleprompter leve por blocos do esboço.
- **Série/pasta** no histórico + filtro por chips.
- **Comparar 2 ensaios** lado a lado.
- **Exportar** relatório em texto (share_plus).
- Histórico, gravações, relatório minimal/visual, S-315 heurístico, análise online manual.
- Checkpoint, pausa/retomar, wake lock, comparativo vs recorde/último.
- Home: card meta semanal + ciclo Treinar → Ensaio be-T ou Módulo treino.

### Técnico
- `metricsListenable` / `contentListenable` para rebuild seletivo.
- Throttle de insights (~2,5 s) e volume (a cada 3 amostras).
- Checkpoint em `compute`, máx. 15 eventos.
- Testes: engine, coaching, muletas, estrutura, S-315, payload online, smart flags, coach filter, teleprompter builder, export.

---

## 2. Margem de melhoria — por prioridade

### P0 — Correções e polish (baixo risco, alto impacto)

| Item | Descrição | Onde |
|------|-----------|------|
| Recalibrar volume ao voltar do teste | `hasVolumeCalibration` só atualiza no `initialize`; ao voltar do VoiceVolumeTestScreen, refrescar provider | `voice_rehearsal_provider.dart`, `voice_rehearsal_screen.dart` |
| Calibração presa em "Calibrando" | Timeout + garantir `_finishCalibration` se usuário sair da tela; liberar gravador | `voice_volume_test_provider.dart` |
| Focus layout em aquecimento | Gauge deve respeitar `hideScore` / nota `—` no warmup | `voice_rehearsal_focus_layout.dart` |
| Presets modo inteligente | Chips "Iniciante" / "Completo" que ligam conjuntos de flags | `voice_rehearsal_smart_flags_panel.dart` |
| Acessibilidade | Semantics em cockpit, botões Treino/Gravar, banners | widgets ao vivo |
| Erro STT mais acionável | Card com link para configurações se permissão negada | `voice_rehearsal_screen.dart` |

### P1 — UX e fluxo (médio esforço)

| Item | Descrição |
|------|-----------|
| **Teleprompter avançado** | Rolagem automática lenta por bloco; destaque do bloco atual por tempo ou marcador manual |
| **Cobertura do esboço** | % de palavras-chave do outline mencionadas na transcrição (heurística local) |
| **Treino por bloco** | Ensaiar só introdução / um ponto / conclusão (timer + coach filtrado) |
| **"Uma coisa" visível** | Chip carry-over no banner *Foco agora* durante a sessão, não só no prepare |
| **Comparar 3+ ensaios** | Gráfico sparkline ou tabela na mesma tela de comparar |
| **Gráfico por série** | Evolução filtrada por `seriesName` no histórico |
| **Nota do usuário** | Campo texto por tentativa; export inclui nota |
| **PDF do relatório** | Export além de texto (pacote pdf ou printing) |
| **Análise online em lote** | Multi-select no histórico; fila com Wi‑Fi only |
| **Widget / atalho** | Deep link ou home widget "Ensaio 4 min" |
| **Onboarding Ensaio** | Coach marks na primeira visita (3 passos) |

### P1 — Performance

| Item | Descrição |
|------|-----------|
| RepaintBoundary | Gauge, feed items pesados, teleprompter strip |
| Isolar rebuild do feed | Garantir que tick de 1s não reconstrua prepare card |
| Transcrição incremental | Limitar tamanho do painel colapsável (últimos N chars visíveis) |
| Pós-gravação cancelável | Cancelar transcrição se usuário sair da tela |
| Android paridade | Documentar + testar gravar; transcrição pós-arquivo como padrão se STT dual falhar |

### P2 — Produto e integração

| Item | Descrição |
|------|-----------|
| **Modo Palco ← Ensaio** | Após ensaio forte, sugerir abrir StageMode com mesmo Speech |
| **Autoavaliação pré-preenchida** | Passar `focusCharacteristicId` do carry-over |
| **Partes da reunião** | Vincular `Parte` além de `Speech` |
| **Sincronização backend** | POST histórico quando API existir; conflito last-write-wins |
| **Streak / badges** | Dias seguidos com ensaio ≥ 2 min (local, sem ranking social) |
| **Desafio semanal** | "Reduza muletas 20% vs média da semana passada" |
| **Perfil de microfone** | Lembrar recalibração a cada 30 dias |
| **Modo silencioso coach** | Flag: só cronômetro + nota, zero dicas |
| **Instrutor** | Nota de feedback textual ligada à tentativa (futuro multiusuário) |

### P2 — Coach e métricas (qualidade pedagógica)

| Item | Descrição |
|------|-----------|
| Ajuste WPM por tipo | Parte 4–6 min vs discurso 30 min — metas diferentes na UI |
| Menos falsos positivos muletas | Lista regional; contexto "né" em citação |
| Dicas com trecho clicável | Highlight na transcrição ao tocar na dica |
| Score breakdown ao vivo | Colapsável no feed, não só pós-sessão |
| Estrutura mais cedo | Intro/conclusão detectáveis antes de 80% do tempo |
| Exemplos de áudio | 10 s "bom ritmo" vs "muitas muletas" (assets locais) |

### P3 — Nice to have

| Item | Descrição |
|------|-----------|
| Apple Watch / Wear | Start/stop + tempo (muito esforço) |
| Modo picture-in-picture | Só timer (Android/iOS restrito) |
| STT en-US | Trechos em inglês em discursos |
| Compartilhar áudio + relatório | ZIP ou dois shares |
| Modo escuro refinado | Cockpit e banners com contraste WCAG AA |

---

## 3. Prompts por tema (copiar e colar)

### 3.1 Performance e rebuild

```
No Ensaio be-T (app_apresentacao), audite rebuilds durante sessão de 10+ minutos.
Garanta que: (1) metricsListenable só atualiza cockpit/tempo; (2) contentListenable
não dispara no tick de volume; (3) VoiceCoachingFeed não reconstrói filtros sem mudança.
Adicione RepaintBoundary onde medir jank. Não mude comportamento funcional.
Rode flutter analyze. Atualize doc só se necessário.
```

### 3.2 Teleprompter e esboço

```
Implemente teleprompter melhorado no Ensaio be-T: rolagem manual + botão "próximo bloco"
avança seção do VoiceOutlineTeleprompterBuilder; destaque visual do bloco ativo;
opcional auto-scroll lento (flag em VoiceRehearsalSmartFlags). Mantenha offline-first.
Vincule cobertura heurística: % de títulos/palavras-chave do outline encontrados na
transcrição (exibir no pós-ensaio). Testes para builder e cobertura.
```

### 3.3 Histórico e evolução

```
Estenda o histórico de ensaios: (1) gráfico de evolução por seriesName; (2) comparar
até 4 tentativas em tabela; (3) nota livre do usuário por tentativa (campo + persistência
em VoiceRehearsalAttempt); (4) export PDF opcional além de texto. Siga padrões de
voice_rehearsal_history_screen e compare_screen. Português na UI.
```

### 3.4 Modo inteligente — novas flags

```
Adicione flags ao VoiceRehearsalSmartFlags (opt-in, default false):
- silentCoach: só nota e tempo, sem insights no feed
- blockPractice: ensaio só de um bloco do teleprompter (dropdown no prepare)
- autoScrollTeleprompter: rolagem lenta do bloco ativo
Persistir em StorageService. UI no VoiceRehearsalSmartFlagsPanel agrupada.
Implemente comportamento no provider sem quebrar fluxo countdown→warmup→recording.
```

### 3.5 Integração ciclo do app

```
Integre Ensaio be-T ao ciclo da home: (1) após ensaio com nota ≥ X sugerir Modo Palco
com mesmo Speech; (2) botão no relatório "Abrir esboço" se linkedSpeechId; (3) na
autoavaliação, pré-marcar 2 características mais fracas do último ensaio. Diff focado,
sem refatorar módulos inteiros.
```

### 3.6 Testes e qualidade

```
Aumente cobertura de testes do Ensaio be-T: provider smart tick (milestones, haptic
thresholds mock), voice_coach_focus_filter casos limite, integração export com
transcrição longa. Não adicione testes triviais. Corrija falhas existentes em
flutter test test/voice_*.
```

### 3.7 Bug bash pós-layout

```
Faça bug bash no Ensaio be-T: idle scroll, volume bar, pause/resume, checkpoint,
modo visual abas, gravar+iOS transcrição pós, comparar 2, export share. Corrija
regressões com diff mínimo. Liste o que não corrigiu e por quê.
```

---

## 4. Critérios de aceite (template)

Para qualquer entrega, verificar:

- [ ] Funciona **sem internet** (exceto feature explicitamente online).
- [ ] Flags novas **desligadas por padrão** e persistidas.
- [ ] Idle: scroll no prepare; gravando: feed scroll; sem loading infinito em volume.
- [ ] Treino e Gravar testados no simulador (ou dispositivo) ≥ 2 min.
- [ ] Histórico salva e reabre relatório sem perda de dados.
- [ ] `flutter analyze` sem erros nos arquivos tocados.
- [ ] Testes unitários passam se alterou engine/serviços.
- [ ] Textos UI em português, tom encorajador, não paternalista.
- [ ] Doc `ensaio-be-t-funcionalidades.md` atualizado se mudou comportamento.

---

## 5. O que NÃO pedir ao agente

- Julgar conteúdo bíblico ou sugerir textos doutrinários.
- Análise online automática ao parar o ensaio.
- Ranking público entre usuários.
- Dependência obrigatória de backend para ensaiar.
- Refatoração total do provider sem tarefa explícita.
- Remover modo inteligente ou flags existentes sem migração.
- Commits/push/PR sem pedido do usuário.

---

## 6. Métricas de sucesso (produto)

| Métrica | Como medir (local / analytics futuro) |
|---------|--------------------------------------|
| Ensaios completados/semana | `countVoiceRehearsalAttemptsThisWeek` |
| % com calibração de volume | `hasVolumeCalibration` no primeiro ensaio |
| Uso modo inteligente | Flags true em `voice_rehearsal_smart_flags` |
| Retenção carry-over | Próximo ensaio com mesma characteristicId melhor |
| Tempo médio de sessão | `durationSeconds` no histórico |
| Nota média por série | Agrupar por `seriesName` |

---

## 7. Roadmap sugerido (3 sprints)

### Sprint A — Estabilidade
P0 bugs + recalibrar volume + focus warmup + presets flags + testes provider tick.

### Sprint B — Esboço e evolução
Teleprompter blocos + cobertura outline + gráfico por série + nota usuário + comparar N.

### Sprint C — Ecossistema
Modo Palco + autoavaliação link + PDF export + onboarding + widget atalho.

---

## 8. Link na documentação

Adicione na tabela de `doc/mobile/README.md`:

| [ensaio-be-t-prompt-melhorias.md](./ensaio-be-t-prompt-melhorias.md) | Prompt mestre para evolução do Ensaio be-T |

---

*Documento vivo — atualize quando concluir itens P0/P1 ou mudar arquitetura.*

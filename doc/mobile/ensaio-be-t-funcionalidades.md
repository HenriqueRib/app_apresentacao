# Ensaio be-T — Funcionalidades e recursos

Documento único que descreve **tudo** o que o modo **Ensaio be-T** oferece no app (*Ensaie. Treine. Evolua.*).

**Tela principal:** `lib/screens/tools/bet_guide/voice_rehearsal_screen.dart`  
**Acesso:** Hub de ferramentas → Ensaio be-T (`tools_hub_section.dart`)

---

## 1. Visão geral

O Ensaio be-T é um **coach vocal em tempo real** para quem prepara partes, discursos ou apresentações no contexto do livro *Beneficie-se da Escola do Ministério Teocrático* (be-T). O app escuta o microfone, transcreve em português (quando possível), calcula métricas e devolve **nota ao vivo**, **alertas** e **dicas práticas** enquanto a pessoa fala.

| Princípio | Comportamento |
|-----------|----------------|
| **Offline-first** | Treino, métricas, histórico, relatório e feedback S-315 heurístico funcionam **sem internet**. |
| **Opcional online** | Análise aprofundada via API só se o usuário **ativar** a ajuda online e **solicitar** no histórico. |
| **Escopo vocal** | Avalia entrega **detectável pelo microfone** (ritmo, muletas, volume, modulação, repetição de palavras). |
| **Fora do escopo** | Conteúdo bíblico, gestos, contato visual, uso da Bíblia — use a **Autoavaliação be-T**. |

---

## 2. Tela principal — Ensaio be-T

### 2.1 Cabeçalho (AppBar)

| Elemento | Função |
|----------|--------|
| Título **Ensaio be-T** + subtítulo *Ensaie. Treine. Evolua.* | Identificação |
| Menu **⋮** (idle) | Layout minimalista/dinâmico, ajuda, teste de volume, histórico, gravações |
| **Modo foco** (ao gravar) | Alterna layout concentrado (gauge + dica) |
| **Card Preparar ensaio** (idle) | Meta de tempo, modo foco, calibração, tema e recorde num único painel |

### 2.2 Cockpit ao vivo (minimalista e dinâmico)

Barra fixa no topo **durante** a sessão:

- **Nota** `0–10` em destaque, **tempo** `MM:SS`, chip **vs recorde/último**
- **Meta de tempo** (quando configurada) — barra de progresso
- Chips: **WPM**, **Muletas**, **Palavras**, **Volume**

Ao **encerrar**: cabeçalho *Ensaio encerrado* com nota e comparativo.

### 2.3 Características be-T (pills)

Até **3 pills** coloridas por desempenho; **`+N`** abre lista completa. Enquanto não há dados: *"Características: aguardando análise…"*.

**IDs monitorados (Fase A):** `2, 4, 5, 8, 9, 24, 28, 29` · **Estrutura:** `38, 39, 51`

### 2.4 Layout minimalista (ao vivo)

| Área | Conteúdo |
|------|----------|
| Cockpit + pills | Fixos no topo |
| **Transcrição** | Colapsável (só treino) |
| **Foco agora** | Sticky acima do feed |
| **Feed** | Dicas e alertas |
| **Modo foco** | Gauge central — sem feed |

### 2.5 Layout dinâmico (ao vivo)

Mesmo **cockpit** e **pills**; conteúdo em **abas**:

| Aba | Conteúdo |
|-----|----------|
| **Métricas** | Grid WPM/muletas/pausas/palavras, volume, estrutura, barras be-T |
| **Dicas** | Feed de coaching |
| **Transcrição** | Painel ao vivo (só treino) |

**Foco agora** fica entre as abas e o conteúdo. Pós-ensaio: cabeçalho + feed com resumo (sem abas).

### 2.6 Transcrição e modo Gravar

- **Treino:** STT ao vivo; transcrição colapsável (minimal) ou aba dedicada (dinâmico).
- **Gravar (iOS):** sem STT simultâneo; volume/pausas pelo gravador. Transcrição pós-ensaio em segundo plano se o texto ficar vazio.

### 2.7 Banner “foco agora”

Dica de maior prioridade (`severityRank`). Toque rola o feed até a dica correspondente.

### 2.8 Feed de coaching (`VoiceCoachingFeed`)

| Recurso | Descrição |
|---------|-----------|
| **Filtros** | Todas · Ritmo · Muletas · Volume · Positivos |
| **Dicas** | Mensagem, sugestão, observado/evite/faça assim, exemplos |
| **Rodapé pós-sessão** | Breakdown, palavras repetidas, atalhos Autoavaliação e Histórico |

Nova dica durante o ensaio → feed rola para o topo.

### 2.9 Metas e modo foco (antes do ensaio)

| Recurso | Descrição |
|---------|-----------|
| **Meta de tempo** | Chips: Livre · 4 min · 6 min · 10 min — barra de progresso durante o ensaio |
| **Modo foco** | Esconde feed, características e transcrição; mantém nota, tempo, meta e dica principal |
| **Recorde** | Exibe melhor nota do histórico ao configurar a sessão |

Preferências salvas localmente (`voice_rehearsal_session_prefs`).

### 2.10 Modo inteligente (flags)

Painel **Modo inteligente** no card Preparar ensaio — cada recurso é **opt-in** (desligado por padrão), persistido em `voice_rehearsal_smart_flags`. Chips rápidos: **Iniciante**, **Completo** e **Desligar tudo**.

Durante o ensaio, o chip de **foco carry-over** aparece no banner *Foco agora* (quando há meta salva).

| Flag | Comportamento |
|------|----------------|
| Contagem regressiva | 3…2…1 antes de ligar o microfone |
| Aquecimento | ~45 s com nota oculta (`—`); botão **Começar valendo** |
| Marcos de tempo | Banners: metade da meta, meta atingida, +1 min |
| Sinal discreto | Vibração ao acumular muletas ou WPM fora de 90–170 |
| Pausa inteligente | Sugestão após 3 alertas da mesma característica em 60 s |
| Foco no próximo ensaio | Salva a característica be-T mais fraca ao encerrar |
| Filtrar coach | Chips: Tudo · Muletas · Ritmo · Volume · Modulação · Estrutura |
| Coach mínimo | Só dicas de severidade alta |
| Ouvir últimos 30 s | Pós-gravação (.m4a) |
| Meta semanal na home | Card de progresso (padrão 3 ensaios/semana) |
| Rolagem lenta do roteiro | Teleprompter desliza no bloco ativo durante o ensaio |

**Vincular discurso:** escolhe um `Speech` do planejamento → tema, meta sugerida e **roteiro** (teleprompter com blocos do esboço, bloco ativo, **Próximo bloco**, rolagem lenta opcional). Ao encerrar, **cobertura do esboço** (% palavras-chave citadas) no relatório.

**Série / pasta:** texto opcional salvo no histórico; filtro por chip na lista.

### 2.11 Barra inferior — controles

| Estado | Botões |
|--------|--------|
| **Idle** | **Iniciar treino** · **Gravar** |
| **Gravando** | **Pausar** · **Parar** |
| **Pausado** | **Retomar** · **Encerrar ensaio** |
| **Encerrado** | **Novo ensaio** · **Treino** · **Gravar** (reinicia no modo escolhido) |

Comparativo pós-ensaio: **vs último** e **Novo recorde!** / **vs recorde** (baseline capturada ao iniciar).

**Aviso STT:** se o reconhecimento de voz não estiver disponível, aparece: *"STT indisponível — volume e pausas continuam ativos."*

**Permissão:** sem microfone, a tela mostra card pedindo ativação nas configurações do dispositivo.

### 2.12 Integração com o ciclo do app

| Recurso | Comportamento |
|---------|----------------|
| Onboarding Ensaio | Diálogo de 3 passos na primeira visita (persistido) |
| Atalho 4 min | Card meta semanal na home → **Ensaio 4 min** |
| Pós-ensaio forte | Nota ≥ 7,0 + discurso vinculado → sugere **Modo Palco** |
| Abrir esboço | Pós-ensaio e relatório do histórico (`linkedSpeechId`) |
| Autoavaliação | Pré-marca 2 características mais fracas do ensaio |
| Export PDF | Histórico → relatório → ícone PDF (além de texto) |

---

## 3. Dois modos de sessão

### 3.1 Iniciar treino (`VoiceSessionMode.training`)

- Microfone + **speech-to-text** (pt_BR, ditado, resultados parciais)
- Nível de som do STT alimenta métricas de **volume** e **modulação**
- **Não** grava arquivo de áudio
- Transcrição ao vivo visível na tela
- STT reinicia automaticamente se o sistema interromper a escuta (sessões longas)

### 3.2 Gravar ensaio (`VoiceSessionMode.recording`)

- Igual ao treino para feedback e métricas, **mais** gravação **AAC `.m4a`** em `Documents/ensaio_bet/`
- Volume via **amplitude do gravador** (não STT paralelo)
- Ao parar: salva no **histórico** e na lista **Gravações**
- Se transcrição vazia: **transcrição offline em background** do arquivo e atualização do relatório

---

## 4. O que o motor analisa (local)

Motor: `VoiceAnalysisEngine` + `VoiceCoachingBuilder` + `VoiceSpeechStructureAnalyzer`.

### 4.1 Métricas

| Métrica | Significado |
|---------|-------------|
| **WPM** | Palavras ÷ minutos. Faixa confortável configurada: **90–170** WPM |
| **Muletas** | Contagem de termos da lista padrão + personalizados |
| **Pausas longas** | Silêncio prolongado (≥ ~4 s); alerta se muitas por minuto |
| **Volume médio (dB)** | Com calibração opcional do usuário |
| **Variância de amplitude** | Proxy de **modulação** da voz |
| **Palavras vagas** | *coisa, negócio, tal…* (diferente de muleta) |
| **Repetição de palavras** | Mesma palavra muitas vezes (exceto stopwords) |
| **Nota 0–10** | Score composto suavizado; breakdown no resumo |

### 4.2 Categorias de dicas (`VoiceImprovementInsight`)

| Categoria | Exemplos de detecção |
|-----------|-------------------|
| `repeticao` | Palavra repetida acima de limiar |
| `muleta` | *é, então, tipo, né, hum…* (+ customizadas) |
| `vaga` | Termos imprecisos |
| `ritmo` | WPM baixo/alto |
| `pausas` | Pausas longas ou bônus por pausa estratégica |
| `volume` | Muito baixo/alto |
| `modulacao` | Voz monótona (baixa variância) |
| Estrutura | Introdução, conclusão, tempo (características 38, 39, 51) |

Cada dica pode trazer: `observed`, `avoid`, `tryInstead`, `beforeExample`, `afterExample`, link para **characteristicId** be-T.

### 4.3 Muletas padrão

`é, então, tipo, né, aí, hum, ah, hm, hmm, enfim` — editáveis em **Muletas personalizadas**.

### 4.4 Debounce e limites

- Alertas da mesma característica: intervalo mínimo (~20 s)
- Análise de WPM/repetição: mínimo de palavras/tempo antes de penalizar
- Feed de eventos ao vivo: mantém até **20** alertas recentes

---

## 5. Durante a sessão — comportamentos especiais

| Recurso | Detalhe |
|---------|---------|
| **Wake lock** | Tela não apaga enquanto ensaia |
| **Checkpoint** | A cada 30 s (máx. 15 eventos); também ao ir para background |
| **Retomar ensaio** | Ao reabrir a tela, diálogo *Continuar* / *Descartar* |
| **Performance** | STT pesado ~2,5 s; volume a cada 3 amostras; `metricsListenable` / `contentListenable` (feed não reconstrói a cada segundo); checkpoint em `compute` |
| **Pré-voo** | Lembrete de calibração de volume e meta de tempo antes de iniciar |
| **Ao vivo** | Comparativo com recorde (`↑ recorde`, `p/ rec`) durante o ensaio |
| **Transcrição** | Banner com mensagem ao processar gravação pós-ensaio |
| **Descartar checkpoint** | Confirmação se o ensaio salvo tiver ≥ 1 min |
| **Progresso** | Barra fina enquanto transcreve gravação em background |

---

## 6. Ao encerrar a sessão

1. Gera `VoiceRehearsalSummary` (métricas, eventos, scores por característica, insights, breakdown, transcrição formatada, estrutura do discurso em JSON).
2. **Persiste tentativa** no histórico local (`VoiceRehearsalAttempt`).
3. Se foi **Gravar**: persiste `VoiceRecording` e, se necessário, agenda transcrição do áudio.
4. Limpa checkpoint e tema da sessão na memória do provider.
5. Na UI: feed mostra **resumo da sessão** + comparativo com ensaio anterior.

---

## 7. Telas e fluxos auxiliares

### 7.1 Como funciona (`voice_rehearsal_help_screen.dart`)

Guia in-app:

- Funcionamento offline vs ajuda online
- Toggle **Ajuda online** (mesmo componente em outras telas)
- Seções: muletas, palavras, ritmo/WPM, nota, volume, “o que melhorar agora”, palavras vagas, treino × gravar
- Atalhos: personalizar muletas, teste de volume
- Nota pedagógica: referência be-T; gestos/Bíblia → autoavaliação

### 7.2 Teste de volume (`voice_volume_test_screen.dart`)

- Escuta microfone e mostra zona (baixo / ideal / alto)
- **Calibrar** perfil de volume do usuário (persistido)
- **Recalibrar** quando já existe calibração
- Ao sair da tela durante calibração/escuta, o gravador é liberado; timeout de segurança evita ficar em “Calibrando”
- Ao voltar ao Ensaio, `refreshVolumeCalibration()` atualiza o estado sem reiniciar a tela
- A calibração ajusta os dB usados em todo o Ensaio (`applyCalibration`)

### 7.3 Muletas personalizadas (`voice_filler_settings_screen.dart`)

- Lista de palavras/sons extras além do padrão
- Adicionar / remover
- Toggle de ajuda online (acesso rápido à preferência)

### 7.4 Histórico de ensaios (`voice_rehearsal_history_screen.dart`)

| Recurso | Descrição |
|---------|-----------|
| **Gráfico de evolução** | Notas ao longo das tentativas |
| **Lista** | Título (tema ou preview da transcrição), data, modo, duração, nota |
| **Abrir relatório** | Detalhe completo |
| **Excluir** | Swipe ou ícone, com confirmação |
| **Comparar** | Ícone `compare_arrows`: seleciona **2–4** ensaios → tabela (nota, WPM, muletas, pausas, duração, cobertura do esboço) |
| **Evolução por série** | Gráfico filtra pelo chip de série; título mostra nome da série |
| **Nota do usuário** | Campo livre no detalhe do ensaio; incluído na exportação |
| **Série** | Filtro por pasta/série; campo definido no preparar ensaio |
| **Exportar** | Ícone compartilhar no relatório → texto (Share) |
| **Reproduzir áudio** | Se a tentativa veio do modo Gravar e o arquivo existe |

### 7.5 Relatório do ensaio (`voice_rehearsal_history_detail_screen.dart`)

Dois modos de visualização (preferência salva):

| Modo | Conteúdo |
|------|----------|
| **Minimalista** | Abas: Resumo · be-T · S-315 · Mais |
| **Dinâmico e visual** | Hero com nota, grid de métricas, barras de características, estrutura do discurso, seções expansíveis |

**Em ambos:**

- Nota, duração, modo (treino/gravação), tema
- Detalhamento da nota e dicas
- Características be-T a revisar (cards com link para biblioteca)
- Transcrição (formatada em parágrafos quando disponível)
- **Feedback S-315** heurístico local (`S315SpeakerFeedbackBuilder`) — inspirado no formulário de oradores, **não substitui** avaliação oficial
- Reprodução da gravação vinculada

**Análise online** (se habilitada):

- Botão na AppBar do relatório
- Requisitos: transcrição não vazia e **≥ 20 palavras**
- `POST /v1/ensaio/analisar` — ver [contrato-ensaio-analise-online.md](./contrato-ensaio-analise-online.md)
- Resposta salva em `onlineAnalysis` no histórico local
- Seção dedicada com texto enriquecido e S-315 online quando o backend devolver

### 7.6 Gravações de ensaio (`voice_recordings_screen.dart`)

- Lista áudios com nota, data, duração
- **Play / stop** do arquivo
- **Transcrever e analisar** quando não há transcrição (gera/atualiza `VoiceRehearsalSummary`)
- Expansão com `VoiceRehearsalReportSection` (relatório embutido)
- Exclusão de arquivo + entrada na lista

### 7.7 Integração com Autoavaliação be-T

No resumo pós-sessão e no relatório:

- Botão **Autoavaliação be-T** → `SelfAssessmentScreen`
- Na autoavaliação, se houve foco vocal recente, pode sugerir característica detectada no ensaio

---

## 8. Ajuda online (opcional)

| Item | Comportamento |
|------|----------------|
| **Preferência** | `voice_rehearsal_online_help_enabled` (toggle em Ajuda / Muletas) |
| **Disparo** | Manual, no relatório do histórico — **não** automático ao parar |
| **Offline** | Falha de rede não impede ensaio nem relatório local |
| **Contrato API** | [contrato-ensaio-analise-online.md](./contrato-ensaio-analise-online.md) |

Payload enviado inclui: transcrição, métricas locais, estrutura, características be-T, insights, S-315 local, tema, modo, duração.

---

## 9. Persistência local (sem backend obrigatório)

| Chave / dado | Conteúdo |
|--------------|----------|
| `voice_rehearsal_history` | Lista de `VoiceRehearsalAttempt` (summary JSON completo) |
| Gravações | Metadados + caminho do `.m4a` |
| `voice_rehearsal_online_help_enabled` | Boolean |
| `voice_rehearsal_report_view_mode` | `minimal` ou `visual` |
| `voice_rehearsal_session_prefs` | Meta de tempo, modo foco |
| `voice_rehearsal_smart_flags` | Modo inteligente (flags) |
| `voice_rehearsal_next_focus` | Carry-over de característica |
| `voice_rehearsal_weekly_goal` | Meta semanal |
| `voice_rehearsal_linked_speech_id` | Discurso vinculado |
| Calibração de volume | Perfil `VoiceVolumeCalibration` |
| Muletas customizadas | Lista de strings |
| Checkpoint | Arquivo temporário da sessão em andamento |

---

## 10. Arquitetura resumida (para devs)

```
VoiceRehearsalScreen
  └── VoiceRehearsalProvider
        ├── SpeechToText (treino) / AudioRecorder (gravar)
        ├── VoiceAnalysisEngine (métricas + eventos)
        ├── VoiceCoachingBuilder (insights)
        ├── VoiceSpeechStructureAnalyzer (estrutura)
        ├── VoiceSessionCheckpoint (retomada)
        ├── StorageService (histórico, prefs)
        └── VoiceRecordingTranscriber (pós-gravação)
```

**Testes unitários** (pasta `test/`): engine, coaching, muletas, estrutura, S-315 builder, payload online, formatação de transcrição, etc.

---

## 11. O que o Ensaio **não** faz

- Não substitui avaliador humano nem formulário S-315 oficial
- Não julga doutrina, textos bíblicos citados ou postura corporal
- Não sincroniza histórico com servidor por padrão (v1 é local)
- Não inicia análise online sozinho ao terminar o ensaio

---

## 12. Documentos relacionados

| Arquivo | Uso |
|---------|-----|
| [contrato-ensaio-analise-online.md](./contrato-ensaio-analise-online.md) | API `POST /v1/ensaio/analisar` |
| [contrato-json-backend-flutter.md](./contrato-json-backend-flutter.md) | Contrato geral (seção Ensaio) |

---

*Última revisão alinhada ao código Flutter do repositório `app_apresentacao`.*

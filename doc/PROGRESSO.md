# Progresso do Desenvolvimento - Poder de Convencer

**Última atualização:** 23/03/2026

## Visão Geral

Aplicativo Flutter "Poder de Convencer" que integra:
- **Método Shinyashiki**: Ciclo de 5 passos (Planejar, Preparar, Treinar, Executar, Aprimorar)
- **53 Características de Oratória**: Do livro "Beneficie-se da Escola do Ministério Teocrático" (be-T)
- **Método L.E.I.A.**: Leia, Explique, Ilustre, Aplique

---

## Status de Desenvolvimento

### Legenda
- [x] Concluído
- [ ] Pendente
- [~] Em progresso

---

## 1. Estrutura Base e Dados

| Item | Status | Descrição |
|------|--------|-----------|
| Projeto Flutter | [x] | Configurado com Material Design 3 |
| JSON das 53 Características | [x] | Arquivo `assets/data/caracteristicas_oratoria.json` |
| Categorias de Características | [x] | 5 categorias principais |
| Competências de Avaliação | [x] | 5 competências com pesos |
| Pilares Shinyashiki | [x] | 3 pilares fundamentais |
| Serviço de Características | [x] | `CharacteristicsService` com busca e filtros |

---

## 2. Modelos de Dados

| Item | Status | Descrição |
|------|--------|-----------|
| Speech | [x] | Modelo principal de discurso |
| SpeechOutline | [x] | Estrutura do esboço |
| MainPoint | [x] | Pontos principais do discurso |
| BiblicalText | [x] | Textos bíblicos com método L.E.I.A. |
| AudienceAnalysis | [x] | Análise da assistência |
| TrainingProgress | [x] | Progresso de treinamento |
| ExecutionRecord | [x] | Registro de execução |
| FeedbackRecord | [x] | Registro de feedback |
| OratoryCharacteristic | [x] | Característica de oratória |

---

## 3. Módulo 1: PLANEJAR

| Item | Status | Descrição |
|------|--------|-----------|
| Tela de planejamento | [x] | Wizard de 4-5 passos |
| Seleção de tipo (10/30 min) | [x] | Designação estudante ou público |
| Seleção de objetivo | [x] | Pessoal ou ajudar próximo |
| Definição do objetivo central | [x] | Campo obrigatório |
| Análise da assistência | [x] | 4 campos de análise |
| Seleção de característica foco | [x] | Para discursos de 10 min |
| Validação obrigatória | [x] | Impede avançar sem objetivo |

---

## 4. Módulo 2: PREPARAR (Esboço)

| Item | Status | Descrição |
|------|--------|-----------|
| Editor de esboço | [x] | Interface completa |
| Header com objetivo | [x] | Sempre visível no topo |
| Seção de introdução | [x] | Com dicas e tempo estimado |
| Pontos principais | [x] | Limite baseado no tipo (3 ou 5) |
| Drag & drop de pontos | [x] | Reordenação de pontos |
| Seção de conclusão | [x] | Com dicas e tempo estimado |
| Textos bíblicos L.E.I.A. | [x] | Ler, Explicar, Ilustrar, Aplicar |
| Validação de L.E.I.A. | [x] | Indicador de completude |
| Indicador de progresso | [x] | Barra de progresso visual |
| Ilustrações por ponto | [x] | Campo para ilustrações |

---

## 5. Módulo 3: TREINAR

| Item | Status | Descrição |
|------|--------|-----------|
| Tela de treinamento | [x] | 3 abas |
| Timer de ensaio | [x] | Circular com progresso |
| Indicador de overtime | [x] | Alerta visual |
| Nível de energia | [x] | Slider 1-5 |
| Checklist de palco | [x] | 5 itens verificáveis |
| Indicador de prontidão | [x] | Progresso do checklist |
| Características em foco | [x] | Card destacado |
| Características recomendadas | [x] | Lista expansível |
| Salvar sessão | [~] | UI pronta, persistência parcial |
| Marcar como pronto | [x] | Botão funcional |

---

## 6. Módulo 4: EXECUTAR (Modo Palco)

| Item | Status | Descrição |
|------|--------|-----------|
| Interface zero distração | [x] | Fundo escuro, tela cheia |
| Header com objetivo | [x] | Sempre visível |
| Temporizador grande | [x] | Com semáforo de cores |
| Regra dos 3 minutos | [x] | Alerta "Largada Forte" |
| Alertas de conclusão | [x] | Amarelo/Vermelho conforme tempo |
| Teleprompter | [x] | Cards por seção |
| Navegação por swipe | [x] | Próximo/anterior |
| Cues de performance | [x] | Alertas de características |
| Indicador de pausa | [x] | Silêncio estratégico |
| Ajuda de característica | [x] | Dialog com ação |
| Ilustrações no card | [x] | Seção destacada |

---

## 7. Módulo 5: APRIMORAR

| Item | Status | Descrição |
|------|--------|-----------|
| Dashboard de progresso | [x] | Visão geral |
| Métricas totais | [x] | Discursos, executados, taxa |
| Competências de avaliação | [x] | 5 competências com pesos |
| Lista de executados | [x] | Cards de discursos |
| Formulário de feedback | [x] | Bottom sheet completo |
| Objetivo alcançado | [x] | Switch sim/não |
| Engajamento da audiência | [x] | Slider 1-5 |
| Pontos fortes | [x] | Campo de texto |
| Pontos a melhorar | [x] | Campo de texto |
| Lições aprendidas | [x] | Campo de texto |

---

## 8. Biblioteca de 53 Características

| Item | Status | Descrição |
|------|--------|-----------|
| Tela de biblioteca | [x] | Lista completa |
| Busca por texto | [x] | Título, categoria, ação |
| Filtro por categoria | [x] | Chips horizontais |
| Card expansível | [x] | Ação + Importância |
| Referência de página | [x] | Indicador visual |
| Contador de resultados | [x] | Exibe total |

---

## 9. Infraestrutura

| Item | Status | Descrição |
|------|--------|-----------|
| StorageService | [x] | SharedPreferences |
| CharacteristicsService | [x] | Carrega JSON |
| SpeechProvider | [x] | Gerenciamento de estado |
| Onboarding atualizado | [x] | 4 telas novas |
| Tema do app | [x] | AppTheme |

---

## Arquivos Principais

```
lib/
├── main.dart
├── core/
│   ├── theme/app_theme.dart
│   └── constants/app_constants.dart
├── models/
│   ├── speech.dart              # Novo modelo principal
│   ├── oratory_characteristic.dart
│   ├── presentation.dart        # Legado
│   └── creative_resource.dart   # Legado
├── services/
│   ├── storage_service.dart
│   └── characteristics_service.dart  # Novo
├── providers/
│   ├── speech_provider.dart     # Novo
│   ├── presentation_provider.dart
│   └── resource_provider.dart
└── screens/
    ├── home_screen_new.dart     # Nova home
    ├── onboarding/
    ├── planning/
    │   └── speech_planning_screen.dart
    ├── preparation/
    │   └── outline_editor_screen.dart
    ├── training/
    │   └── training_module_screen.dart
    ├── execution/
    │   └── stage_mode_new_screen.dart
    ├── dashboard/
    │   └── improvement_dashboard_screen.dart
    └── characteristics/
        └── characteristics_library_screen.dart

assets/
└── data/
    └── caracteristicas_oratoria.json  # 53 características
```

---

## JSON das 53 Características

O arquivo `assets/data/caracteristicas_oratoria.json` contém:

- **metadata**: Versão do livro, idioma
- **categories**: 5 categorias de agrupamento
- **characteristics**: 53 características completas com:
  - id, title, page_reference, category
  - action (o que fazer)
  - importance (por que é importante)
- **competencies_feedback**: 5 competências de avaliação
- **shinyashiki_pillars**: 3 pilares do método

---

## Como Executar

```bash
# Instalar dependências
flutter pub get

# Rodar em modo debug
flutter run

# Build para Android
flutter build apk

# Build para iOS
flutter build ios
```

---

## Próximos Passos (Backlog)

| Item | Prioridade | Descrição |
|------|------------|-----------|
| Integração com API Laravel | Alta | Backend para IA |
| Geração de esboço manuscrito | Alta | IA para converter esboço |
| Gravação de vídeo de ensaio | Média | Análise de performance |
| Notificações de follow-up | Média | Lembretes |
| Sincronização em nuvem | Média | Firebase |
| Análise de voz | Baixa | Detecção de "Problema? Oba!" |
| OCR de esboços manuais | Baixa | Digitalização |

---

## Progresso Geral

| Módulo | Completude |
|--------|------------|
| Estrutura Base | 100% |
| Dados (JSON 53 chars) | 100% |
| Planejar | 100% |
| Preparar (Esboço) | 95% |
| Treinar | 90% |
| Executar (Modo Palco) | 95% |
| Aprimorar | 90% |
| Biblioteca 53 Chars | 100% |

**Progresso Geral: ~95%**

O aplicativo está **usável** para o fluxo completo:
1. Criar discurso com planejamento
2. Preparar esboço com método L.E.I.A.
3. Treinar com timer e checklist
4. Executar no Modo Palco
5. Registrar feedback e aprimorar

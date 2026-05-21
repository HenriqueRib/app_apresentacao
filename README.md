# 🎤 Palestrante de Sucesso

> **"Transforme seu mindset, conquiste sua audiência."**  
> Um ecossistema completo para capacitar oradores na "missão de gigante": converter oratória em conversão, comunicação em missão e apresentações em transformações reais de vida.

---

## 🛠 1. Arquitetura e Metodologia

O projeto **Palestrante de Sucesso** foi projetado seguindo as melhores práticas de engenharia de software para o ecossistema Flutter. Utilizamos uma arquitetura baseada em **Camadas (Layer-First)** altamente modular e desacoplada, focada em testabilidade, facilidade de manutenção e princípios **SOLID**.

### Padrões Técnicos e de Design
* **Gerenciamento de Estado**: [Provider](https://pub.dev/packages/provider) (Adoção de `ChangeNotifierProvider` e `MultiProvider` para garantir fluxos reativos e controle de estados eficientes e seguros).
* **Camada de Serviço (Service Layer)**: Serviços singleton bem definidos que isolam a lógica de negócio (ex: persistência com `StorageService`, comunicação externa com `ApiService` e carregamento de dados estáticos com `CharacteristicsService`).
* **State & Dependency Injection**: Centralizado no ponto de entrada do app (`main.dart`) por meio do `MultiProvider`, disponibilizando estados desacoplados para a árvore de widgets sem acoplamento direto.
* **Modelo Orientado a Domínio**: Modelos de dados imutáveis decorados com `@immutable` e equipados com cópias defensivas (`copyWith`) e serializadores (`fromJson`/`toJson`).

---

## 🧰 Ferramentas (Expansão 2026)

Na aba **Início**, a seção **Ferramentas** agrega módulos aditivos sem alterar o ciclo de discursos:

| Ferramenta | Descrição |
|------------|-----------|
| Central da Reunião | Abas: comentários (favoritos/notas) + respostas IA (adicionar, listar, melhorar) |
| A Sentinela | Estudos: adicionar, listar, gerar/melhorar comentários, settings IA |
| Discursos | CRUD: adicionar, editar, excluir, gerar/melhorar manuscrito e guia |
| Partes 10 min | CRUD + gerar/melhorar esboço + apresentar com timer |
| Timer Pro | Cronômetro fullscreen com split (1+7+2) e bordas verde/amarelo/vermelho |
| Meu Estúdio | Tópicos curtos independentes + flashcards + refinar com IA |
| Autoavaliação be-T | Checklist das 53 características com histórico |
| Masterclass Shinyashiki | 5 passos pedagógicos + Treinador de Voz (gravação) |

Ver [doc/mobile/](doc/mobile/) para contratos de API.

---

## 📁 2. Estrutura do Projeto

A organização de diretórios reflete a separação clara de responsabilidades:

```text
lib/
├── core/
│   ├── constants/         # Valores globais de layout, chaves de API e strings estáticas (app_constants.dart)
│   └── theme/             # Design System contendo lightTheme e darkTheme (app_theme.dart)
├── models/                # Entidades de domínio imutáveis e enums estruturados (Speech, Presentation, etc.)
├── providers/             # Gerenciadores de estado reativos / ViewModels (SpeechProvider, ResourceProvider, etc.)
├── screens/               # Interfaces visuais organizadas por passos e contextos da jornada do usuário
│   ├── characteristics/   # Biblioteca de competências oratórias para aprimoramento contínuo
│   ├── dashboard/         # Visualizações de progresso, relatórios de ensaios e feedbacks sinceros
│   ├── execution/         # Interfaces de performance ao vivo, como o Modo Palco (stage_mode)
│   ├── onboarding/        # Fluxo interativo de boas-vindas do aplicativo
│   ├── planning/          # Assistente (wizard) e criação de objetivos de discursos
│   ├── preparation/       # Editor de esboços estruturados e arquitetura da mensagem
│   ├── resources/         # Repositório criativo de piadas, vídeos, histórias e anedotas
│   └── training/          # Temporizador de ensaio, controle de energia e simuladores
│   └── tools/             # Ferramentas aditivas (reunião, timer pro, estúdio, masterclass)
└── services/              # Abstrações de E/S, comunicação HTTP e persistência local persistente
```

---

## 🔧 3. Tecnologias Utilizadas

* **Flutter SDK**: Framework multiplataforma de alta performance para UI nativa.
* **Dart**: Linguagem base tipada, performática e moderna.
* **Provider (v6.1.2)**: Solução estável e oficial para gerenciamento de estado e injeção de dependência.
* **Shared Preferences (v2.3.5)**: Motor de persistência de chave-valor local usado com mapeamento JSON robusto.
* **Http (v1.6.0)**: Cliente HTTP para consumir serviços de IA e sincronização no backend.
* **Uuid (v4.5.1)**: Geração de identificadores exclusivos para entidades locais.
* **Cupertino Icons (v1.0.8)**: Assets visuais nativos.

---

## 🎯 4. Status das Funcionalidades

### **Passo 1: Planejar (Planning Wizard)** ✅
- [x] **Setup Wizard**: Formulário sequencial obrigando a definição clara do KPI de sucesso e tipo de discursos (Estudante 10 min vs Público 30 min).
- [x] **Tipos de Workflow**: Controle e validação de "Objetivo Próprio" (vendas, patrocínio) e "Objetivo do Cliente" (dores e soluções).
- [x] **Quick Pitch**: Suporte para microapresentações dinâmicas de 5 minutos baseadas nos ensinamentos de Nuno Cobra.

### **Passo 2: Preparar (Preparation)** ✅
- [x] **Arquitetura de Mensagem**: Limitação de caracteres em inputs textuais para evitar "gordura textual" e focar na síntese objetiva.
- [x] **Pico de Eureca (Milestone 5)**: Destaque visual na UI focado no elo de conexão entre o problema levantado e a solução oferecida.
- [x] **Editor de Esboço Estruturado**: Edição organizada de introdução, pontos principais, passagens de apoio e conclusão tripartite.

### **Passo 3: Treinar (Training Module)** ✅
- [x] **Simulador de Plateia**: Controle de tempo em ensaios, gravação do progresso de duração e vibrações interativas.
- [x] **Ritual de Concentração**: Guia mental de preparação pré-ensaio para dominar o medo e focar na missão.
- [x] **Checklist de Posse de Palco**: Controle manual de postura, movimentação estratégica, comunicação afetiva e independência de slides.

### **Passo 4: Executar (Stage Mode)** ✅
- [x] **Modo Palco (Zero Distração)**: Interface limpa e em tela cheia otimizada para visualização rápida no palco.
- [x] **Teleprompter Inteligente**: Leitura em tempo real do manuscrito gerado com destaque de ritmo.
- [x] **Contador de Silêncio**: Timer regressivo visual para pausas dramáticas e consolidação de ideias.
- [x] **Urgência da Largada**: Avisos e comandos críticos de tempo focando nos primeiros 3 minutos fundamentais.

### **Passo 5: Aprimorar (Dashboard)** ✅
- [x] **Success Metrics**: Dashboard de acompanhamento registrando dados concretos (negócios fechados, contratos) em detrimento de métricas de vaidade.
- [x] **Feedback Loops**: Cadastro e análise sincera de críticas, lições aprendidas e pontos fortes a desenvolver.
- [x] **Biblioteca de Características**: Biblioteca interativa para estudar técnicas de comunicação de impacto.

---

## 🚀 5. Como Executar

### Pré-requisitos
* Flutter SDK instalado (versão estável mais recente recomendada).
* Emulador ou dispositivo físico conectado (Android, iOS ou Desktop).
* Servidor Backend executando em `http://localhost:8001` (caso queira habilitar a sincronização remota).

### Comandos de Terminal

```bash
# 1. Sincronizar e baixar dependências
flutter pub get

# 2. Limpar cache de compilação antiga
flutter clean

# 3. Executar o app em Modo Debug (Dispositivo padrão)
flutter run

# 4. Executar no Navegador Web (Google Chrome)
flutter run -d chrome

# 5. Executar em Modo Profile (Recomendado para verificar fluidez da UI e frames)
flutter run --profile
```

---

## ⚡ 6. Dependências Principais

* **`provider`**: Lida com a propagação de mudanças reativas da regra de negócio à interface, mantendo a responsabilidade de repintura otimizada.
* **`shared_preferences`**: Central de armazenamento permanente e offline. As entidades complexas são codificadas em strings JSON e salvas de forma segura sob chaves dedicadas.
* **`http`**: Faz solicitações assíncronas ao servidor web local, lidando com timeouts, erros de conexão e tratamento de respostas estruturadas do backend.
* **`uuid`**: Garante que novos esboços e recursos criativos recebam chaves primárias únicas independentes do banco remoto.

---

## 💎 7. Qualidade de Código e Boas Práticas

* **Clean Code**: Nomes de variáveis autoexplicativos, métodos pequenos e focados em responsabilidade única (SRP).
* **Imutabilidade e Segurança**: Entidades de domínio imutáveis que evitam efeitos colaterais na manipulação de estados.
* **Null Safety Estrito**: Sem uso de asserções inseguras, tirando o máximo proveito das garantias do Dart moderno.
* **Separação UI/Regra de Negócios**: Nenhuma lógica de dados é injetada diretamente nos widgets visuais, sendo toda delegada aos herdeiros de `ChangeNotifier` (`SpeechProvider`, etc.).

---

## 🌐 8. Internacionalização

O projeto possui todas as constantes de texto e strings organizadas em `AppConstants` e componentes de apresentação de forma centralizada e padronizada. A estrutura de código foi projetada para receber fácil integração futura de arquivos `.arb` via pacote oficial `flutter_localizations` (`intl`).

---

## 💾 9. Persistência de Dados

A persistência do aplicativo é gerenciada pela classe `StorageService`. Usamos um padrão híbrido de serialização:
1. As entidades do domínio (`Speech`, `Presentation`, `CreativeResource`) contêm métodos `toJson()` e `fromJson()`.
2. O `StorageService` armazena e lê os objetos serializados em listas codificadas como Strings JSON usando `SharedPreferences`.
3. Isso garante o funcionamento offline completo e respostas instantâneas de leitura/gravação sem adicionar dependências nativas pesadas de SQLite ou NoSQL nativos.

---

## 🔌 10. APIs e Integrações

O `ApiService` atua como o cliente para o backend corporativo remoto. As principais integrações configuradas são:
* **Geração de Manuscritos**: Endpoint `/v1/discursos/gerar-manuscrito/total` recebe os dados brutos estruturados e gera textos formatados.
* **Guia e Roteiro de IA**: Endpoint `/v1/discursos/gerar-guia` para processar orientações estruturadas de palco.
* **Histórico Centralizado**: Consumo de listagem centralizada (`/v1/discursos`) e detalhes específicos (`/v1/discursos/{id}`) para sincronia multidevice.
* **Insight da Semana**: Endpoint `/v1/comentarios/semanal` que baixa dados e análises reflexivas do servidor para alimentar a inspiração do palestrante.
* **Refinar Tópico**: Endpoint `/v1/discursos/refinar-texto` para melhorar frases curtas no Estúdio de Esboços.

---

## 🚧 11. Status do Projeto

Atualmente, o projeto encontra-se em **desenvolvimento ativo**, com todos os módulos essenciais da metodologia Shinyashiki totalmente implementados localmente e integrados ao backend REST.

---

## 📚 12. Próximas Melhorias Planejadas

1. **Sincronização Offline First**: Fila de persistência (Outbox) para sincronizar esboços e notas quando a internet voltar.
2. **LEIA via API**: Integrar `POST /discursos/sugerir-versiculos` no Estúdio de Esboços.
3. **Chat IA**: Tela dedicada no hub de Ferramentas.

---
*Palestrante de Sucesso - Transformando tempo em evolução.*  
**Henriqueessafoiboa2025**

# Executar no navegador
flutter run -d chrome

# --profile faz com que o app fique disponível por 7 dias no iphone 
//Elizangela
flutter run --profile -d "00008140-001035D2149B801C"
//Henrique
flutter run --profile -d "00008110-000229413C03A01E"

flutter run                    # dispositivo padrão conectado
flutter run -d chrome          # Web (Google Chrome)
flutter run -d ios             # iOS Simulator (se disponível)
flutter run -d android         # Android Emulator (se disponível)
flutter run -d 824DFB4D-8FCD-4BDF-9807-64671D59DC71
flutter emulators --launch apple_ios_simulato

# Executar com perfil de performance (recomendado para testes de UI fluida)
flutter run --profile

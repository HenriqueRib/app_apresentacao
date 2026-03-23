Especificação de Requisitos de Software (SRS): App TheocratSpeak

1. Visão Geral e Objetivo do Sistema

O App TheocratSpeak é projetado como um ambiente de fluxo de trabalho estruturado para mitigar a carga cognitiva durante a preparação de discursos teocráticos. Seu propósito central é operacionalizar as diretrizes da Escola do Ministério Teocrático (pág. 5), equipando oradores para "apresentar publicamente a esperança bíblica" com convicção e clareza. O sistema não é apenas um editor de texto, mas uma arquitetura de ensino que transforma o "dom divino da fala" em um "sacrifício de louvor" técnico e espiritual (pág. 5).

O sistema é segmentado em três módulos arquitetônicos principais:

* Módulo de Planejamento Estratégico: Preparação do coração e definição de alvos.
* Módulo de Estruturação Lógica: Construtor de esboços hierárquicos e encadeamento de ideias.
* Módulo de Oratória Aprimorada: Interface de performance baseada no currículo de 53 qualidades de ensino.

2. Módulo de Planejamento (Metodologia Shinyashiki)

Este módulo atua como um gate obrigatório. O usuário é impedido de acessar o construtor de esboços sem antes completar a "Preparação Mental". A lógica baseia-se em "preparar o coração" (pág. 14) e "definir o objetivo" (pág. 34) para garantir que a mensagem seja receptiva e motivada.

Lógica de Preparação Mental: O sistema exige a definição de um Input Schema obrigatório:

1. Objetivo Central (String): Um alvo conciso que permanecerá como um "header persistente" no topo da UI durante todo o processo de escrita.
2. Análise da Assistência (JSON Object): Nível de conhecimento prévio (pág. 62), necessidades imediatas e atitude esperada (pág. 66).
3. Transformação Desejada: A ação prática que o ouvinte deve tomar (pág. 34).

3. Construtor de Esboços Teocráticos (Partes de 10 e 30 min)

O sistema deve impor uma estrutura de "esqueleto" (pág. 52), evitando que o orador redija um manuscrito denso que prejudique a naturalidade. A estrutura segue rigorosamente as diretrizes das páginas 39 e 40.

Requisito	Discurso de 10 min (Designação)	Discurso de 30 min (Público)
Pontos Principais	Limite rígido de 2 a 3 pontos.	Limite de 3 a 5 pontos (pág. 40).
Introdução	Despertar interesse imediato (pág. 215).	Estabelecer base argumentativa (pág. 41).
Profundidade	Foco em aplicação direta de 1-2 textos.	Argumentação lógica e refutação (pág. 34).
Timing (Est.)	Intro: 1m; Corpo: 8m; Conclusão: 1m.	Intro: 3m; Corpo: 24m; Conclusão: 3m.

Regras de Negócio:

1. Hierarquia: O sistema deve suportar aninhamento de ideias (Ponto Principal > Argumento > Texto Bíblico).
2. Validação de Volume: Alertas visuais se o número de pontos principais exceder 5 (pág. 40).
3. Coerência: A conclusão deve ser validada contra o "Objetivo Central" definido no Módulo 2.

4. Motor de Regras L.E.I.A. (Leia, Explique, Ilustre, Aplique)

Este é o Motor de Validação para cada texto bíblico inserido. O sistema não permite o fechamento de um bloco de texto sem o preenchimento dos nós terminais.

1. Leia (Input: Referência): Validação de "leitura exata" (pág. 83). O sistema deve puxar o texto da API bíblica.
2. Explique (Input: Texto): Campo obrigatório para esclarecer o sentido, contexto e fundo histórico (pág. 53). O sistema aplica um check de "Contextual Keywords".
3. Ilustre (Input: Texto/Mídia): Requisito de "simplicidade" (pág. 240). O sistema sugere analogias baseadas em situações conhecidas (pág. 244).
4. Aplique (Input: Ação Prática): Este é o Nó Terminal. O sistema emitirá um "Warning" se um texto for lido e explicado, mas não possuir uma aplicação clara que mostre o valor prático (pág. 153, 157).

5. Integração de Inteligência Artificial (API Laravel)

O endpoint Laravel deve receber um payload JSON estruturado (outline_tree, target_audience_id, objective_string) para gerar uma sugestão de manuscrito fluido.

* Prompt Engineering Logic: O sistema deve injetar as variáveis de "Objetivo" (pág. 34) e "Perfil da Assistência" (pág. 62) nas instruções da IA.
* Requisito de Estilo: O retorno deve priorizar o "Estilo Conversante" (pág. 179), distinguindo-o de uma leitura mecânica e visando o "Proferimento Espontâneo" (pág. 174).
* Segurança: Transmissão via HTTPS com autenticação JWT.

6. Banco de Dados Offline: As 53 Características de Oratória

O app deve operar offline-first. O banco JSON contém o sumário completo (págs. 2-3), indexado por categoria para alimentação do "Modo Palco".

Amostra do Formato JSON:

[
  {
    "id": 1,
    "nome_da_qualidade": "Leitura exata",
    "pagina_referencia": 83,
    "categoria": "Leitura Pública"
  },
  {
    "id": 5,
    "nome_da_qualidade": "Uso correto de pausas",
    "pagina_referencia": 97,
    "categoria": "Qualidade da Voz"
  },
  {
    "id": 10,
    "nome_da_qualidade": "Entusiasmo",
    "pagina_referencia": 115,
    "categoria": "Sentimento"
  },
  {
    "id": 28,
    "nome_da_qualidade": "Estilo conversante",
    "pagina_referencia": 179,
    "categoria": "Proferimento"
  },
  {
    "id": 53,
    "nome_da_qualidade": "Encorajar e fortalecer os ouvintes",
    "pagina_referencia": 268,
    "categoria": "Conclusão"
  }
]


7. Interface "Modo Palco" e Teleprompter

A UI de apresentação deve minimizar a carga visual, agindo apenas como suporte para o proferimento espontâneo.

* [ ] Temporizador de Distribuição: Lógica de cores (Verde/Amarelo/Vermelho) baseada na distribuição de tempo por seção (pág. 263).
* [ ] Cues de Performance (Triggered): O usuário pode "taggear" parágrafos do manuscrito com um Quality_ID. O app deve disparar uma notificação discreta 5 segundos antes do texto taggeado atingir a linha de leitura (ex: "ID #10: Use Entusiasmo").
* [ ] Teleprompter Adaptativo: Rolagem automática com controle de velocidade manual via gesto (pág. 174).
* [ ] Segurança de Navegação: Botão de bloqueio de tela para evitar fechamento acidental durante o discurso.

8. Checklist de Prioridades para o Desenvolvedor (Flutter)

1. Sincronização Offline (JSON): Persistência de dados local para uso em locais sem conectividade.
2. Responsividade do Teleprompter: Renderização fluida em tablets e smartphones (Android/iOS).
3. Latência da API Laravel/IA: O processamento do manuscrito não deve exceder 5 segundos de Round Trip Time (RTT).
4. Gestão de Estado do Temporizador: Persistência do cronômetro em caso de interrupções de sistema ou chamadas telefônicas.
5. Navegação Hierárquica: Implementação de ExpansionTile para colapsar/expandir pontos secundários do esboço.
6. UI/UX para Acessibilidade: Suporte a alto contraste e escalonamento dinâmico de fontes para atender a todos os "níveis culturais" e idades (pág. 5).

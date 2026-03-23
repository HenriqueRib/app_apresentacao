Escopo de Projeto: Aplicativo de Oratória "Poder de Convencer"

1. Visão Geral e Objetivos Estratégicos

Este documento define as especificações técnicas e funcionais para o sistema "Poder de Convencer", fundamentado na metodologia de Roberto Shinyashiki. A premissa arquitetural do software baseia-se no princípio de que o sucesso é proporcional ao número de pessoas auxiliadas.

O objetivo central não é a mera sistematização de oratória, mas a criação de uma ferramenta que transforme o orador em um agente de mudança capaz de provocar ação imediata (o efeito "Vamos Lutar!" de Churchill em contraste ao "Ele fala bem" de Demóstenes).

Categorias de Usuários e Missão

1. Palestrantes Profissionais: Focados no "Objetivo Próprio" (venda de produtos, projetos ou ideias).
2. Oradores de Ajuda/Teocráticos: Focados no "Objetivo do Cliente/Próximo" (instrução, espiritualidade e auxílio comunitário).


--------------------------------------------------------------------------------


2. Módulos Funcionais: Integração do Método Shinyashiki

O ecossistema Flutter será dividido em cinco módulos core, traduzindo o método de alto desempenho em fluxos de trabalho lógicos:

2.1 Módulo Planejar (Definição de Meta)

Interface de entrada de dados para estabelecer o "Ponto de Chegada".

* Input Lógico: Seleção entre "Realizar Objetivo Próprio" ou "Ajudar Objetivo do Outro".
* Campo Obrigatório: Identificação do "Produto" (Ideia, Comportamento ou Item Físico).

2.2 Módulo Preparar (Estrutura da Mensagem)

Motor de roteirização que impõe a sequência lógica de 8 passos extraída da fonte:

1. Ideia Central: O núcleo da mensagem.
2. Problema/Oportunidade: O desafio a ser resolvido.
3. Identificação: Técnicas para o público sentir que o orador entende suas dores.
4. Causa: Diagnóstico do problema.
5. Solução: A proposta de valor.
6. Passos da Solução (O Método): Detalhamento técnico do "Como fazer".
7. Motivação para Ação: Gatilhos de superação e autoconfiança.
8. Celebração/Conclusão: Finalização em auge emocional.

2.3 Módulo Treinar (Habilidades de Performance)

* Reconhecimento de Voz "Problema? Oba!": Algoritmo de trigger sonoro que detecta a palavra "problema" e exige uma resposta positiva/entusiasmada do usuário para condicionamento pavloviano.
* Checklist de Posse de Palco: Monitoramento de movimentação e segurança física.
* Vínculo Afetivo: Sugestões de linguagem adequada ao perfil do público.

2.4 Módulo Executar (Modo Palco)

Interface de alta performance otimizada para o momento crítico da apresentação.

2.5 Módulo Aprimorar (Análise de KPIs)

Interface para inserção de feedbacks de grupos de teste e logs pós-palestra. O sistema deve calcular o índice de sucesso baseado no fechamento de negócios e na mudança de comportamento da plateia.


--------------------------------------------------------------------------------


3. Arquitetura de Dados e Motor L.E.I.A.

3.1 Estrutura de Dados (JSON Offline)

O banco de dados local armazenará os fundamentos de credibilidade. Como a fonte não contém dados externos da "Escola do Ministério", os registros iniciais serão povoados com os pilares fundamentais de Shinyashiki:

[
  {
    "ID": "F01",
    "Nome_Caracteristica": "Ética e Integridade",
    "Descricao": "Coerência entre discurso e prática; base para credibilidade duradoura.",
    "KPI_Referencia": "86.2%"
  },
  {
    "ID": "F02",
    "Nome_Caracteristica": "Qualidade Premium",
    "Descricao": "Garantia de que o conteúdo ou produto entregue é superior à concorrência.",
    "KPI_Referencia": "Produto_Premium"
  },
  {
    "ID": "F03",
    "Nome_Caracteristica": "Benefício ao Ouvinte",
    "Descricao": "Foco total nos anseios da plateia e não nos interesses do orador.",
    "KPI_Referencia": "Foco_No_Outro"
  }
]


3.2 Motor de Diretrizes L.E.I.A. (Logic Enhancement Integration Assistant)

O motor lógico filtrará as características de oratória baseando-se em:

* Inputs: Perfil do Público, Objetivo da Venda, Tempo Disponível.
* Output: Sugestão de "Casos Ilustrativos" e "Histórias Tocantes" específicos para o nível de profundidade exigido.


--------------------------------------------------------------------------------


4. Integração Backend Laravel e Inteligência Artificial

4.1 Fluxo de API (Flutter-Laravel)

A comunicação via API REST enviará um payload estruturado para o processamento de IA:

* Endpoint: /api/v1/generate-outline
* Payload: { "script_body": string, "target_audience": string, "visual_style": "handwritten", "duration_seconds": int }

4.2 Geração de Esboços Manuscritos

O backend utilizará modelos de IA para converter o roteiro em um esboço visual que simule escrita manual.

* Justificativa Técnica: A escrita manual evita a rigidez da leitura de slides, promovendo uma "Comunicação Afetiva" e natural no palco.
* Estados do Job: 1. Pending, 2. Processing, 3. Completed.


--------------------------------------------------------------------------------


5. Especificações do Modo Palco (Execução)

5.1 Temporizador Visual e "Regra dos 3 Minutos"

* Largada Forte: O cronômetro exibirá um alerta visual de alta intensidade (Flash Azul/Verde) nos primeiros 180 segundos. Segundo a fonte, os primeiros 3 minutos definem se o orador será "escutado ou aturado".
* Semáforo de Ritmo: Verde (Normal), Amarelo (Conclusão de Tópico), Vermelho (Encerramento Imediato).

5.2 Topic-Based Teleprompter (Anti-Leitura)

A interface proíbe a exibição de parágrafos longos.

* Performance Cues: Cards que disparam lembretes para "Fazer Silêncio Estratégico" (pausa para a ideia ecoar no coração) e "Elevar Energia".
* Conteúdo: Exibição exclusiva de Tópicos, Casos Ilustrativos e Histórias.


--------------------------------------------------------------------------------


6. Configurações e Filtros de Realidade

O sistema permite a personalização do mindset do orador conforme o Capítulo 11 da fonte.

Configuração	Descrição Técnica
Tipo de Meta	Alterna entre "Venda Própria" e "Ajuda ao Cliente".
Filtro de Realidade	Ajuste de mindset pré-palco para converter medo em entusiasmo.
Poder de Síntese	Limitação de caracteres para garantir a objetividade (Regra dos 18 minutos).
Intensidade	Ajuste da frequência de "Cards de Energia" durante a execução.


--------------------------------------------------------------------------------


7. Protocolo de Treinamento e Feedback Competencial

O app implementará uma interface de entrada de feedback para plateias de teste baseada na pesquisa do Wall Street Journal citada na fonte. O orador deve ser avaliado em uma escala de 1 a 5 nas seguintes competências:

1. Comunicação e Relacionamento: (Peso: 89,0%)
2. Trabalho em Equipe: (Peso: 86,9%)
3. Capacidade de Resolver Problemas: (Peso: 84,3%)
4. Ética e Integridade Pessoal: (Peso: 86,2%)
5. Ética Profissional: (Peso: 74,5%)

Relatório de Melhoria: O sistema gerará um gráfico comparativo entre o desempenho treinado e a execução final, transformando críticas em planos de ação para a próxima palestra.

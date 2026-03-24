# Documentação da API para o Aplicativo "Palestrante de Sucesso"

Esta documentação detalha as rotas que o frontend (Flutter) precisa consumir para o pleno funcionamento das novas funcionalidades de Inteligência Artificial.

## URL Base
- **Local:** `http://localhost:8001/api/v1`

---

## 1. Gerar Manuscrito/Esboço Completo

Responsável por receber um texto bruto (ideias, notas, transcrição) e devolver uma estrutura organizada de discurso seguindo o método da aplicação.

### Rota
`POST /discursos/gerar-manuscrito/total`

### Request Body (JSON)
| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `conteudo_bruto` | String | O conteúdo fornecido pelo usuário para ser processado. |

**Exemplo:**
```json
{
  "conteudo_bruto": "Gostaria de falar sobre como a disciplina ajuda a alcançar o sucesso. Disciplina não é punição, é liberdade. Exemplos de atletas. Como começar pequeno. O sucesso vem no longo prazo."
}
```

### Response (JSON)
| Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `titulo` | String | Sugestão de título para o discurso. |
| `objetivo_central` | String | O que o palestrante pretende alcançar. |
| `introducao` | String | Texto da introdução sugerida. |
| `conclusao` | String | Texto da conclusão sugerida. |
| `pontos_principais` | Array | Lista de blocos de conteúdo para o corpo do discurso. |

**Exemplo de Resposta Esperada:**
```json
{
  "titulo": "A Disciplina como Caminho para a Liberdade",
  "objetivo_central": "Inspirar o público a ver a disciplina como uma ferramenta de liberdade e não de restrição.",
  "introducao": "Muitas pessoas acreditam que ser disciplinado é viver em uma prisão de horários e regras. Mas hoje eu quero mostrar que a disciplina é, na verdade, a chave para a sua liberdade.",
  "conclusao": "Comece hoje com um pequeno passo. A liberdade que você tanto deseja está protegida pela disciplina que você ainda não tem. Seja livre, seja disciplinado.",
  "pontos_principais": [
    {
      "titulo": "Disciplina vs Punição",
      "conteudo": "Explicação sobre como a percepção errada de disciplina nos afasta dos nossos objetivos. Disciplina é escolher entre o que você quer agora e o que você mais quer na vida."
    },
    {
      "titulo": "O Mindset de Atleta",
      "conteudo": "Análise de como atletas de alta performance usam a rotina para liberar sua mente para o que realmente importa durante a competição."
    },
    {
      "titulo": "A Lei do Pequeno Começo",
      "conteudo": "Como construir o hábito da disciplina começando com tarefas simples que geram dopamina e sensação de progresso."
    }
  ]
}
```

---

## 2. Sugestão de Versículos (LEIA) - *Opcional/Futuro*

Esta rota poderá ser usada para enriquecer o esboço com referências bíblicas seguindo o método LEIA (Ler, Explicar, Ilustrar, Aplicar).

### Rota
`POST /discursos/sugerir-versiculos`

### Request Body (JSON)
```json
{
  "tema": "Disciplina e Sucesso"
}
```

### Response (JSON)
```json
{
  "versiculos": [
    {
      "referencia": "1 Coríntios 9:24-27",
      "ler": "Não sabeis vós que os que correm no estádio...",
      "explicar": "Paulo compara a vida cristã e o sucesso a uma corrida que exige autodomínio.",
      "ilustrar": "Imagine um maratonista que treina na chuva enquanto outros dormem.",
      "aplicar": "Qual prazer imediato você precisa sacrificar hoje pelo seu alvo maior?"
    }
  ]
}
```

---

## Status de Erro Esperados

- `400 Bad Request`: Quando o corpo da requisição está mal formatado ou faltando campos obrigatórios.
- `500 Internal Server Error`: Erro no processamento do modelo de IA ou falha inesperada no servidor.

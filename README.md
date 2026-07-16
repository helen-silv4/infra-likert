# infra-likert

Infraestrutura como código (Terraform) responsável pelo provisionamento das tabelas DynamoDB (`tb_usuarios` e `tb_avaliacoes`) do projeto Likert. Este repositório concentra os recursos de dados compartilhados, consumidos pelos serviços `bffservice` e `svclikert`.

### 📌 Arquitetura

![Arquitetura Likert](docs/arquitetura.png)

### 🎲 Modelo de dados

#### tb_usuarios

| Atributo | Tipo | Descrição |
|---|---|---|
| `id_usuario` (PK) | string | Identificador técnico/anônimo do usuário (UUID gerado via localStorage, ou repassado pela aplicação host) |
| `datas_resposta_por_fluxo` | map | Registro de quais fluxos esse usuário já respondeu e quando (ex: `{"portfolio": "2026-06-15T22:27:02"}`). Usado para controle de dedupe. |

#### tb_avaliacoes

| Atributo | Tipo | Descrição |
|---|---|---|
| `id_avaliacao` (PK) | string | Identificador único da avaliação |
| `data_hora_avaliacao` | string | Data/hora do envio da avaliação |
| `descricao_fluxo` | string | Identifica o fluxo/campanha ao qual a avaliação pertence |
| `nota_avaliacao` | int | Nota da escala Likert (1 a 5) |
| `descricao_comentario` | string (opcional) | Comentário livre digitado pelo usuário |
| `chips_comentario` | string (opcional) | Chip pré-definido selecionado pelo usuário |

> **Nota:** `tb_avaliacoes` é intencionalmente anônima, não guarda nenhuma referência a `id_usuario`, garantindo que a resposta não possa ser vinculada a quem a enviou.

### 🔄️ Fluxos

Cada fluxo de avaliação (ex: um período de 3 semanas em uma aplicação específica) é configurada manualmente no AWS Parameter Store, sem passar pelo Terraform, isso mantém o cadastro de novos fluxos rápido e independente do ciclo de infraestrutura.

### 💡 Ideias futuras

- **Rastrear visualizações sem resposta**: hoje só sabemos quantas avaliações foram enviadas, não quantas pessoas viram o formulário e não responderam. Registrar isso permitiria calcular taxa de resposta por fluxo. Implicaria criar o registro em `tb_usuarios` no carregamento do widget (não só na resposta), e provavelmente um campo `visualizacoes_por_fluxo` equivalente ao `datas_resposta_por_fluxo`.
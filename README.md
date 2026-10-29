# Entrega 2 — Modelo Lógico, Implementação SQL e Apresentação Final

### Clínica Sued Odontologia Humanizada — sistema de gestão de informações

## 1. Relatório Técnico Final

### Integrantes

| Nome completo do aluno | RGM | Usuário do GitHub |
| :---- | :---- | :---- |
| Letícia Santos da Silva | [COMPLETAR: RGM] | [COMPLETAR: usuário do GitHub] |
| [COMPLETAR: nome completo do integrante 2] | [COMPLETAR: RGM] | [COMPLETAR: usuário do GitHub] |
| [COMPLETAR: nome completo do integrante 3] | [COMPLETAR: RGM] | [COMPLETAR: usuário do GitHub] |
| [COMPLETAR: demais integrantes] | [COMPLETAR: RGM] | [COMPLETAR: usuário do GitHub] |

&nbsp;

### 1.1 Revisão do Modelo Conceitual

#### Caracterização da organização

- **Nome e natureza da organização:** Clínica Sued Odontologia Humanizada, clínica odontológica particular (prestação de serviços de saúde odontológica), com fins lucrativos. A atividade principal é o atendimento clínico odontológico geral, com procedimentos de implantodontia, confecção e entrega de próteses, clareamento e manutenção preventivo-restauradora.
- **Contexto e porte (em números):**
  - cerca de **7 atendimentos por semana**, com capacidade de agenda para expansão;
  - cerca de **300 pacientes** no histórico físico acumulado (fichas em papel);
  - **1 sala de atendimento** com 1 cadeira odontológica (equipo);
  - **1 cirurgiã-dentista**, que também faz a gestão da clínica (não há outros profissionais cadastrados);
  - **6 meses** de funcionamento nas instalações atuais;
  - **7 serviços** no catálogo de procedimentos (limpeza, cirurgia, manutenção, endodontia, implante, prótese e clareamento);
  - **7 categorias** de despesa na planilha de controle (aluguel, luz, impostos, laboratórios, material dental, empréstimos e gastos eventuais);
  - **1 convênio** em implantação.
- **Problemas e necessidades identificados** (detalhados em [`levantamento/levantamento.md`](levantamento/levantamento.md), seção 4):
  - **P1 — Prontuário e histórico clínico apenas em papel:** as fichas de anamnese e de evolução ficam só em papel, o que dificulta consultar o histórico de procedimentos do paciente e deixa a informação de saúde (dado sensível, LGPD) sem restrição de acesso por perfil e sem trilha de auditoria.
  - **P2 — Agendamento manual:** a agenda usa o Google Agenda e o controle manual da dentista, sem validação automática; há risco de agendamento duplo (mesmo dentista, mesma data e hora) e cancelamentos e faltas ficam sem acompanhamento.
  - **P3 — Pagamentos sem registro:** pagamentos parcelados, entradas e saldos pendentes são anotados de modo informal em fichas e cadernos, sem controle de quem deve e quanto.
  - **P4 — Busca lenta de pacientes e do financeiro:** pacientes são identificados só pelo nome em fichas físicas, sem identificador único (homônimos) e com telefones sem padronização.
  - **P5 — Captação de clientes (atendido parcialmente):** a origem do paciente não é registrada. O modelo atende apenas a parte de conversão em tratamento e de pacientes inativos; a origem do paciente está fora do escopo (seção 8, item 5, do levantamento).
  - **P6 — Despesas em planilha separada:** as despesas ficam em planilha simples, sem vínculo com os tratamentos que as originaram (ex.: laboratório de prótese) e sem controle de vencimentos, o que impede apurar o custo direto e a margem por tratamento.
- **Escopo do sistema:** o banco reúne **todos os dados da clínica**, e não só um setor: pacientes, telefones e convênios; dentista e especialidades; agendamentos; planos de tratamento; catálogo de procedimentos e procedimentos realizados; pagamentos; e despesas com suas categorias. São 14 tabelas.
- **Justificativa da escolha:** [COMPLETAR: por que o grupo escolheu esta clínica e por que ela é um bom caso para o projeto]. Fatos já registrados no levantamento: a clínica está em operação, com processos controlados em papel, Google Agenda, cadernos e planilha, e o grupo tem acesso direto à proprietária. **Vínculo declarado:** a integrante **Letícia Santos da Silva** é prima da proprietária, a Dra. Tamires Sued. O vínculo não substitui a entrevista e a observação presencial feitas no ambiente da clínica, descritas abaixo. Nenhum outro integrante declarou vínculo.
- **Evidências da organização:**
  - **Endereço:** Praça Nelson Sales de Abreu, 103 — Sl 04, Cidade Patriarca, São Paulo — SP, CEP 03547-100.
  - **Google Meu Negócio / Google Maps:** a responsável informou que a clínica tem perfil no Google Meu Negócio. A ficha pode ser vista em [Clínica Sued Odontologia Humanizada no Google Maps](https://maps.app.goo.gl/E1UdxAZoc6zMUEYx5).
  - **Contato:** telefone da clínica (11) 95387-7504.
  - **Fotos (arquivos no repositório):**

    ![Foto da visita de campo à Clínica Sued Odontologia Humanizada](imagens/foto_visita.jpeg)

    ![Foto do ambiente da Clínica Sued Odontologia Humanizada](imagens/foto_clinica.jpg)

- **Responsável pela organização:** Dra. Tamires Sued (cirurgiã-dentista, proprietária e gestora), telefone (11) 95387-7504.

#### Relato da entrevista

- **Quem:** entrevistada: Dra. Tamires Sued (cirurgiã-dentista e gestora). Integrantes do grupo presentes: Letícia Santos da Silva e [COMPLETAR: demais integrantes que participaram da entrevista].
- **Quando e onde:** 24 de outubro de 2026, às [COMPLETAR: horário], nas instalações físicas da clínica (Praça Nelson Sales de Abreu, 103 — Sl 04, São Paulo — SP).
- **Comprovação:** fotos em `imagens/foto_visita.jpeg` e `imagens/foto_clinica.jpg`, exibidas na seção anterior.
- **O que foi levantado (resumo).** O texto completo está em [`levantamento/levantamento.md`](levantamento/levantamento.md).
  - **O que a responsável informou (entrevista):**
    - o contato com o paciente ocorre por WhatsApp ou telefone, e o cadastro na recepção exige nome e ao menos um telefone;
    - a agenda é controlada pelo Google Agenda e pelo controle manual da dentista;
    - os pagamentos são feitos em Pix, crédito, débito ou dinheiro, com possibilidade de parcelamento ou pagamento fracionado;
    - recibos e notas são emitidos só quando o paciente pede;
    - as despesas são controladas em planilha, por categoria;
    - o convênio ainda está em implantação;
    - a clínica não controla estoque de materiais, não registra a origem do paciente e não tem integração fiscal.
  - **O que o grupo observou presencialmente (separado do que foi dito):**
    - a confirmação dos pacientes do dia é feita por mensagens de WhatsApp enviadas no balcão de recepção;
    - durante a consulta, a dentista anota os procedimentos em ficha física de evolução, em papel, sobre a mesa do consultório;
    - pacientes em tratamentos continuados de prótese e implante fazem acertos parciais na recepção, e o controle da parte pendente era feito em cadernos, o que confirmou a necessidade do campo `status` (`pendente` ou `pago`) em `pagamento`.
  - **Nova visita e mudanças em relação à Entrega 1:** [COMPLETAR: informar se houve nova visita além da entrevista da Entrega 1 e o que mudou em processos, regras, volumes e problemas].

#### Processos de negócio

Os cinco fluxos principais, com os dados envolvidos (detalhe completo na seção 3 do levantamento):

1. **Recepção e cadastro de pacientes.** Coleta-se em `paciente` o `nome` (obrigatório) e, quando disponíveis, `nome_social`, `cpf`, `data_nascimento` e `info_saude` (anamnese). Cada telefone vai para `telefone` (`numero`). Se o paciente tem convênio, o vínculo é gravado em `paciente_convenio`; sem vínculo, é particular.
2. **Agendamento e controle de consultas.** O `agendamento` registra `id_paciente`, `id_dentista`, `data_hora` e `status` inicial `agendado`, e opcionalmente `id_tratamento` e `observacoes`. Em cancelamento ou falta, o `status` é atualizado e a clínica oferece novo horário.
3. **Atendimento e lançamento de procedimentos.** A dentista realiza o procedimento e anota a evolução na ficha de papel. No banco, grava-se em `procedimento_realizado` o `id_agendamento`, o `id_procedimento`, o `preco_praticado` (que pode diferir do `preco_base`) e as `observacoes`, e o agendamento passa a `realizado`.
4. **Faturamento, pagamento e controle financeiro.** Cada parcela ou valor recebido ou devido gera um registro em `pagamento` com `valor`, `forma_pagamento` (`pix`, `credito`, `debito`, `dinheiro`) e `status` (`pago`, `pendente`).
5. **Gestão de despesas.** Cada gasto é lançado em `despesa` com `id_categoria_despesa`, `valor`, `data_vencimento`, `data_pagamento` (quando paga), `status` (`pendente`, `paga`) e `descricao`. Despesas originadas por um tratamento (como o laboratório de prótese) levam o `id_tratamento`.

**Processos prováveis não incluídos, e por quê:**

| Processo | Motivo |
| :---- | :---- |
| Controle de estoque de materiais e fornecedores | A clínica declarou não controlar estoque; o material é comprado direto e lançado como despesa da categoria `dental`. |
| Cadastro de dentistas parceiros e de funcionários auxiliares | Parceiros são convidados pontualmente e não fazem parte do quadro; o sistema mantém só a dentista titular (RN05). |
| Pré-requisito entre procedimentos (ex.: limpeza antes do clareamento) | Fica a cargo do julgamento clínico e da aplicação, por orientação do professor; não há autorrelacionamento nem tabela de pré-requisito. |
| Emissão de nota fiscal e recibo | A clínica não tem integração fiscal e emite recibo só quando solicitado; não há o que armazenar. |
| Origem do paciente (canal de captação) | A clínica não registra a origem comercial do paciente. |
| Termos de consentimento (cirurgia de implante, uso de imagem, entrega de prótese) | Existem em papel, mas não foram representados nesta versão (ver dicionário de dados, seção 1). |
| Geração de relatórios pela clínica | A clínica não gera relatórios; as consultas gerenciais do script cumprem esse papel. |

#### Requisitos

**Requisitos funcionais** (detalhados na seção 5 do levantamento):

| Código | Requisito |
| :---- | :---- |
| RF01 | Cadastrar e atualizar pacientes (`nome`, `nome_social`, `cpf`, `data_nascimento`, `info_saude`). |
| RF02 | Gerenciar os telefones do paciente (`id_paciente`, `numero`). |
| RF03 | Gerenciar convênios (`nome`) e a associação N:N com pacientes (`paciente_convenio`). |
| RF04 | Cadastrar dentistas (`nome`) e associá-los a uma ou mais especialidades (`dentista_especialidade`). |
| RF05 | Controlar agendamentos (`id_paciente`, `id_dentista`, `data_hora`, `status`, `id_tratamento`, `observacoes`). |
| RF06 | Gerenciar planos de tratamento (`nome`, `data_inicio`, `descricao`, `observacoes`). |
| RF07 | Consultar o catálogo de procedimentos e lançar os realizados (`procedimento_realizado`, com `preco_praticado` e `observacoes`). |
| RF08 | Registrar e dar baixa em pagamentos (`valor`, `forma_pagamento`, `status`). |
| RF09 | Gerenciar categorias e lançamentos de despesas (`id_categoria_despesa`, `valor`, `data_vencimento`, `data_pagamento`, `status`, `descricao`, `id_tratamento`). |
| RF10 | Ocultar `info_saude` de perfis de recepção e financeiro e registrar log de auditoria de leitura e modificação. |
| RF11 | Buscar pacientes por `nome`, `nome_social`, `cpf` ou `numero` de telefone. |
| RF12 | Consultar pagamentos pendentes por paciente, despesas pendentes e vencidas e resultado financeiro mensal. |
| RF13 | Listar os procedimentos já realizados em um paciente, com a quantidade e a data da última realização. |

**Requisitos não funcionais:**

> [COMPLETAR/CONFIRMAR: os RNF abaixo foram escritos a partir do dicionário de dados e do script, pois o levantamento não os lista. Compare com os RNF da Entrega 1 e ajuste.]

| Código | Requisito |
| :---- | :---- |
| RNF01 | **SGBD:** MySQL 8.0, engine InnoDB, codificação `utf8mb4`; o script deve executar em banco vazio sem erros. |
| RNF02 | **Integridade:** chaves primárias, estrangeiras, `UNIQUE` e `CHECK` aplicadas no banco; `ON DELETE RESTRICT` em todas as chaves estrangeiras, de modo que nada seja apagado em cascata. |
| RNF03 | **Segurança e privacidade (LGPD):** `info_saude` é dado sensível e só deve ser visto por dentista e auditoria; acessos devem gerar log (matriz de acesso nas seções 5 e 6 do dicionário). |
| RNF04 | **Desempenho:** índices em `paciente.nome`, `telefone.numero`, `agendamento.id_paciente`, `pagamento.status` e `despesa (status, data_vencimento)` para as buscas mais frequentes (P4). |
| RNF05 | **Precisão monetária:** valores em `DECIMAL(10,2)`. |
| RNF06 | **Retenção:** registros de prontuário, atendimento e tratamento mantidos pelo prazo legal de 20 anos, sem exclusão física (RN20). |

**Requisitos prováveis não incluídos:** controle de estoque, emissão de nota fiscal, cadastro de dentistas parceiros e de funcionários, registro da origem do paciente e pré-requisito entre procedimentos. Os motivos são os mesmos da tabela de processos acima.

#### Regras de negócio

As regras estão em [`levantamento/levantamento.md`](levantamento/levantamento.md), seção 6, e seguem a mesma numeração do dicionário de dados e do script. A coluna da direita diz onde cada uma é garantida.

| Código | Regra | Onde é garantida |
| :---- | :---- | :---- |
| RN01 | Todo paciente tem `nome` e ao menos um telefone. | `NOT NULL` em `paciente.nome`; o telefone mínimo é garantido pela aplicação no cadastro e conferido pela consulta A01. |
| RN02 | Um dentista não tem dois agendamentos na mesma `data_hora`, desconsiderando cancelados. | `UNIQUE (id_dentista, data_hora)` e consulta A02. |
| RN03 | `data_nascimento` não pode ser futura. | Aplicação (o MySQL não aceita a data atual em `CHECK`). |
| RN04 | A situação do agendamento deve estar sempre atualizada; em cancelamento oferece-se novo horário, e em falta contata-se o paciente. | `CHECK` no `status`; consultas A03 e A12; atualização U02. |
| RN05 | Dentistas parceiros e auxiliares não são cadastrados. | Decisão de escopo: só a titular existe em `dentista`. |
| RN06 | Procedimentos só são lançados em atendimentos `realizado`. | Aplicação; consulta A05. |
| RN07 | Não há duas especialidades com o mesmo nome. | `UNIQUE` em `especialidade.nome`. |
| RN08 | O `preco_praticado` pode diferir do `preco_base`. | Colunas separadas; consulta A11 confere descontos grandes. |
| RN09 | Um agendamento só entra em um tratamento do mesmo paciente. | Aplicação; consulta A04. |
| RN10 | Um agendamento pode ter vários pagamentos, e a soma não ultrapassa o valor dos procedimentos. | Relacionamento 1:N em `pagamento`; consulta A08. |
| RN11 | `preco_base` e `preco_praticado` são maiores ou iguais a zero. | `CHECK` nas duas colunas. |
| RN12 | Pagamento pendente gera aviso ao paciente. | Processo da clínica; consulta A07 lista os pendentes há mais de 30 dias. |
| RN13 | Todo dentista tem ao menos uma especialidade. | Aplicação; consulta A06. |
| RN14 | `pagamento.valor` é maior que zero. | `CHECK`. |
| RN15 | `forma_pagamento` é `pix`, `credito`, `debito` ou `dinheiro`. | `CHECK`. |
| RN16 | `data_pagamento` da despesa só existe quando ela está `paga`. | `CHECK` composto; consulta A09. |
| RN17 | `pagamento.status` é `pago` ou `pendente`. | `CHECK` e `DEFAULT 'pendente'`. |
| RN18 | Toda despesa tem categoria. | `NOT NULL` e chave estrangeira. |
| RN19 | CPF opcional; se informado, tem 11 dígitos e é único. | `UNIQUE` e `CHECK` com regex; consulta A10. |
| RN20 | Prontuário guardado por 20 anos, sem exclusão física. | Chaves estrangeiras `ON DELETE RESTRICT`. |
| RN21 | `despesa.valor` é maior que zero. | `CHECK`. |
| RN22 | `info_saude` é dado sensível de saúde (LGPD) e só dentista e auditoria o veem. | Matriz de acesso do dicionário (seção 6). [COMPLETAR: informar como será implementado, por exemplo view para a recepção e perfis no MySQL.] |
| RN23 | Telefone só com dígitos (10 ou 11, com DDD). | `CHECK` com regex. |
| RN24 | Convênio com estrutura enxuta (identificador e nome). | Modelo da tabela `convenio`. |
| RN25 | Paciente sem vínculo em `paciente_convenio` é particular. | Ausência de linhas na tabela de ligação. |
| RN26 | `numero_sessoes_estimado`, quando informado, é maior que zero. | `CHECK`. |
| RN27 | Despesas gerais não têm tratamento; as originadas por tratamento (ex.: laboratório) têm. | `id_tratamento` opcional em `despesa`; consulta G10. |

**Regras prováveis não incluídas:** as regras fiscais (emissão de nota fiscal), de estoque e de pré-requisito entre procedimentos não valem aqui, pelos mesmos motivos da tabela de processos.

#### Notação do DER conceitual

O DER foi criado no **brModelo** e segue a notação do brModelo: entidades em retângulo, relacionamentos em losango, cardinalidade `(mín, máx)` dos dois lados, atributos em círculo, `procedimento_realizado` como entidade associativa (retângulo envolvendo o losango `inclui`) e **sem chaves estrangeiras**. O DER não tem generalização nem autorrelacionamento. As cardinalidades são lidas "do outro lado" (o par ao lado de uma entidade diz quantas ocorrências dela se associam a uma ocorrência da outra), como explica a seção 1 do dicionário.

![DER conceitual revisado, na notação do brModelo](diagramas/DER_conceitual.png)

**Caso A — mesma organização da Entrega 1.** Registro de cada apontamento da correção da Entrega 1:

| Apontamento da correção da E1 | O que mudou no trabalho | Por quê |
| :---- | :---- | :---- |
| [COMPLETAR: apontamento 1 da correção da E1] | [COMPLETAR: o que foi alterado] | [COMPLETAR: justificativa] |
| [COMPLETAR: apontamento 2] | [COMPLETAR] | [COMPLETAR] |
| [COMPLETAR: apontamento 3 — se o grupo discordou e manteve o modelo, registrar aqui com a justificativa] | [COMPLETAR] | [COMPLETAR] |

> [COMPLETAR: a organização da Entrega 1 era a Clínica Sued? Se sim, este é o Caso A e a tabela acima precisa ser preenchida com a correção recebida. Se a organização da E1 era outra ou fictícia, trocar por Caso B e remover a tabela.]

### 1.2 Conversão do Modelo Conceitual para o Modelo Lógico

- **Entidades → Tabelas.** Cada uma das 12 entidades virou uma tabela com o mesmo nome (`paciente`, `telefone`, `convenio`, `dentista`, `especialidade`, `tratamento`, `agendamento`, `procedimento`, `pagamento`, `categoria_despesa`, `despesa`) e a entidade associativa `procedimento_realizado` virou tabela própria. Os dois relacionamentos N:N restantes viraram as tabelas de ligação `paciente_convenio` e `dentista_especialidade`. Resultado: **14 tabelas**.
- **Atributos → Colunas.** Todos os atributos viraram colunas atômicas. Os identificadores (`id_...`) viraram chaves primárias `INT`. Datas viraram `DATE` ou `DATETIME`, textos viraram `VARCHAR` e valores monetários aparecem como `FLOAT` no brModelo, mas são `DECIMAL(10,2)` no script (o brModelo não oferece `DECIMAL` nem mostra o tamanho do `VARCHAR`; os tipos definitivos estão no dicionário e no script).
- **Relacionamentos → Chaves.**

| Relacionamento | Cardinalidade | Tradução no lógico |
| :---- | :---- | :---- |
| `possui` (paciente–telefone) | 1:N | FK `id_paciente` em `telefone` |
| `marca` (paciente–agendamento) | 1:N | FK `id_paciente` em `agendamento` |
| `agenda` (dentista–agendamento) | 1:N | FK `id_dentista` em `agendamento` |
| `agrupa` (tratamento–agendamento) | 1:N, opcional | FK `id_tratamento` (nula) em `agendamento` |
| `gera` (agendamento–pagamento) | 1:N | FK `id_agendamento` em `pagamento` |
| `classifica` (categoria–despesa) | 1:N | FK `id_categoria_despesa` em `despesa` |
| `origina` (tratamento–despesa) | 1:N, opcional | FK `id_tratamento` (nula) em `despesa` |
| `possui` (paciente–convênio) | N:N | tabela `paciente_convenio`, PK composta |
| `tem` (dentista–especialidade) | N:N | tabela `dentista_especialidade`, PK composta |
| `inclui` (agendamento–procedimento) | N:N com atributos | tabela `procedimento_realizado`, PK composta, com `preco_praticado` e `observacoes` |

- **Cardinalidades.** Os relacionamentos 1:N colocam a chave estrangeira no lado "muitos". A obrigatoriedade mínima 1 do lado "um" vira `NOT NULL` na FK, e o mínimo 0 vira FK que aceita nulo. Os N:N viram tabelas associativas com chave primária composta pelas duas chaves.
- **Generalização/especialização.** O DER não tem generalização, então não foi necessária nenhuma estratégia de conversão.

### 1.3 Definição de Chaves Primárias e Estrangeiras

| Tabela | Chave primária | Chaves estrangeiras (todas `ON UPDATE CASCADE ON DELETE RESTRICT`) |
| :---- | :---- | :---- |
| `paciente` | `id_paciente` | — |
| `telefone` | `id_telefone` | `id_paciente` → `paciente` |
| `convenio` | `id_convenio` | — |
| `paciente_convenio` | `id_paciente` + `id_convenio` | `id_paciente` → `paciente`; `id_convenio` → `convenio` |
| `dentista` | `id_dentista` | — |
| `especialidade` | `id_especialidade` | — |
| `dentista_especialidade` | `id_dentista` + `id_especialidade` | `id_dentista` → `dentista`; `id_especialidade` → `especialidade` |
| `tratamento` | `id_tratamento` | — |
| `agendamento` | `id_agendamento` | `id_paciente` → `paciente`; `id_dentista` → `dentista`; `id_tratamento` → `tratamento` (opcional) |
| `procedimento` | `id_procedimento` | — |
| `procedimento_realizado` | `id_agendamento` + `id_procedimento` | `id_agendamento` → `agendamento`; `id_procedimento` → `procedimento` |
| `pagamento` | `id_pagamento` | `id_agendamento` → `agendamento` |
| `categoria_despesa` | `id_categoria_despesa` | — |
| `despesa` | `id_despesa` | `id_categoria_despesa` → `categoria_despesa`; `id_tratamento` → `tratamento` (opcional) |

### 1.4 Processo de Normalização (1FN, 2FN e 3FN)

O ponto de partida foi a ficha de papel da clínica, em que paciente, telefones, convênio, consulta, procedimentos, pagamentos e despesas aparecem misturados.

- **1FN — atributos atômicos e sem grupos repetitivos.**
  - Um paciente pode ter vários telefones: eles saíram de `paciente` para a tabela `telefone` (uma linha por número).
  - Um paciente pode ter vários convênios e um convênio vários pacientes: ficou `paciente_convenio`.
  - Um dentista pode ter várias especialidades: ficou `dentista_especialidade`.
  - Um atendimento pode ter vários procedimentos e vários pagamentos: ficaram `procedimento_realizado` e `pagamento`, em vez de colunas repetidas como `procedimento1`, `procedimento2` ou `parcela1`, `parcela2`.
- **2FN — sem dependência parcial da chave primária composta.** As tabelas com chave composta são `paciente_convenio`, `dentista_especialidade` e `procedimento_realizado`. As duas primeiras só têm as chaves. Em `procedimento_realizado` (chave `id_agendamento` + `id_procedimento`), `preco_praticado` e `observacoes` dependem do **par** (qual procedimento, em qual atendimento). O `nome`, o `preco_base` e o `numero_sessoes_estimado` dependem só de `id_procedimento`, e por isso ficam em `procedimento`, e não repetidos em cada realização.
- **3FN — sem dependência transitiva.**
  - O nome da categoria de despesa depende de `id_categoria_despesa`, e não da despesa: foi para `categoria_despesa`.
  - Nome e dados do paciente não se repetem em `agendamento`, `pagamento` ou `tratamento`; basta a chave estrangeira. O `tratamento` nem guarda o paciente: ele é obtido pelos agendamentos, o que evita a inconsistência de dois pacientes para o mesmo tratamento (RN09).
  - O nome do dentista e as especialidades ficam em `dentista` e `especialidade`, e o convênio em `convenio`.
- **Por que cada forma foi necessária:** sem a 1FN não seria possível guardar vários telefones, parcelas ou procedimentos por atendimento (P3, P4). Sem a 2FN o preço de catálogo se repetiria em cada atendimento e ficaria divergente. Sem a 3FN, mudar o nome de uma categoria ou corrigir um dado de paciente exigiria alterar várias linhas, com risco de inconsistência (P4, P6).

### 1.5 Justificativas Técnicas das Decisões

**Chaves primárias.** As tabelas de entidade usam um identificador artificial `id_...` (`INT AUTO_INCREMENT`), em vez de chaves naturais, porque nome não é único (homônimos, P4) e o CPF é opcional e sensível (RN19), então não serve de chave. As tabelas de ligação e `procedimento_realizado` usam chave composta pelas duas chaves estrangeiras, o que impede repetir o mesmo vínculo (o mesmo convênio duas vezes para o mesmo paciente, por exemplo).

**Chaves estrangeiras.** Cada FK implementa um relacionamento do DER (tabela da seção 1.2). Todas usam `ON DELETE RESTRICT`: nada de clínica ou financeiro é apagado em cascata (RN20, guarda do prontuário). As FKs opcionais (`agendamento.id_tratamento` e `despesa.id_tratamento`) aceitam nulo porque nem todo atendimento pertence a um tratamento e nem toda despesa vem de um tratamento (RN27).

**Restrições aplicadas:**

| Restrição | Onde | Regra |
| :---- | :---- | :---- |
| `NOT NULL` | `paciente.nome`, `telefone.numero`, `agendamento.data_hora`, `agendamento.status`, `pagamento.valor`, `despesa.id_categoria_despesa`, entre outras | RN01, RN18 |
| `UNIQUE` | `paciente.cpf` | RN19 |
| `UNIQUE` | `especialidade.nome` | RN07 |
| `UNIQUE` | `convenio.nome`, `procedimento.nome`, `categoria_despesa.nome` | evitar duplicidade em tabelas de referência |
| `UNIQUE` | `agendamento (id_dentista, data_hora)` | RN02 |
| `CHECK` | `paciente.cpf` com 11 dígitos | RN19 |
| `CHECK` | `telefone.numero` com 10 ou 11 dígitos | RN23 |
| `CHECK` | `agendamento.status` em cinco valores | RN04 |
| `CHECK` | `procedimento.preco_base >= 0`; `procedimento_realizado.preco_praticado >= 0` | RN11 |
| `CHECK` | `procedimento.numero_sessoes_estimado > 0` | RN26 |
| `CHECK` | `pagamento.valor > 0` | RN14 |
| `CHECK` | `pagamento.forma_pagamento` em quatro valores | RN15 |
| `CHECK` | `pagamento.status` em dois valores | RN17 |
| `CHECK` | `despesa.valor > 0` | RN21 |
| `CHECK` | `despesa.data_pagamento` coerente com `status` | RN16 |
| `DEFAULT` | `agendamento.status = 'agendado'`; `pagamento.status = 'pendente'`; `despesa.status = 'pendente'` | valor inicial natural de cada processo |
| Índices | `paciente.nome`, `telefone.numero`, `agendamento.id_paciente`, `pagamento.status`, `despesa (status, data_vencimento)` | buscas frequentes (P4, RNF04) |

**Decisões arquiteturais gerais:**
- **Uma entidade `dentista` mesmo com um único dentista:** a clínica tem hoje só a titular, mas o modelo comporta novos profissionais sem mudança de estrutura (RN05 define que parceiros pontuais não são cadastrados).
- **`procedimento_realizado` como entidade associativa com preço próprio:** o preço varia por paciente e situação (RN08), então o preço praticado fica separado do preço de catálogo.
- **`pagamento` ligado ao agendamento e sem data própria:** a clínica registra o pagamento junto ao atendimento. Por isso o faturamento mensal (G01) usa a data do agendamento.
- **`despesa` separada de `pagamento`:** entradas e saídas têm naturezas diferentes e a despesa pode ou não ligar a um tratamento, o que permite calcular margem por tratamento (P6).
- **`convenio` enxuto (RN24):** a clínica ainda está em implantação de convênios; novos campos podem ser acrescentados depois.
- **Regras garantidas pela aplicação e pela auditoria:** o que o SGBD não consegue expressar como restrição de coluna (RN01 no telefone mínimo, RN06, RN09, RN13) é conferido pelas consultas de auditoria do script.

### 1.6 Proposta de Arquitetura Analítica para BI e IA

**Informações estratégicas** que os dados permitem extrair:
- quanto a clínica recebe e quanto gasta por mês, e o resultado financeiro;
- quais procedimentos geram mais receita e com que desconto médio;
- quais tratamentos dão margem, depois de descontar laboratório e material;
- quanta agenda se perde com cancelamentos e faltas;
- quanto há a receber e há quanto tempo;
- quais pacientes estão sem retorno e quantos entram em tratamento.

**KPIs propostos.** Cada um tem fórmula, período e consulta do script que o calcula. As metas devem ser definidas com a responsável: [COMPLETAR: metas combinadas com a Dra. Tamires, por exemplo para taxa de perda de agenda e atendimentos por semana].

| KPI | Fórmula | Período | Consulta |
| :---- | :---- | :---- | :---- |
| Faturamento mensal | soma de `pagamento.valor` com status `pago`, por forma de pagamento | mensal | G01 |
| Valor a receber | soma de `pagamento.valor` com status `pendente`, por paciente | contínuo | G02 |
| Atendimentos por semana | contagem de agendamentos `realizado` | semanal | G03 |
| Média semanal de atendimentos | média de G03 (a clínica informou cerca de 7) | período total | G04 |
| Taxa de perda de agenda | (cancelados + faltas) ÷ agendamentos do mês | mensal | G05 |
| Receita por procedimento e desconto médio | soma de `preco_praticado` e média de (1 − `preco_praticado` ÷ `preco_base`) | mensal ou total | G06 |
| Despesa por categoria | soma de `despesa.valor` por categoria | mensal | G07 |
| Contas vencidas | despesas `pendente` com vencimento anterior à data de referência e dias de atraso | contínuo | G08 |
| Resultado mensal | recebido − despesas pagas | mensal | G09 |
| Margem por tratamento | receita dos agendamentos do tratamento − despesas ligadas a ele | por tratamento | G10 |
| Pacientes inativos | pacientes sem atendimento há mais de 90 dias | contínuo | G12 |
| Taxa de conversão em tratamento | pacientes com tratamento ÷ pacientes atendidos | período total | G13 |

**Rastreabilidade — problema → tabelas → consulta:**

| Problema ou KPI | Tabelas envolvidas | Consulta no script |
| :---- | :---- | :---- |
| P1 — prontuário e histórico em papel (histórico do paciente) | `paciente`, `agendamento`, `procedimento_realizado`, `procedimento` | G06, G11, G14 |
| P1 — acesso restrito a dados de saúde e trilha de auditoria (RF10, RN22) | `paciente` | [COMPLETAR: ainda sem consulta no script; incluir uma consulta ou view que demonstre a restrição de `info_saude`] |
| P2 — agendamento manual | `agendamento`, `paciente`, `dentista` | G03, G04, G05, A02, A12 |
| P3 — pagamentos sem registro | `pagamento`, `agendamento`, `paciente` | G01, G02, A07, A08 |
| P4 — busca lenta de pacientes e do financeiro | `paciente`, `telefone`, `pagamento` | G11, G02, G09 |
| P5 — captação (parcial) | `paciente`, `agendamento`, `tratamento` | G12, G13 |
| P6 — despesas em planilha | `despesa`, `categoria_despesa`, `tratamento` | G07, G08, G09, G10 |
| KPIs de faturamento, atendimentos e resultado | `pagamento`, `agendamento`, `despesa` | G01, G03, G04, G09 |

**Potencial para BI.** A estrutura em estrela natural em torno de `agendamento` (com paciente, dentista, tratamento, data) e `pagamento` e `despesa` (valores) permite montar dashboards de agenda (atendimentos, perda de horários), financeiro (faturamento, a receber, despesas, resultado mensal) e clínico (receita por procedimento, margem por tratamento). As consultas G01 a G14 já funcionam como fontes de dados para os painéis.

**Aplicações analíticas e de IA.**
- **Previsão de faltas:** modelo de classificação sobre o histórico de `agendamento.status` (`nao_compareceu`, `cancelado`) para sugerir confirmações extras.
- **Previsão de demanda:** série temporal dos atendimentos por semana para planejar a agenda.
- **Reativação de pacientes:** lista priorizada a partir de G12 e do histórico de procedimentos (G14).
- **Previsão de inadimplência:** pacientes com pagamentos pendentes antigos (A07) como base para antecipar cobranças.
- **Detecção de anomalias de preço:** descontos fora do padrão (A11).

**Limitações atuais dos dados:** `pagamento` não tem data própria, o que obriga o faturamento a usar a data do agendamento; e a origem do paciente não é registrada, o que limita a análise de captação (P5). Elas indicam a evolução futura do modelo.

---

## 2. Modelo Lógico Relacional

O modelo lógico foi criado no **brModelo**, na notação do modelo lógico do brModelo (tabelas, colunas com tipo, marcas `PK` e `FK` e cardinalidade `(mín, máx)` em cada ponta).

![Modelo lógico relacional, na notação do brModelo](diagramas/Modelo_logico.png)

- Arquivo: [`diagramas/Modelo_logico.png`](diagramas/Modelo_logico.png) ([PDF](diagramas/Modelo_logico.pdf)).
- As demais restrições de integridade (`NOT NULL`, `UNIQUE`, `CHECK`, `DEFAULT`) não aparecem no diagrama e estão documentadas no [dicionário de dados](docs/dicionario_dados.html) e implementadas no [script SQL](docs/script.sql).
- Valores monetários aparecem como `FLOAT` no diagrama porque o brModelo não oferece `DECIMAL`; no dicionário e no script são `DECIMAL(10,2)`.

---

## 3. Script SQL Completo

Arquivo: [`docs/script.sql`](docs/script.sql). SGBD: **MySQL 8.0** (testado do zero, em banco vazio, no MySQL 8.0.46, sem erros). Execução: `mysql -u usuario -p < docs/script.sql`, ou abrir o arquivo no MySQL Workbench e executar todo o script.

**Ordem do script:**

1. `CREATE DATABASE clinica_sued` (com `DROP DATABASE IF EXISTS`, o que permite executar de novo sem duplicar dados);
2. `CREATE TABLE` das 14 tabelas, com tipos, `NOT NULL`, `UNIQUE`, `DEFAULT` e `CHECK`;
3. chaves estrangeiras (`ALTER TABLE`) e índices;
4. `INSERT INTO` da massa de dados (seção 4);
5. `SELECT` com `JOIN` (J01 a J05);
6. `UPDATE` (U01 a U03);
7. `DELETE` (D01);
8. consultas gerenciais G01 a G14;
9. consultas de auditoria A01 a A12.

A data de referência das consultas é a variável `@hoje` (definida no início do script como `2026-10-24`, a data até a qual vai a massa de dados). Para testar G11 e G14, troque os valores de `@busca` e `@id_paciente`.

**Consultas gerenciais:**

| Código | Pergunta | Atende |
| :---- | :---- | :---- |
| G01 | Quanto a clínica recebeu por mês e por forma de pagamento? | P3, P4 |
| G02 | Quais pacientes têm pagamentos pendentes e quanto devem? | P3, P4 |
| G03 | Quantos atendimentos foram realizados por semana? | P2 |
| G04 | Qual é a média semanal de atendimentos realizados? | P2 |
| G05 | Qual é a taxa de cancelamentos e faltas por mês? | P2 |
| G06 | Quais procedimentos mais geram receita e quanto de desconto médio é dado? | P1, P4 |
| G07 | Quanto a clínica gasta por categoria de despesa em cada mês? | P6 |
| G08 | Quais contas a pagar estão pendentes e quantos dias de atraso têm? | P6 |
| G09 | Qual é o resultado financeiro de cada mês? | P4, P6 |
| G10 | Quanto cada tratamento custou em materiais e laboratório e qual foi a margem? | P6 |
| G11 | Como achar rapidamente um paciente por nome, CPF ou telefone? | P4, P1 |
| G12 | Quais pacientes estão sem atendimento há mais de 90 dias? | P5 (parcial) |
| G13 | Que parcela dos pacientes atendidos entrou em tratamento? | P5 (parcial) |
| G14 | Quais procedimentos já foram realizados em um paciente? | P1 (RF13) |

**Consultas de auditoria:**

| Código | Pergunta | Verifica |
| :---- | :---- | :---- |
| A01 | Existe paciente sem nenhum telefone? | RN01 |
| A02 | Existem dois agendamentos ativos do mesmo dentista no mesmo horário? | RN02 |
| A03 | Quais cancelamentos ou faltas ficaram sem novo agendamento? | RN04 |
| A04 | Existe tratamento com agendamentos de mais de um paciente? | RN09 |
| A05 | Existe procedimento registrado em agendamento que não foi realizado? | RN06, RN08 |
| A06 | Existe dentista sem nenhuma especialidade? | RN13 |
| A07 | Quais pagamentos pendentes de atendimentos realizados têm mais de 30 dias? | RN12 |
| A08 | Existe agendamento com pagamentos maiores que o valor dos procedimentos? | RN10 |
| A09 | Existe despesa paga sem data de pagamento, ou pendente com data? | RN16 |
| A10 | Existe CPF cadastrado para mais de um paciente? | RN19 |
| A11 | Quais procedimentos de sessão única foram cobrados com mais de 20% de desconto? | RN08 |
| A12 | Existe agendamento no passado que ainda consta como "agendado"? | RN04 |

---

## 4. Massa de Dados

A massa de dados está **incluída no script** ([`docs/script.sql`](docs/script.sql), seção 4). Ela é **fictícia**: nenhum nome, telefone, valor ou informação de saúde real foi usado, e os CPFs têm dígito verificador inválido de propósito. É coerente com as operações observadas na clínica.

**Como o volume real justifica a quantidade de registros:**

| Tabela | Registros | Justificativa |
| :---- | :---- | :---- |
| `paciente` | 20 | Amostra dos pacientes ativos no período coberto pelos dados (a clínica tem cerca de 300 no histórico). [CONFIRMAR: o comentário do script diz "a clínica atende cerca de 20 pacientes"; alinhar com o número de 300 do levantamento.] |
| `telefone` | 26 | Todo paciente tem ao menos 1 telefone (RN01); alguns têm 2. |
| `convenio` / `paciente_convenio` | 1 / 3 | A clínica tem 1 convênio em implantação e poucos pacientes o usam. |
| `dentista` | 1 | A clínica tem uma única dentista (RN05). |
| `especialidade` / `dentista_especialidade` | 5 / 3 | Catálogo de 5 especialidades; a dentista tem 3 (RN13). |
| `procedimento` | 7 | Os 7 serviços informados na entrevista. |
| `agendamento` | 233 | 7 atendimentos por semana × 26 semanas (6 meses) dá 182 realizados; somando cancelados, faltas e remarcados chega-se a 220 marcações até a data de referência, mais a agenda da semana seguinte. |
| `tratamento` | 30 | Tratamentos de várias sessões (canal, implante, prótese etc.). |
| `procedimento_realizado` | 172 | Cada atendimento realizado com procedimento registra o preço praticado. |
| `pagamento` | 190 | Pagamentos dos atendimentos, com parcelas e formas diferentes. |
| `categoria_despesa` | 7 | As 7 categorias da planilha da clínica. |
| `despesa` | 50 | Despesas mensais fixas (aluguel, luz, empréstimo, impostos) e eventuais ao longo de 6 meses. |

**Variedade para os testes:** agendamentos realizados, cancelados, remarcados, faltas e ainda `agendado`; paciente sem nenhum agendamento; pacientes sem retorno há mais de 90 dias; pagamentos em Pix, crédito, débito e dinheiro; pagamentos pendentes antigos; despesas pendentes e vencidas; despesas ligadas e não ligadas a tratamento; agendamentos passados esquecidos como `agendado`. Com isso as consultas gerenciais e de auditoria retornam linhas que demonstram o resultado.

**Uso de IA na massa de dados:** [COMPLETAR: informar se a massa de dados foi gerada com IA, quais ferramentas e prompts, e registrar na seção 6].

---

## 5. Repositório GitHub

Estrutura de arquivos na branch `main`:

| Caminho | Conteúdo |
| :---- | :---- |
| `README.md` | Este Relatório Técnico |
| `levantamento/levantamento.md` | Levantamento de requisitos e análise da organização |
| `imagens/foto_visita.jpeg`, `imagens/foto_clinica.jpg` | Fotos da visita e da clínica |
| `diagramas/` | DER conceitual e modelo lógico (brModelo), em PNG e PDF |
| `docs/dicionario_dados.html` | Dicionário de dados atualizado (arquivo HTML único) |
| `docs/script.sql` | Script SQL completo, com a massa de dados |
| [COMPLETAR: pasta ou arquivo dos slides] | Slides do pitch |

- **Dicionário de dados:** [`docs/dicionario_dados.html`](docs/dicionario_dados.html) (v1.2), com as restrições de cada coluna (obrigatoriedade, unicidade, valores permitidos e valor padrão), as cardinalidades, o log de acesso e a matriz de acesso por perfil (LGPD).
- **Histórico de commits e colaboração:** [COMPLETAR: confirmar que cada integrante fez commits com a própria conta, que o nome na conta do GitHub é compatível com o da tabela de Integrantes e que o histórico está distribuído ao longo dos dias, e não em um único commit final].

---

## 6. Uso de Inteligência Artificial

> [COMPLETAR: confirmar com o grupo todos os usos de IA. Abaixo estão registrados os usos do **Claude (Anthropic)** que aconteceram na conversa usada para este trabalho. Se o grupo usou outras ferramentas (por exemplo, para gerar o script ou a massa de dados, ou para pesquisar processos, requisitos, regras e KPIs típicos), cada uso precisa de uma linha nas tabelas abaixo.]

### Uso 1 — Claude: aprender e usar o MySQL

| Item | Registro |
| :---- | :---- |
| **Ferramenta e etapa** | Claude (Anthropic), na instalação do MySQL e do MySQL Workbench e na execução do script SQL. |
| **Motivação** | Uma integrante precisava aprender a usar o MySQL do zero para executar o script feito por outra integrante. |
| **Prompt(s)** | "eu estou fazendo um trabalho de banco de dados e a minha amiga fez o SQL e agr eu quero aprender a mexer nele, eu preciso q vc me ensine a mexer no MySQL do 0, da parte de instalar até o SQL rodar" (e prints das telas de instalação e do Workbench, com perguntas sobre o que marcar). |
| **Resposta recebida** | Passo a passo de instalação, criação da conexão `root@localhost:3306`, abertura e execução do script e como conferir o banco `clinica_sued`. |
| **Fontes consultadas e verificadas** | O procedimento foi conferido na prática: o servidor instalou, o Workbench foi instalado à parte quando o instalador falhou e o script rodou. |
| **Trechos rejeitados ou corrigidos** | A IA sugeriu rodar `SET @hoje = CURDATE();`, o que sobrescreve a data de referência do script (`2026-10-24`) e muda o resultado de consultas como G05, G08, G12 e A12. O correto é manter `@hoje = '2026-10-24'`. Também afirmou, de início, que rodar o script de novo poderia duplicar dados, mas o script começa com `DROP DATABASE IF EXISTS`. |
| **Justificativa da escolha final** | Foram mantidos os passos de instalação e conexão, que funcionaram, e corrigidos os dois pontos acima. |
| **Reflexão crítica** | A IA descreveu telas de memória e precisou se corrigir depois de ver os prints; sugeriu um comando sem ler antes o script inteiro. |

### Uso 2 — Claude: conferência de consistência entre os artefatos

| Item | Registro |
| :---- | :---- |
| **Ferramenta e etapa** | Claude (Anthropic), na conferência do DER, do modelo lógico, do dicionário, do script e do levantamento. |
| **Motivação** | Verificar se os cinco artefatos estavam coerentes entre si e com o que o professor pediu. |
| **Prompt(s)** | "eu preciso q vc confira tudo e diga se está certo, porfavor"; "confere se o levantamento está correto". |
| **Resposta recebida** | A IA executou o script do zero no MySQL 8.0.46 (sem erros) e listou inconsistências: número de dentistas, numeração divergente de P, RF e RN entre levantamento, script e dicionário, volume de pacientes (20 no script e 300 no levantamento), `UNIQUE` de horário bloqueando agendamentos cancelados, agendamentos `realizado` posteriores à data de referência, tabela `pagamento` sem data e problema P sem consulta. |
| **Fontes consultadas e verificadas** | O grupo conferiu os apontamentos abrindo os arquivos e rodando as consultas no Workbench. [COMPLETAR: quais apontamentos foram verificados e corrigidos pelo grupo.] |
| **Trechos rejeitados ou corrigidos** | A IA entendeu "Dra. Tamires" e "Dra. Sued" como duas dentistas e concluiu que o modelo deveria ter 2; na verdade é uma pessoa só (Dra. Tamires Sued) e o modelo com 1 dentista está correto. O grupo corrigiu o levantamento. |
| **Justificativa da escolha final** | O grupo manteve os apontamentos que se confirmaram nos arquivos e descartou o que partiu de interpretação errada da IA. |
| **Reflexão crítica** | A IA interpretou nomes sem confirmação e só conseguiu avaliar o que estava nos arquivos enviados; não substitui a conferência com a responsável da clínica. |

### Uso 3 — Claude: padronização dos códigos do levantamento e redação do README

| Item | Registro |
| :---- | :---- |
| **Ferramenta e etapa** | Claude (Anthropic), na renumeração de P, RF e RN do `levantamento.md` e na redação deste README a partir do esqueleto do professor. |
| **Motivação** | Alinhar os códigos do levantamento com os do script e do dicionário, e organizar o relatório na estrutura exigida. |
| **Prompt(s)** | "vc consegue arrumar os codigos RN, RF e P no levantamento e me mandar por favor"; envio do esqueleto da Entrega 2 e dos artefatos pedindo que o README seguisse o esqueleto, com marcações onde faltasse informação. |
| **Resposta recebida** | Levantamento com P1–P6, RF01–RF13 e RN01–RN27 alinhados ao script e ao dicionário, e este README. |
| **Fontes consultadas e verificadas** | Os dados do README foram extraídos dos arquivos do grupo (levantamento, script, dicionário, DER e modelo lógico). [COMPLETAR: o grupo revisou e conferiu o texto contra os arquivos?] |
| **Trechos rejeitados ou corrigidos** | [COMPLETAR: o que o grupo alterou no texto gerado] |
| **Justificativa da escolha final** | [COMPLETAR] |
| **Reflexão crítica** | Os RNF, as regras RN04, RN05, RN06, RN10 e RN12 e as metas dos KPIs foram redigidos pela IA a partir dos artefatos, sem confirmação com a clínica; por isso precisam de revisão do grupo. |

### Outros usos de IA

[COMPLETAR: declarar, com ferramenta, etapa, prompts, respostas, correções e reflexão, qualquer outro uso de IA no trabalho: geração do script SQL, geração da massa de dados, pesquisa de processos, requisitos, regras e KPIs típicos, escrita ou revisão de texto. Se o grupo não usou IA em alguma etapa, declarar isso explicitamente.]

---

## 7. Apresentação Corporativa Final

Pitch de 8 minutos. Slides: [COMPLETAR: link ou caminho dos slides]. Apresentadores: [COMPLETAR: quem fala em cada parte; todos os integrantes participam e estão presentes para a defesa].

Roteiro, na ordem pedida:

1. **Problema:** a clínica controla agenda, pagamentos, despesas e prontuário em Google Agenda, cadernos, planilha e papel (P1 a P6).
2. **Solução:** banco de dados MySQL com 14 tabelas que reúne todos os dados da clínica.
3. **Modelo lógico:** diagrama do brModelo (seção 2 deste README).
4. **SQL rodando:** execução do script do zero no MySQL Workbench (seção 3).
5. **Consultas gerenciais e de auditoria:** [COMPLETAR: escolher 2 ou 3 consultas para a demonstração, por exemplo uma gerencial de agenda, uma financeira e uma de auditoria].
6. **Potencial para BI e IA:** KPIs e aplicações da seção 1.6.
7. **Benefícios para a decisão:** controle de quem deve e de quanto, de horários perdidos, de custo e margem por tratamento, e de acesso ao histórico do paciente.

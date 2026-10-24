# Entrega 1 — Modelo Conceitual (DER)
### Modelagem de um sistema de gestão de informações para uma organização de pequeno porte

---

## Metadados

- **Nomes dos alunos e RGM:**
- Beatriz Fonseca Dias 47272139
- Vitória Aparecida de Assis Silva 46625909
- Letícia Santos da Silva 47551976

---

## 1. Caracterização da Organização

- **Nome e natureza da organização:** Clínica Sued Odontologia Humanizada — clínica odontológica particular, com fins lucrativos, atualmente em processo de implantação de atendimento por convênio (1 convênio).
- **Contexto e porte:** clínica em funcionamento há 6 meses. Estrutura enxuta: 1 sala de atendimento e 1 funcionária (a própria dentista responsável, Tamires, que também acumula a função de recepção/agendamento). Atende cerca de 20 pacientes cadastrados, com uma média de 7 atendimentos por semana. Os serviços oferecidos incluem atendimento clínico geral, implantes e próteses, além de outros procedimentos como limpeza, cirurgia, endodontia e clareamento.
- **Problemas e necessidades identificados:** as informações da clínica estão divididas entre um aplicativo criado com apoio de IA e fichas clínicas físicas, sem prontuário eletrônico. Os problemas, numerados para acompanhamento no restante do relatório, são:
  — Prontuário e histórico só em papel** (anamnese e ficha de evolução físicas), difíceis de consultar. Atendido por `paciente`, `telefone`, `tratamento`, `agendamento` e `procedimento_realizado`.
  — Agendamento manual** por WhatsApp e Google Agenda, sem bloqueio automático de horário. Atendido por `agendamento`.
  — Pagamentos sem registro em sistema**, com pendências controladas pelo prontuário. Atendido por `pagamento`.
  — Busca lenta de pacientes e do financeiro**, a maior necessidade relatada pela responsável. Atendido por `paciente`, `telefone`, `pagamento` e `despesa`.
  — Dificuldade de captar clientes**, relatada pela responsável. A clínica não registra de onde vem o paciente, e **o DER desta entrega não cobre este problema**: seria preciso guardar a data de cadastro e o canal de captação do paciente.
  — Despesas em planilha separada**, sem ligação com o restante. Atendido por `despesa`, `categoria_despesa` e pela ligação com `tratamento`.
- **Justificativa da escolha:** a clínica é pequena o suficiente para ser modelada nesta etapa (poucos profissionais, processos ainda simples), mas já gera entidades e relacionamentos suficientes para um modelo relevante: pacientes, dentistas, agendamentos, procedimentos, tratamentos, pagamentos e despesas. Além disso, por ser uma operação recém-criada e ainda sem sistema informatizado estruturado, o grupo tem espaço real para propor melhorias que a própria clínica já demonstrou desejar (prontuário eletrônico, busca rápida, controle financeiro).
- **Evidências da organização:**
  - **Endereço:** Praça Nelson Sales de Abreu, 103 - Sl 04, Cidade Patriarca, São Paulo - SP, CEP 03547-100
  - **Telefone de contato:** (11) 95387-7504
  - **Localização no Google Maps:** [maps.app.goo.gl/E1UdxAZoc6zMUEYx5](https://maps.app.goo.gl/E1UdxAZoc6zMUEYx5)
  - **Responsável pela organização:** Tamires (dentista e proprietária da clínica)
  - **Foto da visita de campo:**

    ![Foto da visita à Clínica Sued Odontologia Humanizada](imagens/foto_visita.jpeg)

---

## 2. Processos de Negócio

**Principais processos mapeados:**

1. **Cadastro de paciente** — feito por meio de anamnese física no primeiro atendimento; coleta dados pessoais e informações de saúde relevantes. Nome e telefone são obrigatórios; o paciente pode ter mais de um telefone de contato. O cadastro pode ser alterado posteriormente.
2. **Agendamento, cancelamento e falta** — o paciente entra em contato via WhatsApp (único canal, exceto presencialmente com agendamento prévio); a própria dentista realiza o agendamento, verificando disponibilidade no Google Agenda. Em caso de cancelamento, é oferecido reagendamento; em caso de falta, a clínica entra em contato para saber o motivo e propor novo horário.
3. **Atendimento e registro de procedimentos** — o paciente é recepcionado e avaliado pela própria dentista, que confirma a chegada. Durante o atendimento são registrados os procedimentos realizados e observações. Um atendimento pode envolver mais de um procedimento.
4. **Planejamento do tratamento e definição de valores** — na avaliação, a dentista define os procedimentos a realizar. Alguns procedimentos exigem outro antes (pré-requisito) e outros precisam de várias sessões. Cada procedimento tem um preço, que pode variar conforme o paciente ou a situação; a quantidade de pagamentos e a forma de pagar dependem do que é combinado com o paciente. O plano de tratamento é apresentado ao paciente antes do início e registrado, junto com o tratamento completo, na ficha de anamnese e na ficha de evolução (ambas em papel).
5. **Acompanhamento de tratamento** — quando o paciente precisa de múltiplos atendimentos ao longo do tempo (ex.: tratamento de canal, implante), a evolução é registrada em uma ficha de evolução física. Para novos agendamentos, a clínica consulta os procedimentos já realizados.
6. **Encaminhamento a dentista parceiro** — quando o paciente precisa de uma especialização diferente da dentista titular, um profissional parceiro realiza o atendimento.
7. **Pagamento** — pode ocorrer antes ou depois do atendimento, à vista ou parcelado, em pix, crédito, débito ou dinheiro. Não há registro sistematizado — o controle é feito apenas por meio do prontuário físico, e pendências são tratadas avisando o paciente.
8. **Convênios (em implantação)** — a clínica está iniciando o atendimento por convênio; as regras específicas (informações registradas, múltiplos convênios por paciente, autorização de procedimentos pelo convênio) ainda não estão consolidadas.
9. **Compra e controle de materiais (não formalizado)** — segundo a entrevista, a clínica não mantém estoque formal, não controla materiais por quantidade mínima e não tem fornecedores cadastrados. Quando há entrada ou uso de materiais, o registro é feito pela própria dentista. "Abastecimento" foi citado pela responsável entre os pontos que gostaria de melhorar. Por não existir controle hoje, o processo está mapeado como necessidade futura e **não** entra no DER desta entrega.
10. **Controle financeiro e contas a pagar** — as despesas da clínica são controladas em uma planilha simples, com gastos de aluguel, luz, impostos, laboratórios, material dental, empréstimos da clínica e gastos eventuais. O controle financeiro foi apontado como prioridade pela responsável. No DER, esse processo é representado pelas entidades `despesa` e `categoria_despesa`, com ligação opcional ao `tratamento` para custos de um tratamento específico, como materiais dentais e laboratório. A entrevista não detalhou as colunas da planilha; vencimento, data de pagamento e situação são proposta do grupo.
11. **Termos de consentimento** — a clínica utiliza três termos: termo para cirurgia de implante, autorização de imagem e termo de entrega de próteses. A entrevista não informou como os termos são guardados. Os termos **não são representados no DER desta entrega**.
12. **Recibo ou nota fiscal** — as respostas da responsável divergem: antes disse que emite se o paciente solicitar; depois, que ainda não emite. A entrevista não indicou nenhum registro de recibos, e o DER não os representa.
13. **Captação de clientes** — a responsável apontou a dificuldade de captar clientes como principal problema. A entrevista não informou quais ações de captação a clínica usa nem se registra a origem do paciente. O DER desta entrega não registra essa informação (P5).

**O que a clínica não possui hoje:**

- Estoque de materiais, quantidade mínima de materiais e fornecedores cadastrados: a clínica não possui nenhum dos três.
- Registro de pagamentos em sistema: a clínica não possui; o controle é feito no prontuário em papel.
- Prontuário e histórico eletrônicos: a clínica não possui; o histórico é apenas físico.
- Identificador único de paciente: a clínica não possui; a identificação é pelo nome.
- Relatórios: a clínica não gera nenhum.
- Dados cadastrais do dentista além do nome: a clínica não registra.
- Regras de convênio (autorização de procedimentos e mais de um convênio por paciente): a clínica ainda não definiu.

---

## 3. Requisitos do Sistema

### 3.1 Requisitos Funcionais

- RF01 — Cadastrar pacientes com nome (`paciente.nome`) e ao menos um telefone (`telefone.numero`), admitindo vários telefones por paciente. *Atende P1.*
- RF02 — Registrar e consultar o histórico completo de agendamentos e atendimentos de um paciente. *Atende P1.*
- RF03 — Agendar consultas associando paciente, dentista, data e hora (`agendamento.data_hora`), impedindo dois pacientes no mesmo horário com o mesmo dentista. *Atende P2.*
- RF04 — Registrar a situação do agendamento (`agendamento.status`: agendado, realizado, cancelado, remarcado, não compareceu) e observações. *Atende P2.*
- RF05 — Registrar, em cada agendamento realizado, um ou mais procedimentos executados com o preço praticado (`procedimento_realizado.preco_praticado`). *Atende P1.*
- RF06 — Cadastrar procedimentos com nome, preço base e número estimado de sessões (`procedimento.nome`, `preco_base`, `numero_sessoes_estimado`) e seus pré-requisitos.
- RF07 — Vincular agendamentos a um tratamento (`tratamento.nome`, `data_inicio`, `descricao`, `observacoes`), admitindo agendamentos sem tratamento (avaliação inicial). *Atende P1.*
- RF08 — Registrar pagamentos de um agendamento (`pagamento.valor`, `forma_pagamento`, `status`), admitindo parcelamento e formas combinadas. *Atende P3.*
- RF09 — Identificar pagamentos pendentes. *Atende P3.*
- RF10 — Cadastrar dentistas com uma ou mais especialidades.
- RF11 — Buscar rapidamente um paciente por nome, telefone ou CPF. *Atende P4.*
- RF12 — Associar o paciente a nenhum, um ou vários convênios.
- RF13 — Consultar os procedimentos já realizados em um paciente, para subsidiar novos agendamentos.
- RF14 — Registrar despesas (`despesa.descricao`, `valor`, `data_vencimento`, `data_pagamento`, `status`) classificadas em uma categoria e, opcionalmente, ligadas a um tratamento. *Atende P6.*
- RF15 — Consultar contas a pagar pendentes e o total de despesas por categoria e período. *Atende P4 e P6.*

### 3.2 Requisitos Não Funcionais

- RNF01 — **Usabilidade:** interface simples, já que o sistema será operado por uma única profissional sem apoio técnico dedicado.
- RNF02 — **Segurança e privacidade:** acesso às informações do paciente restrito à dentista responsável (ou a quem ela autorizar), dado o caráter sensível dos dados de saúde.
- RNF03 — **Disponibilidade:** acessível também por dispositivo móvel, já que o agendamento hoje é feito por WhatsApp fora do horário fixo de clínica.
- RNF04 — **Desempenho:** buscas de paciente e consulta de dados financeiros devem retornar rapidamente (P4).
- RNF05 — **Confiabilidade:** os dados de prontuário não podem ser perdidos, pois hoje dependem de ficha física.
- RNF06 — **Conformidade legal:** respeitar a LGPD para dados de saúde (dado pessoal sensível), manter registro de acessos e preservar o prontuário pelo prazo de guarda de 20 anos, com anonimização após o prazo.

---

## 4. Regras de Negócio

**Regras operacionais:**

- **RN01** — Um paciente só pode ser cadastrado com nome e ao menos um telefone.
- **RN02** — Um mesmo horário não pode ter dois pacientes agendados com o mesmo dentista.
- **RN03** — Um dentista pode ter várias consultas marcadas no mesmo dia.
- **RN04** — Em caso de cancelamento, é oferecido reagendamento; em caso de falta, a clínica contata o paciente para entender o motivo e propor novo horário.
- **RN05** — Caso o procedimento exija uma especialidade diferente da dentista titular, o paciente é encaminhado a um dentista parceiro.
- **RN06** — Um agendamento pode envolver mais de um procedimento.
- **RN07** — Um procedimento pode exigir a realização prévia de outro procedimento (pré-requisito), e nunca de si mesmo.
- **RN08** — O preço de um procedimento é variável por paciente ou situação; por isso o preço efetivamente praticado é registrado a cada procedimento realizado.
- **RN09** — Um agendamento pertence a no máximo um tratamento e pode não pertencer a nenhum (ex.: avaliação inicial). Todos os agendamentos de um tratamento são do mesmo paciente.
- **RN10** — Um agendamento pode ser pago em mais de uma vez (parcelamento), inclusive com formas de pagamento diferentes.
- **RN11** — O pagamento pode ocorrer antes ou depois do atendimento.
- **RN12** — Quando há pagamento pendente, a clínica notifica o paciente.
- **RN13** — Todo dentista tem ao menos uma especialidade cadastrada.
- **RN14** — Toda despesa pertence a exatamente uma categoria: aluguel, luz, impostos, laboratórios, dental, empréstimos ou gastos eventuais.
- **RN15** — Uma despesa pode estar ligada a um tratamento (como materiais dentais e laboratório) ou ser geral da clínica (como aluguel, luz e impostos).
- **RN16** — Toda despesa tem situação pendente ou paga; a data de pagamento só é preenchida quando a despesa está paga.

**Restrições organizacionais:**

- **RN17** — A estrutura atual (1 sala, 1 dentista fixa) limita os atendimentos simultâneos; o modelo não representa salas, mas permite essa expansão futura.
- **RN18** — O acesso às informações do paciente é restrito à dentista; é uma restrição de privacidade a preservar no sistema.
- **RN19** — A clínica não tem identificador único de paciente (identifica por nome); o modelo corrige isso com chave primária gerada pelo sistema e CPF opcional e único.
- **RN20** — **Guarda do prontuário:** guardar por 20 anos; encerrado o prazo, anonimizar, nunca apagar fisicamente. Por isso registros de paciente, tratamento e agendamento não são excluídos.
- **RN21** — **LGPD:** as informações de saúde são dado pessoal sensível (art. 5º, II e art. 11); o acesso é restrito aos envolvidos no cuidado e deve ser registrado em log.
- **RN22** — **Termos de consentimento:** a clínica usa três termos (implante, imagem e entrega de próteses). A entrevista não informou como são guardados, e o DER desta entrega não os representa.
- **RN23** — **Documento fiscal:** as respostas da responsável divergem sobre a emissão de recibo ou nota fiscal, e a clínica não registra recibos; por isso o DER não os representa.
- **RN24** — **Convênio:** o atendimento por convênio está em implantação; as regras de autorização de procedimentos e de múltiplos convênios por paciente **não estão definidas** pela clínica. O modelo guarda só o nome do convênio.

---

## 5. Dicionário de Dados Conceitual (Preliminar)

📄 **[Dicionário de Dados (HTML)](https://bia12diasfonseca-cyber.github.io/Entrega-1-Banco-de-dados/dicionario_dados.html)**

---

## 6. Modelagem Conceitual (Entidades, Atributos, Relacionamentos)

**Entidades reconhecidas**:

- **paciente** — pessoa física atendida; entidade central do modelo.
- **telefone** — contato do paciente; entidade separada porque o paciente pode ter vários.
- **convenio** — plano ou operadora; entidade separada por poder ser compartilhada entre vários pacientes.
- **dentista** — profissional responsável pelos agendamentos.
- **especialidade** — área de atuação odontológica; compartilhada entre dentistas.
- **agendamento** — consulta marcada entre paciente e dentista; depois de realizada, representa o atendimento.
- **tratamento** — conjunto de cuidados acompanhado ao longo de vários agendamentos.
- **procedimento** — serviço odontológico oferecido pela clínica, com preço base.
- **procedimento_realizado** *(associativa)* — procedimento executado em um agendamento, com o preço praticado.
- **pagamento** — registro financeiro gerado por um agendamento.
- **despesa** — gasto da clínica (conta a pagar).
- **categoria_despesa** — classificação da despesa (aluguel, luz, impostos, laboratórios, dental, empréstimos, gastos eventuais).

**Atributos e classificações** *(conforme o DER anexado):*

- **paciente:** `id_paciente` (chave primária); `nome` (obrigatório); `nome_social` (opcional); `cpf` (opcional, único quando informado); `data_nascimento` (opcional); `info_saude` (opcional, sensível).
- **telefone:** `id_telefone` (chave primária); `numero` (obrigatório).
- **convenio:** `id_convenio` (chave primária); `nome` (obrigatório).
- **dentista:** `id_dentista` (chave primária); `nome` (obrigatório).
- **especialidade:** `id_especialidade` (chave primária); `nome` (obrigatório).
- **agendamento:** `id_agendamento` (chave primária); `data_hora` (obrigatório); `status` (categórico: agendado, realizado, cancelado, remarcado, não compareceu); `observacoes` (opcional).
- **tratamento:** `id_tratamento` (chave primária); `nome` (obrigatório); `data_inicio` (opcional); `descricao` (opcional); `observacoes` (opcional).
- **procedimento:** `id_procedimento` (chave primária); `nome` (obrigatório); `preco_base` (obrigatório); `numero_sessoes_estimado` (opcional).
- **procedimento_realizado:** `preco_praticado` (obrigatório); `observacoes` (opcional); identificada pelas chaves de agendamento e procedimento.
- **pagamento:** `id_pagamento` (chave primária); `valor` (obrigatório); `forma_pagamento` (categórico: pix, crédito, débito, dinheiro); `status` (categórico: pago, pendente).
- **categoria_despesa:** `id_categoria_despesa` (chave primária); `nome` (obrigatório).
- **despesa:** `id_despesa` (chave primária); `descricao` (opcional); `valor` (obrigatório); `data_vencimento` (obrigatório); `data_pagamento` (opcional); `status` (categórico: pendente, paga).

Não há atributos compostos nem multivalorados: telefones, convênios e especialidades são entidades próprias. A idade do paciente é derivável de `data_nascimento` e não é armazenada.

**Relacionamentos pertinentes:**

As cardinalidades seguem o formato (mín,máx) do DER, lidas "do outro lado": o par ao lado de uma entidade indica quantas ocorrências **dela** se associam a **uma** ocorrência da entidade oposta.

| Relacionamento | Entidade A | Entidade B | Leitura |
|---|---|---|---|
| **possui** | paciente (0,n) | convenio (0,n) | Um paciente tem zero ou mais convênios (zero = particular); um convênio tem zero ou mais pacientes (N:N). |
| **possui** | paciente (1,1) | telefone (1,n) | Um paciente tem de um a vários telefones; cada telefone pertence a um único paciente. |
| **marca** | paciente (1,1) | agendamento (0,n) | Um paciente tem zero ou vários agendamentos; cada agendamento é de um único paciente. |
| **agenda** | dentista (1,1) | agendamento (0,n) | Um dentista tem zero ou vários agendamentos; cada agendamento é com um único dentista. |
| **tem** | dentista (0,n) | especialidade (1,n) | Um dentista tem de uma a várias especialidades; uma especialidade pode ter zero ou vários dentistas (N:N). |
| **agrupa** | tratamento (0,1) | agendamento (0,n) | Um tratamento agrupa zero ou vários agendamentos; cada agendamento pertence a no máximo um tratamento. |
| **inclui** (associativa procedimento_realizado) | agendamento (0,n) | procedimento (0,n) | Um agendamento inclui zero ou vários procedimentos; um procedimento aparece em zero ou vários agendamentos (N:N). |
| **exige** (autorrelacionamento) | procedimento (0,n) | procedimento (0,n) | Um procedimento exige zero ou vários procedimentos prévios e pode ser pré-requisito de zero ou vários outros (N:N). |
| **gera** | agendamento (1,1) | pagamento (0,n) | Um agendamento gera zero ou vários pagamentos; cada pagamento vem de um único agendamento. |
| **origina** | tratamento (0,1) | despesa (0,n) | Um tratamento origina zero ou várias despesas; cada despesa está ligada a no máximo um tratamento. |
| **classifica** | categoria_despesa (1,1) | despesa (0,n) | Uma categoria classifica zero ou várias despesas; cada despesa tem exatamente uma categoria. |

O paciente e o dentista de um tratamento não são ligados diretamente a ele: constam em cada agendamento do tratamento (RN09).

**Restrições e políticas organizacionais aplicadas ao modelo:**

- Todo paciente tem ao menos um telefone (RN01) e todo dentista tem ao menos uma especialidade (RN13).
- Todo agendamento tem exatamente um paciente e um dentista, e no máximo um tratamento (RN09).
- A exclusividade de horário por dentista (RN02) e a regra de que os agendamentos de um tratamento são do mesmo paciente (RN09) não são expressas por cardinalidade; são regras de integridade garantidas na implementação.
- Um procedimento não pode ser pré-requisito de si mesmo (RN07).
- Despesa tem sempre uma categoria e, opcionalmente, um tratamento (RN14, RN15).
- Informação de saúde de acesso restrito (RN18, RN21) e registros preservados por 20 anos (RN20).

---

## 7. Diagrama Entidade-Relacionamento (DER)

 ![Diagrama Entidade-Relacionamento](DiagramaDER.jpg)


---

## 8. Justificativa Técnica

- **Telefone, convênio e especialidade como entidades:** um paciente tem vários telefones e convênios, e um dentista tem várias especialidades. Como atributos, os valores se repetiriam no mesmo registro; como entidades, telefone é 1:N com paciente, e convênio e especialidade são N:N, o que atende à regra de que um dentista pode ter mais de uma especialidade.
- **Agendamento como entidade única para a consulta marcada e realizada:** não foi criada uma entidade atendimento separada. Com uma dentista e uma sala, a consulta marcada vira o atendimento quando ocorre, e `status` já registra cancelamentos e faltas. Duas entidades quase idênticas duplicariam dados.
- **Procedimento como entidade, e associativa `procedimento_realizado`:** a entrevista confirmou que um atendimento envolve vários procedimentos e que o preço varia por paciente ou situação. A relação N:N carrega um dado da combinação, o `preco_praticado`; um atributo de texto no agendamento não permitiria isso.
- **Autorrelacionamento "exige":** representa os pré-requisitos entre procedimentos, confirmados pela clínica, sem duplicar entidades.
- **Tratamento ligado a agendamento (agrupa, 0,1 : 0,n), sem ligação direta com paciente e dentista:** a clínica acompanha tratamentos de várias sessões na ficha de evolução, e agrupar os agendamentos reproduz isso, aceitando agendamentos sem tratamento (avaliação inicial). Paciente e dentista já constam em cada agendamento, e um parceiro pode atender (RN05); ligações diretas seriam redundantes. O custo dessa escolha é que a implementação precisa garantir que os agendamentos de um tratamento sejam do mesmo paciente (RN09).
- **Pagamento como entidade:** como um agendamento pode ser pago em mais de uma vez e de formas diferentes, atributo simples não representaria o parcelamento.
- **Despesa, categoria_despesa e ligação com tratamento:** a clínica controla despesas em planilha e as agrupa em sete categorias. A categoria é uma entidade para permitir novas categorias sem alterar a estrutura. A ligação opcional de `despesa` com `tratamento` (0,1 : 0,n) permite atribuir ao tratamento os custos de materiais dentais e laboratório, e deixa as despesas gerais (aluguel, luz, impostos) sem tratamento.
- **Chaves e CPF opcional:** a clínica identifica pacientes só pelo nome; chaves geradas pelo sistema evitam duplicidade. O `cpf` é opcional e único porque a clínica só exige nome e telefone, e dado desnecessário amplia o risco na LGPD.
- **Fora do DER:** estoque e fornecedores (a clínica não possui), termos de consentimento (a clínica os usa, mas não foram representados nesta entrega), recibo ou nota fiscal (respostas divergentes e nenhum registro hoje) e origem do paciente (P5). Os processos estão na Seção 2.

---

## 9. Uso de Inteligência Artificial

| Item | Registro |
|------|------------------|
| **Ferramenta e etapa** | Claude (Anthropic), utilizado na organização das respostas da entrevista de campo e na redação do README (caracterização da organização, requisitos, regras de negócio, dicionário de dados, modelagem conceitual e justificativa técnica). |
| **Motivação** | O grupo já havia realizado a entrevista presencial na clínica e precisava estruturar as respostas no formato exigido pelo esqueleto do README, incluindo a identificação de entidades, atributos e cardinalidades a partir das respostas obtidas. |
| **Prompt(s) utilizados** | 1) "Você pode me ajudar com um trabalho? Preciso fazer um README seguindo as orientações que estão no arquivo da atividade. Vou te enviar esse arquivo e, depois, a entrevista que fiz com a empresa. Quero que você analise o que a atividade pede e me diga quais informações você precisa da entrevista ou de outras fontes para conseguir montar o README corretamente." 2) "Essa é a entrevista que eu fiz com a empresa. Analise as informações e veja se elas são suficientes para fazer o README seguindo o que a atividade pede. Se estiver faltando alguma informação, me avise exatamente o que preciso fornecer." |
| **Resposta recebida** | A IA solicitou inicialmente as informações necessárias (nome/tipo da organização, evidências de existência, processos, regras e dados coletados) e, após o envio da entrevista, gerou uma proposta de README completo, incluindo entidades, atributos, relacionamentos e cardinalidades derivados das respostas da entrevista. |
| **Fontes consultadas e verificadas** | Nenhuma fonte externa foi usada, todo o conteúdo foi derivado exclusivamente das respostas da entrevista de campo feita pelo próprio grupo na clínica. |
| **Trechos rejeitados ou corrigidos** | O grupo revisou tudo o que a IA gerou, comparando com o que foi observado na visita de campo. Um dos trechos corrigidos foi na parte de atributos das entidades, onde alguns campos sugeridos pela IA foram ajustados para refletir melhor a realidade da clínica. |
| **Justificativa da escolha final** | O grupo adaptou algumas partes sugeridas pela IA porque, com o conhecimento direto da clínica obtido na visita, entendeu que do jeito que o grupo pensou o modelo ficaria mais fiel à realidade observada. |
| **Reflexão crítica** | A IA não teve acesso direto à clínica, apenas ao texto da entrevista, por isso, atributos como `data_nascimento` e `id_paciente` foram propostos como recomendações de boas práticas de modelagem, não como dados hoje efetivamente coletados pela clínica, e devem ser validados pelo grupo. Há também risco de a IA ter generalizado processos comuns a clínicas odontológicas que não necessariamente se aplicam a esta clínica específica (ex.: regras de convênio, que ainda estão em implantação e não foram detalhadas na entrevista). |

---

## Resumo dos Pesos

| Dimensão | Peso total |
|----------|-----------|
| Conceitual (contexto, requisitos/regras, modelagem, justificativa técnica) | 30% |
| Procedimental (requisitos, fluxogramas, dicionário de dados, DER) | 50% |
| Atitudinal (participação, comprometimento, colaboração, autonomia) | 20% |

**Entrega final:** README.md completo + DER + Dicionário de Dados em HTML (com exceção dos cursos GTI) anexado no repositório GitHub do grupo.

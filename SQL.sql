-- =====================================================================
-- Clínica Sued Odontologia Humanizada — Entrega 2 (Banco de Dados)
-- Script SQL completo para MySQL 8.0 (testado do zero, em banco vazio)
--
-- Como executar:  mysql -u usuario -p < script.sql
--
-- Ordem do script
--   1. CREATE DATABASE
--   2. CREATE TABLE (14 tabelas: PK, NOT NULL, UNIQUE, DEFAULT e CHECK)
--   3. Constraints de integridade referencial (FK) e índices
--   4. INSERT INTO (massa de dados fictícia)
--   5. SELECT com JOIN
--   6. UPDATE
--   7. DELETE
--   8. Consultas gerenciais (G01 a G14)
--   9. Consultas de auditoria (A01 a A12)
--
-- Convenções: nomes de tabelas e colunas iguais ao Modelo Lógico e ao
-- Dicionário de Dados. Valores monetários em DECIMAL(10,2) e textos em
-- VARCHAR. A data de referência dos relatórios é a variável @hoje.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. CREATE DATABASE
-- ---------------------------------------------------------------------
DROP DATABASE IF EXISTS clinica_sued;
CREATE DATABASE clinica_sued CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE clinica_sued;

-- Data de referência usada nas consultas (a massa de dados vai até esta data).
SET @hoje = '2026-10-24';

-- ---------------------------------------------------------------------
-- 2. CREATE TABLE
-- ---------------------------------------------------------------------
CREATE TABLE paciente (
  id_paciente     INT          NOT NULL AUTO_INCREMENT,
  nome            VARCHAR(120) NOT NULL,
  nome_social     VARCHAR(120) NULL,
  cpf             CHAR(11)     NULL,
  data_nascimento DATE         NULL,
  info_saude      VARCHAR(1000) NULL,
  CONSTRAINT pk_paciente PRIMARY KEY (id_paciente),
  CONSTRAINT uq_paciente_cpf UNIQUE (cpf),
  CONSTRAINT ck_paciente_cpf CHECK (cpf IS NULL OR cpf REGEXP '^[0-9]{11}$')
) ENGINE=InnoDB;

CREATE TABLE telefone (
  id_telefone INT         NOT NULL AUTO_INCREMENT,
  id_paciente INT         NOT NULL,
  numero      VARCHAR(20) NOT NULL,
  CONSTRAINT pk_telefone PRIMARY KEY (id_telefone),
  CONSTRAINT ck_telefone_numero CHECK (numero REGEXP '^[0-9]{10,11}$')
) ENGINE=InnoDB;

CREATE TABLE convenio (
  id_convenio INT          NOT NULL AUTO_INCREMENT,
  nome        VARCHAR(100) NOT NULL,
  CONSTRAINT pk_convenio PRIMARY KEY (id_convenio),
  CONSTRAINT uq_convenio_nome UNIQUE (nome)
) ENGINE=InnoDB;

CREATE TABLE paciente_convenio (
  id_paciente INT NOT NULL,
  id_convenio INT NOT NULL,
  CONSTRAINT pk_paciente_convenio PRIMARY KEY (id_paciente, id_convenio)
) ENGINE=InnoDB;

CREATE TABLE dentista (
  id_dentista INT          NOT NULL AUTO_INCREMENT,
  nome        VARCHAR(120) NOT NULL,
  CONSTRAINT pk_dentista PRIMARY KEY (id_dentista)
) ENGINE=InnoDB;

CREATE TABLE especialidade (
  id_especialidade INT         NOT NULL AUTO_INCREMENT,
  nome             VARCHAR(60) NOT NULL,
  CONSTRAINT pk_especialidade PRIMARY KEY (id_especialidade),
  CONSTRAINT uq_especialidade_nome UNIQUE (nome)
) ENGINE=InnoDB;

CREATE TABLE dentista_especialidade (
  id_dentista      INT NOT NULL,
  id_especialidade INT NOT NULL,
  CONSTRAINT pk_dentista_especialidade PRIMARY KEY (id_dentista, id_especialidade)
) ENGINE=InnoDB;

CREATE TABLE tratamento (
  id_tratamento INT          NOT NULL AUTO_INCREMENT,
  nome          VARCHAR(120) NOT NULL,
  data_inicio   DATE         NULL,
  descricao     VARCHAR(500) NULL,
  observacoes   VARCHAR(500) NULL,
  CONSTRAINT pk_tratamento PRIMARY KEY (id_tratamento)
) ENGINE=InnoDB;

CREATE TABLE agendamento (
  id_agendamento INT          NOT NULL AUTO_INCREMENT,
  id_paciente    INT          NOT NULL,
  id_dentista    INT          NOT NULL,
  id_tratamento  INT          NULL,
  data_hora      DATETIME     NOT NULL,
  status         VARCHAR(15)  NOT NULL DEFAULT 'agendado',
  observacoes    VARCHAR(500) NULL,
  CONSTRAINT pk_agendamento PRIMARY KEY (id_agendamento),
  -- RN02: um dentista não atende dois pacientes no mesmo horário
  CONSTRAINT uq_agendamento_dentista_hora UNIQUE (id_dentista, data_hora),
  CONSTRAINT ck_agendamento_status CHECK (status IN ('agendado','realizado','cancelado','remarcado','nao_compareceu'))
) ENGINE=InnoDB;

CREATE TABLE procedimento (
  id_procedimento         INT           NOT NULL AUTO_INCREMENT,
  nome                    VARCHAR(100)  NOT NULL,
  preco_base              DECIMAL(10,2) NOT NULL,
  numero_sessoes_estimado INT           NULL,
  CONSTRAINT pk_procedimento PRIMARY KEY (id_procedimento),
  CONSTRAINT uq_procedimento_nome UNIQUE (nome),
  CONSTRAINT ck_procedimento_preco CHECK (preco_base >= 0),
  CONSTRAINT ck_procedimento_sessoes CHECK (numero_sessoes_estimado IS NULL OR numero_sessoes_estimado > 0)
) ENGINE=InnoDB;

CREATE TABLE procedimento_realizado (
  id_agendamento  INT           NOT NULL,
  id_procedimento INT           NOT NULL,
  preco_praticado DECIMAL(10,2) NOT NULL,
  observacoes     VARCHAR(500)  NULL,
  CONSTRAINT pk_procedimento_realizado PRIMARY KEY (id_agendamento, id_procedimento),
  CONSTRAINT ck_proc_realizado_preco CHECK (preco_praticado >= 0)
) ENGINE=InnoDB;

CREATE TABLE pagamento (
  id_pagamento    INT           NOT NULL AUTO_INCREMENT,
  id_agendamento  INT           NOT NULL,
  valor           DECIMAL(10,2) NOT NULL,
  forma_pagamento VARCHAR(10)   NOT NULL,
  status          VARCHAR(10)   NOT NULL DEFAULT 'pendente',
  CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento),
  CONSTRAINT ck_pagamento_valor CHECK (valor > 0),
  CONSTRAINT ck_pagamento_forma CHECK (forma_pagamento IN ('pix','credito','debito','dinheiro')),
  CONSTRAINT ck_pagamento_status CHECK (status IN ('pago','pendente'))
) ENGINE=InnoDB;

CREATE TABLE categoria_despesa (
  id_categoria_despesa INT         NOT NULL AUTO_INCREMENT,
  nome                 VARCHAR(30) NOT NULL,
  CONSTRAINT pk_categoria_despesa PRIMARY KEY (id_categoria_despesa),
  CONSTRAINT uq_categoria_despesa_nome UNIQUE (nome)
) ENGINE=InnoDB;

CREATE TABLE despesa (
  id_despesa           INT           NOT NULL AUTO_INCREMENT,
  id_categoria_despesa INT           NOT NULL,
  id_tratamento        INT           NULL,
  descricao            VARCHAR(200)  NULL,
  valor                DECIMAL(10,2) NOT NULL,
  data_vencimento      DATE          NOT NULL,
  data_pagamento       DATE          NULL,
  status               VARCHAR(10)   NOT NULL DEFAULT 'pendente',
  CONSTRAINT pk_despesa PRIMARY KEY (id_despesa),
  CONSTRAINT ck_despesa_valor CHECK (valor > 0),
  CONSTRAINT ck_despesa_status CHECK (status IN ('pendente','paga')),
  -- RN16: a data de pagamento só existe quando a despesa está paga
  CONSTRAINT ck_despesa_pagamento CHECK ((status = 'paga' AND data_pagamento IS NOT NULL) OR (status = 'pendente' AND data_pagamento IS NULL))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. Constraints de integridade referencial (FK) e índices
--    ON DELETE RESTRICT: nada é apagado em cascata (RN20, guarda do prontuário).
-- ---------------------------------------------------------------------
ALTER TABLE telefone
  ADD CONSTRAINT fk_telefone_paciente FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE paciente_convenio
  ADD CONSTRAINT fk_pacconv_paciente FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT,
  ADD CONSTRAINT fk_pacconv_convenio FOREIGN KEY (id_convenio) REFERENCES convenio (id_convenio) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE dentista_especialidade
  ADD CONSTRAINT fk_dentesp_dentista FOREIGN KEY (id_dentista) REFERENCES dentista (id_dentista) ON UPDATE CASCADE ON DELETE RESTRICT,
  ADD CONSTRAINT fk_dentesp_especialidade FOREIGN KEY (id_especialidade) REFERENCES especialidade (id_especialidade) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE agendamento
  ADD CONSTRAINT fk_agendamento_paciente FOREIGN KEY (id_paciente) REFERENCES paciente (id_paciente) ON UPDATE CASCADE ON DELETE RESTRICT,
  ADD CONSTRAINT fk_agendamento_dentista FOREIGN KEY (id_dentista) REFERENCES dentista (id_dentista) ON UPDATE CASCADE ON DELETE RESTRICT,
  ADD CONSTRAINT fk_agendamento_tratamento FOREIGN KEY (id_tratamento) REFERENCES tratamento (id_tratamento) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE procedimento_realizado
  ADD CONSTRAINT fk_procreal_agendamento FOREIGN KEY (id_agendamento) REFERENCES agendamento (id_agendamento) ON UPDATE CASCADE ON DELETE RESTRICT,
  ADD CONSTRAINT fk_procreal_procedimento FOREIGN KEY (id_procedimento) REFERENCES procedimento (id_procedimento) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE pagamento
  ADD CONSTRAINT fk_pagamento_agendamento FOREIGN KEY (id_agendamento) REFERENCES agendamento (id_agendamento) ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE despesa
  ADD CONSTRAINT fk_despesa_categoria FOREIGN KEY (id_categoria_despesa) REFERENCES categoria_despesa (id_categoria_despesa) ON UPDATE CASCADE ON DELETE RESTRICT,
  ADD CONSTRAINT fk_despesa_tratamento FOREIGN KEY (id_tratamento) REFERENCES tratamento (id_tratamento) ON UPDATE CASCADE ON DELETE RESTRICT;

-- Índices para as buscas mais frequentes (P4)
CREATE INDEX ix_paciente_nome ON paciente (nome);
CREATE INDEX ix_telefone_numero ON telefone (numero);
CREATE INDEX ix_agendamento_paciente ON agendamento (id_paciente);
CREATE INDEX ix_pagamento_status ON pagamento (status);
CREATE INDEX ix_despesa_status_venc ON despesa (status, data_vencimento);

-- ---------------------------------------------------------------------
-- 4. INSERT INTO — massa de dados FICTÍCIA
--
-- Nenhum dado real de pacientes, dentistas ou valores da clínica foi usado.
-- Nomes, telefones, CPFs (todos com dígito verificador inválido de propósito),
-- datas de nascimento, informações de saúde e preços são inventados, mas
-- seguem as operações e os volumes observados na clínica (Seção 1.1 do README).
--
-- Como o volume real justifica a quantidade de registros:
--   paciente ........... 20  — a clínica atende cerca de 20 pacientes.
--   telefone ........... 26  — todo paciente tem ao menos 1 telefone (RN01); alguns têm 2.
--   convenio ........... 1   — a clínica atende 1 convênio, ainda em implantação.
--   paciente_convenio .. 3   — poucos pacientes usam o convênio.
--   dentista ........... 1   — a clínica tem uma única dentista e nenhum outro profissional cadastrado
--                        (nem dentista parceiro nem auxiliar); parceiros externos, quando
--                        necessários (RN05), não são cadastrados no sistema.
--   especialidade ...... 5   — catálogo de especialidades; a dentista possui 3 (clínica geral, prótese e implante).
--   dentista_especialidade 3 — as especialidades da dentista (RN13: ao menos uma).
--   procedimento ....... 7   — os 7 serviços informados na entrevista.
--   agendamento ........ 233 — 220 marcações até a data de referência (média de 8.5 por semana em 26 semanas),
--                        das quais 182 realizadas (7.0 por semana, como informado pela clínica),
--                        mais a agenda da semana seguinte.
--   tratamento ......... 30  — tratamentos de várias sessões (canal, implante, prótese etc.).
--   procedimento_realizado 172 — cada atendimento realizado com procedimento registra o preço praticado.
--   pagamento .......... 190 — pagamentos dos atendimentos, com parcelas e formas diferentes.
--   categoria_despesa .. 7   — as 7 categorias da planilha de despesas da clínica.
--   despesa ............ 50  — despesas mensais (aluguel, luz, empréstimo, impostos) e eventuais, 6 meses.
--
-- Variedade para os testes: agendamentos cancelados, remarcados e faltas;
-- paciente cadastrado sem nenhum agendamento; pacientes sem retorno há mais de
-- 90 dias; pagamentos em pix, crédito, débito e dinheiro; pagamentos pendentes
-- antigos; despesas pendentes e vencidas; despesas ligadas e não ligadas a
-- tratamento; agendamentos passados esquecidos como "agendado".
-- ---------------------------------------------------------------------
INSERT INTO especialidade (id_especialidade, nome) VALUES
  (1, 'Clínica Geral'),
  (2, 'Prótese Dentária'),
  (3, 'Implantodontia'),
  (4, 'Cirurgia Oral'),
  (5, 'Endodontia');

INSERT INTO dentista (id_dentista, nome) VALUES
  (1, 'Helena Duarte');

INSERT INTO dentista_especialidade (id_dentista, id_especialidade) VALUES
  (1, 1),
  (1, 2),
  (1, 3);

INSERT INTO convenio (id_convenio, nome) VALUES
  (1, 'Convênio Odonto Exemplo');

INSERT INTO paciente (id_paciente, nome, nome_social, cpf, data_nascimento, info_saude) VALUES
  (1, 'Mariana Alves Costa', NULL, '72576005625', '1987-03-24', 'Hipertensão controlada'),
  (2, 'Carlos Eduardo Lima', NULL, '28983215594', '1954-05-21', NULL),
  (3, 'Juliana Ramos Pereira', NULL, '72821319101', '1951-04-17', 'Alergia a penicilina'),
  (4, 'Roberto Nogueira Silva', NULL, '67483560241', '1999-01-24', 'Diabetes tipo 2'),
  (5, 'Fernanda Barbosa Souza', NULL, '94256891995', '1991-09-03', NULL),
  (6, 'Paulo Henrique Martins', NULL, NULL, '1971-09-28', 'Uso contínuo de anticoagulante'),
  (7, 'Aline Cardoso Ribeiro', NULL, '05572644481', '1991-09-20', NULL),
  (8, 'Marcos Vinícius Teixeira', NULL, NULL, '1972-07-17', 'Sem alergias relatadas'),
  (9, 'Patrícia Gomes Araújo', NULL, '55135857665', '1960-03-16', NULL),
  (10, 'Rafaela Moreira Dias', NULL, '73632445029', '1977-08-19', NULL),
  (11, 'Eduardo Pinto Cavalcanti', NULL, NULL, '2003-05-09', 'Hipertensão controlada; alergia a dipirona'),
  (12, 'Luciana Freitas Barros', NULL, '19742415723', '1973-06-10', NULL),
  (13, 'Thiago Monteiro Reis', 'Téo Monteiro', NULL, '1954-01-27', NULL),
  (14, 'Camila Azevedo Lopes', NULL, '73499504201', '1976-01-05', 'Asma leve'),
  (15, 'Gustavo Ferraz Almeida', NULL, '30132165067', '1969-12-17', NULL),
  (16, 'Beatriz Campos Mendes', 'Duda Campos', NULL, '1960-03-09', NULL),
  (17, 'Ricardo Santana Borges', NULL, NULL, '1955-06-08', 'Diabetes tipo 2'),
  (18, 'Vanessa Duarte Carvalho', NULL, '89961805641', '1993-10-02', 'Gestante (2º trimestre) no cadastro'),
  (19, 'Leandro Batista Rocha', NULL, NULL, '2003-09-10', NULL),
  (20, 'Sônia Maria Oliveira', NULL, NULL, '1970-08-02', NULL);

INSERT INTO telefone (id_telefone, id_paciente, numero) VALUES
  (1, 1, '11900001037'),
  (2, 2, '11900001074'),
  (3, 2, '11800002082'),
  (4, 3, '11900001111'),
  (5, 4, '11900001148'),
  (6, 5, '11900001185'),
  (7, 5, '11800002205'),
  (8, 6, '11900001222'),
  (9, 7, '11900001259'),
  (10, 8, '11900001296'),
  (11, 9, '11900001333'),
  (12, 9, '11800002369'),
  (13, 10, '11900001370'),
  (14, 11, '11900001407'),
  (15, 12, '11900001444'),
  (16, 12, '11800002492'),
  (17, 13, '11900001481'),
  (18, 14, '11900001518'),
  (19, 15, '11900001555'),
  (20, 15, '11800002615'),
  (21, 16, '11900001592'),
  (22, 17, '11900001629'),
  (23, 18, '11900001666'),
  (24, 18, '11800002738'),
  (25, 19, '11900001703'),
  (26, 20, '11900001740');

INSERT INTO paciente_convenio (id_paciente, id_convenio) VALUES
  (2, 1),
  (9, 1),
  (15, 1);

INSERT INTO categoria_despesa (id_categoria_despesa, nome) VALUES
  (1, 'aluguel'),
  (2, 'luz'),
  (3, 'impostos'),
  (4, 'laboratorios'),
  (5, 'dental'),
  (6, 'emprestimos'),
  (7, 'gastos_eventuais');

INSERT INTO procedimento (id_procedimento, nome, preco_base, numero_sessoes_estimado) VALUES
  (1, 'Limpeza', 200, 1),
  (2, 'Cirurgia', 500, 1),
  (3, 'Manutenção', 180, 1),
  (4, 'Endodontia', 800, 3),
  (5, 'Implante', 3200, 1),
  (6, 'Prótese', 1800, 4),
  (7, 'Clareamento', 1000, 3);

INSERT INTO tratamento (id_tratamento, nome, data_inicio, descricao, observacoes) VALUES
  (1, 'Implante dentário', '2026-05-18', 'Colocação de implante e reabilitação', NULL),
  (2, 'Clareamento dental', '2026-10-19', 'Clareamento supervisionado', NULL),
  (3, 'Implante dentário', '2026-05-14', 'Colocação de implante e reabilitação', NULL),
  (4, 'Clareamento dental', '2026-10-07', 'Clareamento supervisionado', 'Paciente com boa evolução'),
  (5, 'Tratamento de canal', '2026-05-25', 'Tratamento endodôntico em 3 sessões', NULL),
  (6, 'Clareamento dental', '2026-07-24', 'Clareamento supervisionado', NULL),
  (7, 'Tratamento de canal', '2026-05-27', 'Tratamento endodôntico em 3 sessões', NULL),
  (8, 'Prótese dentária', '2026-06-29', 'Confecção e instalação de prótese', 'Paciente com boa evolução'),
  (9, 'Clareamento dental', '2026-05-25', 'Clareamento supervisionado', NULL),
  (10, 'Tratamento de canal', '2026-07-31', 'Tratamento endodôntico em 3 sessões', NULL),
  (11, 'Clareamento dental', '2026-10-15', 'Clareamento supervisionado', NULL),
  (12, 'Prótese dentária', '2026-05-26', 'Confecção e instalação de prótese', 'Paciente com boa evolução'),
  (13, 'Clareamento dental', '2026-10-15', 'Clareamento supervisionado', NULL),
  (14, 'Prótese dentária', '2026-06-05', 'Confecção e instalação de prótese', NULL),
  (15, 'Cirurgia oral', '2026-06-15', 'Cirurgia e retorno', NULL),
  (16, 'Clareamento dental', '2026-10-08', 'Clareamento supervisionado', 'Paciente com boa evolução'),
  (17, 'Tratamento de canal', '2026-06-08', 'Tratamento endodôntico em 3 sessões', NULL),
  (18, 'Clareamento dental', '2026-10-12', 'Clareamento supervisionado', NULL),
  (19, 'Clareamento dental', '2026-06-16', 'Clareamento supervisionado', NULL),
  (20, 'Clareamento dental', '2026-10-19', 'Clareamento supervisionado', 'Paciente com boa evolução'),
  (21, 'Implante dentário', '2026-06-15', 'Colocação de implante e reabilitação', NULL),
  (22, 'Prótese dentária', '2026-07-22', 'Confecção e instalação de prótese', NULL),
  (23, 'Clareamento dental', '2026-10-14', 'Clareamento supervisionado', NULL),
  (24, 'Tratamento de canal', '2026-06-26', 'Tratamento endodôntico em 3 sessões', 'Paciente com boa evolução'),
  (25, 'Clareamento dental', '2026-07-30', 'Clareamento supervisionado', NULL),
  (26, 'Cirurgia oral', '2026-06-23', 'Cirurgia e retorno', NULL),
  (27, 'Prótese dentária', '2026-08-18', 'Confecção e instalação de prótese', NULL),
  (28, 'Clareamento dental', '2026-07-27', 'Clareamento supervisionado', 'Paciente com boa evolução'),
  (29, 'Cirurgia oral', '2026-08-07', 'Cirurgia e retorno', NULL),
  (30, 'Clareamento dental', '2026-10-27', 'Clareamento supervisionado', NULL);

INSERT INTO agendamento (id_agendamento, id_paciente, id_dentista, id_tratamento, data_hora, status, observacoes) VALUES
  (1, 1, 1, NULL, '2026-04-28 16:00:00', 'realizado', NULL),
  (2, 19, 1, NULL, '2026-04-29 08:00:00', 'realizado', 'Retorno em 15 dias'),
  (3, 2, 1, NULL, '2026-05-01 15:00:00', 'realizado', NULL),
  (4, 13, 1, NULL, '2026-05-04 09:00:00', 'realizado', NULL),
  (5, 3, 1, NULL, '2026-05-04 10:00:00', 'realizado', NULL),
  (6, 4, 1, NULL, '2026-05-08 08:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (7, 5, 1, NULL, '2026-05-11 11:00:00', 'realizado', NULL),
  (8, 2, 1, 3, '2026-05-14 09:00:00', 'realizado', NULL),
  (9, 6, 1, NULL, '2026-05-14 16:00:00', 'realizado', NULL),
  (10, 13, 1, NULL, '2026-05-18 08:00:00', 'realizado', 'Orientado sobre higienização'),
  (11, 7, 1, NULL, '2026-05-18 09:00:00', 'realizado', 'Retorno em 15 dias'),
  (12, 1, 1, 1, '2026-05-18 13:00:00', 'nao_compareceu', 'Paciente não compareceu; contato feito por mensagem'),
  (13, 8, 1, NULL, '2026-05-21 08:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (14, 3, 1, 5, '2026-05-25 08:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (15, 1, 1, 1, '2026-05-25 10:00:00', 'realizado', NULL),
  (16, 2, 1, 3, '2026-05-25 13:00:00', 'nao_compareceu', 'Paciente não compareceu; contato feito por mensagem'),
  (17, 5, 1, 9, '2026-05-25 15:00:00', 'realizado', NULL),
  (18, 9, 1, NULL, '2026-05-25 17:00:00', 'realizado', 'Orientado sobre higienização'),
  (19, 6, 1, 12, '2026-05-26 14:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (20, 4, 1, 7, '2026-05-27 17:00:00', 'realizado', NULL),
  (21, 8, 1, NULL, '2026-05-28 09:00:00', 'realizado', NULL),
  (22, 10, 1, NULL, '2026-05-28 17:00:00', 'realizado', NULL),
  (23, 2, 1, 3, '2026-05-29 17:00:00', 'realizado', NULL),
  (24, 3, 1, 5, '2026-06-01 15:00:00', 'realizado', 'Retorno em 15 dias'),
  (25, 11, 1, NULL, '2026-06-01 16:00:00', 'realizado', NULL),
  (26, 5, 1, 9, '2026-06-01 17:00:00', 'realizado', NULL),
  (27, 6, 1, 12, '2026-06-02 14:00:00', 'realizado', NULL),
  (28, 4, 1, 7, '2026-06-02 17:00:00', 'realizado', 'Retorno em 15 dias'),
  (29, 13, 1, NULL, '2026-06-03 08:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (30, 1, 1, 1, '2026-06-03 16:00:00', 'realizado', 'Retorno em 15 dias'),
  (31, 12, 1, NULL, '2026-06-03 17:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (32, 7, 1, 14, '2026-06-05 16:00:00', 'nao_compareceu', 'Paciente não compareceu; contato feito por mensagem'),
  (33, 3, 1, 5, '2026-06-08 09:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (34, 5, 1, 9, '2026-06-08 10:00:00', 'realizado', 'Retorno em 15 dias'),
  (35, 2, 1, 3, '2026-06-08 15:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (36, 9, 1, 17, '2026-06-08 17:00:00', 'realizado', NULL),
  (37, 6, 1, 12, '2026-06-09 08:00:00', 'realizado', NULL),
  (38, 14, 1, NULL, '2026-06-09 09:00:00', 'realizado', NULL),
  (39, 1, 1, 1, '2026-06-09 15:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (40, 7, 1, 14, '2026-06-11 09:00:00', 'realizado', 'Retorno em 15 dias');

INSERT INTO agendamento (id_agendamento, id_paciente, id_dentista, id_tratamento, data_hora, status, observacoes) VALUES
  (41, 4, 1, 7, '2026-06-11 15:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (42, 3, 1, 5, '2026-06-12 10:00:00', 'realizado', NULL),
  (43, 8, 1, 15, '2026-06-15 10:00:00', 'realizado', NULL),
  (44, 12, 1, NULL, '2026-06-15 11:00:00', 'realizado', NULL),
  (45, 11, 1, 21, '2026-06-15 13:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (46, 15, 1, NULL, '2026-06-15 14:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (47, 10, 1, 19, '2026-06-16 13:00:00', 'realizado', 'Orientado sobre higienização'),
  (48, 2, 1, 3, '2026-06-16 15:00:00', 'realizado', NULL),
  (49, 1, 1, 1, '2026-06-16 17:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (50, 6, 1, 12, '2026-06-17 08:00:00', 'realizado', NULL),
  (51, 16, 1, NULL, '2026-06-17 09:00:00', 'realizado', 'Retorno em 15 dias'),
  (52, 9, 1, 17, '2026-06-17 13:00:00', 'realizado', NULL),
  (53, 7, 1, 14, '2026-06-18 10:00:00', 'realizado', NULL),
  (54, 5, 1, NULL, '2026-06-19 17:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (55, 10, 1, 19, '2026-06-22 08:00:00', 'realizado', NULL),
  (56, 13, 1, NULL, '2026-06-22 09:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (57, 11, 1, 21, '2026-06-22 11:00:00', 'realizado', 'Orientado sobre higienização'),
  (58, 3, 1, 5, '2026-06-22 13:00:00', 'realizado', 'Orientado sobre higienização'),
  (59, 17, 1, NULL, '2026-06-22 15:00:00', 'realizado', 'Retorno em 15 dias'),
  (60, 15, 1, 26, '2026-06-23 10:00:00', 'remarcado', 'Remarcado a pedido do paciente'),
  (61, 8, 1, 15, '2026-06-24 17:00:00', 'realizado', NULL),
  (62, 7, 1, 14, '2026-06-25 13:00:00', 'realizado', NULL),
  (63, 14, 1, 24, '2026-06-26 08:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (64, 2, 1, 3, '2026-06-26 09:00:00', 'realizado', NULL),
  (65, 4, 1, 8, '2026-06-29 08:00:00', 'realizado', 'Retorno em 15 dias'),
  (66, 9, 1, 17, '2026-06-29 09:00:00', 'realizado', NULL),
  (67, 18, 1, NULL, '2026-06-29 10:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (68, 11, 1, 21, '2026-06-29 11:00:00', 'realizado', NULL),
  (69, 12, 1, NULL, '2026-06-29 15:00:00', 'realizado', NULL),
  (70, 10, 1, 19, '2026-06-29 16:00:00', 'realizado', NULL),
  (71, 1, 1, NULL, '2026-07-01 08:00:00', 'realizado', NULL),
  (72, 3, 1, NULL, '2026-07-01 17:00:00', 'remarcado', 'Remarcado a pedido do paciente'),
  (73, 17, 1, NULL, '2026-07-02 08:00:00', 'realizado', NULL),
  (74, 7, 1, 14, '2026-07-02 09:00:00', 'realizado', NULL),
  (75, 5, 1, NULL, '2026-07-02 13:00:00', 'realizado', NULL),
  (76, 15, 1, 26, '2026-07-02 14:00:00', 'realizado', 'Retorno em 15 dias'),
  (77, 16, 1, NULL, '2026-07-02 16:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (78, 14, 1, 24, '2026-07-03 09:00:00', 'realizado', NULL),
  (79, 11, 1, 21, '2026-07-06 09:00:00', 'nao_compareceu', 'Paciente não compareceu; contato feito por mensagem'),
  (80, 6, 1, NULL, '2026-07-06 14:00:00', 'nao_compareceu', 'Paciente não compareceu; contato feito por mensagem');

INSERT INTO agendamento (id_agendamento, id_paciente, id_dentista, id_tratamento, data_hora, status, observacoes) VALUES
  (81, 4, 1, 8, '2026-07-06 17:00:00', 'realizado', 'Orientado sobre higienização'),
  (82, 18, 1, NULL, '2026-07-07 13:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (83, 3, 1, NULL, '2026-07-07 15:00:00', 'realizado', NULL),
  (84, 15, 1, 26, '2026-07-08 08:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (85, 16, 1, NULL, '2026-07-08 14:00:00', 'realizado', NULL),
  (86, 2, 1, NULL, '2026-07-09 09:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (87, 9, 1, NULL, '2026-07-09 10:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (88, 14, 1, 24, '2026-07-09 13:00:00', 'nao_compareceu', 'Paciente não compareceu; contato feito por mensagem'),
  (89, 8, 1, NULL, '2026-07-10 11:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (90, 12, 1, NULL, '2026-07-10 13:00:00', 'realizado', 'Orientado sobre higienização'),
  (91, 11, 1, 21, '2026-07-13 11:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (92, 15, 1, 26, '2026-07-13 14:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (93, 7, 1, NULL, '2026-07-13 17:00:00', 'realizado', NULL),
  (94, 4, 1, 8, '2026-07-14 09:00:00', 'realizado', NULL),
  (95, 14, 1, 24, '2026-07-14 14:00:00', 'realizado', NULL),
  (96, 6, 1, NULL, '2026-07-15 10:00:00', 'realizado', NULL),
  (97, 1, 1, NULL, '2026-07-16 11:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (98, 18, 1, NULL, '2026-07-20 09:00:00', 'realizado', NULL),
  (99, 5, 1, NULL, '2026-07-20 13:00:00', 'realizado', NULL),
  (100, 2, 1, NULL, '2026-07-20 15:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (101, 10, 1, NULL, '2026-07-20 17:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (102, 17, 1, NULL, '2026-07-21 09:00:00', 'realizado', 'Retorno em 15 dias'),
  (103, 4, 1, 8, '2026-07-21 17:00:00', 'realizado', NULL),
  (104, 11, 1, 22, '2026-07-22 08:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (105, 9, 1, NULL, '2026-07-22 13:00:00', 'realizado', NULL),
  (106, 3, 1, 6, '2026-07-24 09:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (107, 16, 1, 28, '2026-07-27 09:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (108, 7, 1, NULL, '2026-07-27 10:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (109, 12, 1, NULL, '2026-07-27 13:00:00', 'realizado', NULL),
  (110, 10, 1, NULL, '2026-07-27 14:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (111, 8, 1, NULL, '2026-07-28 11:00:00', 'realizado', 'Orientado sobre higienização'),
  (112, 15, 1, NULL, '2026-07-29 14:00:00', 'nao_compareceu', 'Paciente não compareceu; contato feito por mensagem'),
  (113, 14, 1, 25, '2026-07-30 16:00:00', 'realizado', NULL),
  (114, 4, 1, NULL, '2026-07-31 10:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (115, 5, 1, 10, '2026-07-31 17:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (116, 15, 1, NULL, '2026-08-03 09:00:00', 'realizado', NULL),
  (117, 9, 1, NULL, '2026-08-03 10:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (118, 2, 1, NULL, '2026-08-03 11:00:00', 'realizado', NULL),
  (119, 6, 1, NULL, '2026-08-03 13:00:00', 'realizado', 'Orientado sobre higienização'),
  (120, 1, 1, NULL, '2026-08-03 15:00:00', 'realizado', NULL);

INSERT INTO agendamento (id_agendamento, id_paciente, id_dentista, id_tratamento, data_hora, status, observacoes) VALUES
  (121, 11, 1, 22, '2026-08-03 16:00:00', 'nao_compareceu', 'Paciente não compareceu; contato feito por mensagem'),
  (122, 3, 1, 6, '2026-08-03 17:00:00', 'realizado', 'Orientado sobre higienização'),
  (123, 16, 1, 28, '2026-08-05 15:00:00', 'realizado', NULL),
  (124, 7, 1, NULL, '2026-08-05 17:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (125, 4, 1, NULL, '2026-08-06 09:00:00', 'realizado', NULL),
  (126, 8, 1, NULL, '2026-08-07 08:00:00', 'realizado', NULL),
  (127, 18, 1, 29, '2026-08-07 17:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (128, 3, 1, 6, '2026-08-10 08:00:00', 'realizado', NULL),
  (129, 14, 1, 25, '2026-08-10 11:00:00', 'realizado', NULL),
  (130, 5, 1, 10, '2026-08-10 13:00:00', 'realizado', NULL),
  (131, 12, 1, NULL, '2026-08-10 15:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (132, 17, 1, NULL, '2026-08-10 16:00:00', 'remarcado', 'Remarcado a pedido do paciente'),
  (133, 11, 1, 22, '2026-08-11 09:00:00', 'realizado', NULL),
  (134, 16, 1, 28, '2026-08-11 13:00:00', 'nao_compareceu', 'Paciente não compareceu; contato feito por mensagem'),
  (135, 10, 1, NULL, '2026-08-13 15:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (136, 14, 1, 25, '2026-08-14 13:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (137, 5, 1, 10, '2026-08-17 08:00:00', 'realizado', NULL),
  (138, 2, 1, NULL, '2026-08-17 11:00:00', 'realizado', 'Orientado sobre higienização'),
  (139, 6, 1, NULL, '2026-08-17 14:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (140, 11, 1, 22, '2026-08-17 15:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (141, 18, 1, 29, '2026-08-17 16:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (142, 17, 1, NULL, '2026-08-18 10:00:00', 'realizado', 'Retorno em 15 dias'),
  (143, 15, 1, 27, '2026-08-18 17:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (144, 16, 1, 28, '2026-08-19 10:00:00', 'realizado', NULL),
  (145, 9, 1, NULL, '2026-08-19 13:00:00', 'remarcado', 'Remarcado a pedido do paciente'),
  (146, 4, 1, NULL, '2026-08-21 09:00:00', 'realizado', NULL),
  (147, 1, 1, NULL, '2026-08-21 13:00:00', 'realizado', NULL),
  (148, 3, 1, NULL, '2026-08-24 08:00:00', 'realizado', 'Orientado sobre higienização'),
  (149, 7, 1, NULL, '2026-08-24 10:00:00', 'realizado', NULL),
  (150, 8, 1, NULL, '2026-08-24 11:00:00', 'realizado', NULL),
  (151, 10, 1, NULL, '2026-08-24 14:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (152, 14, 1, 25, '2026-08-24 16:00:00', 'realizado', NULL),
  (153, 9, 1, NULL, '2026-08-26 13:00:00', 'realizado', 'Orientado sobre higienização'),
  (154, 11, 1, 22, '2026-08-26 15:00:00', 'realizado', NULL),
  (155, 2, 1, NULL, '2026-08-28 08:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (156, 15, 1, 27, '2026-08-28 10:00:00', 'realizado', NULL),
  (157, 10, 1, NULL, '2026-08-28 13:00:00', 'realizado', 'Orientado sobre higienização'),
  (158, 12, 1, NULL, '2026-08-31 08:00:00', 'realizado', NULL),
  (159, 1, 1, NULL, '2026-08-31 10:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (160, 14, 1, NULL, '2026-09-01 13:00:00', 'realizado', NULL);

INSERT INTO agendamento (id_agendamento, id_paciente, id_dentista, id_tratamento, data_hora, status, observacoes) VALUES
  (161, 6, 1, NULL, '2026-09-01 16:00:00', 'realizado', NULL),
  (162, 5, 1, NULL, '2026-09-02 14:00:00', 'realizado', NULL),
  (163, 18, 1, NULL, '2026-09-02 17:00:00', 'realizado', 'Orientado sobre higienização'),
  (164, 2, 1, NULL, '2026-09-07 08:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (165, 15, 1, 27, '2026-09-07 10:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (166, 9, 1, NULL, '2026-09-07 13:00:00', 'realizado', NULL),
  (167, 16, 1, NULL, '2026-09-07 15:00:00', 'realizado', NULL),
  (168, 3, 1, NULL, '2026-09-07 16:00:00', 'realizado', 'Orientado sobre higienização'),
  (169, 17, 1, NULL, '2026-09-07 17:00:00', 'nao_compareceu', 'Paciente não compareceu; contato feito por mensagem'),
  (170, 4, 1, NULL, '2026-09-08 09:00:00', 'realizado', NULL),
  (171, 10, 1, NULL, '2026-09-11 13:00:00', 'realizado', 'Orientado sobre higienização'),
  (172, 7, 1, NULL, '2026-09-14 09:00:00', 'realizado', NULL),
  (173, 8, 1, NULL, '2026-09-14 14:00:00', 'realizado', NULL),
  (174, 15, 1, 27, '2026-09-14 15:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (175, 11, 1, NULL, '2026-09-14 16:00:00', 'remarcado', 'Remarcado a pedido do paciente'),
  (176, 12, 1, NULL, '2026-09-15 09:00:00', 'realizado', NULL),
  (177, 1, 1, NULL, '2026-09-17 08:00:00', 'realizado', NULL),
  (178, 18, 1, NULL, '2026-09-17 09:00:00', 'nao_compareceu', 'Paciente não compareceu; contato feito por mensagem'),
  (179, 2, 1, NULL, '2026-09-17 17:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (180, 5, 1, NULL, '2026-09-18 10:00:00', 'realizado', NULL),
  (181, 6, 1, NULL, '2026-09-18 11:00:00', 'realizado', NULL),
  (182, 3, 1, NULL, '2026-09-18 14:00:00', 'realizado', NULL),
  (183, 14, 1, NULL, '2026-09-21 08:00:00', 'realizado', 'Retorno em 15 dias'),
  (184, 11, 1, NULL, '2026-09-21 10:00:00', 'realizado', 'Retorno em 15 dias'),
  (185, 7, 1, NULL, '2026-09-22 10:00:00', 'realizado', 'Retorno em 15 dias'),
  (186, 18, 1, NULL, '2026-09-22 13:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (187, 9, 1, NULL, '2026-09-22 14:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (188, 16, 1, NULL, '2026-09-22 17:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (189, 15, 1, 27, '2026-09-23 09:00:00', 'realizado', NULL),
  (190, 8, 1, NULL, '2026-09-25 14:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (191, 3, 1, NULL, '2026-09-28 15:00:00', 'remarcado', 'Remarcado a pedido do paciente'),
  (192, 4, 1, NULL, '2026-09-28 16:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (193, 10, 1, NULL, '2026-09-29 16:00:00', 'realizado', NULL),
  (194, 1, 1, NULL, '2026-09-30 13:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (195, 12, 1, NULL, '2026-09-30 14:00:00', 'realizado', 'Orientado sobre higienização'),
  (196, 5, 1, NULL, '2026-10-01 10:00:00', 'realizado', NULL),
  (197, 16, 1, NULL, '2026-10-01 15:00:00', 'realizado', 'Orientado sobre higienização'),
  (198, 6, 1, NULL, '2026-10-05 10:00:00', 'realizado', NULL),
  (199, 18, 1, NULL, '2026-10-05 14:00:00', 'realizado', NULL),
  (200, 3, 1, NULL, '2026-10-06 10:00:00', 'realizado', 'Retorno em 15 dias');

INSERT INTO agendamento (id_agendamento, id_paciente, id_dentista, id_tratamento, data_hora, status, observacoes) VALUES
  (201, 2, 1, 4, '2026-10-07 13:00:00', 'realizado', NULL),
  (202, 8, 1, 16, '2026-10-08 09:00:00', 'realizado', NULL),
  (203, 11, 1, NULL, '2026-10-08 17:00:00', 'realizado', 'Orientado sobre higienização'),
  (204, 7, 1, NULL, '2026-10-12 10:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (205, 9, 1, 18, '2026-10-12 11:00:00', 'realizado', 'Retorno em 15 dias'),
  (206, 15, 1, NULL, '2026-10-12 14:00:00', 'realizado', NULL),
  (207, 14, 1, NULL, '2026-10-12 17:00:00', 'realizado', NULL),
  (208, 12, 1, 23, '2026-10-14 14:00:00', 'remarcado', 'Remarcado a pedido do paciente'),
  (209, 2, 1, 4, '2026-10-14 15:00:00', 'realizado', 'Orientado sobre higienização'),
  (210, 16, 1, NULL, '2026-10-14 16:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (211, 4, 1, NULL, '2026-10-15 08:00:00', 'agendado', 'Atendimento não atualizado no sistema'),
  (212, 6, 1, 13, '2026-10-15 15:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (213, 8, 1, 16, '2026-10-15 16:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (214, 5, 1, 11, '2026-10-15 17:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (215, 18, 1, NULL, '2026-10-19 08:00:00', 'realizado', 'Paciente relatou sensibilidade'),
  (216, 10, 1, 20, '2026-10-19 11:00:00', 'cancelado', 'Cancelado pelo paciente; reagendamento oferecido'),
  (217, 11, 1, NULL, '2026-10-19 14:00:00', 'realizado', NULL),
  (218, 1, 1, 2, '2026-10-19 17:00:00', 'realizado', 'Orientado sobre higienização'),
  (219, 9, 1, 18, '2026-10-20 15:00:00', 'nao_compareceu', 'Paciente não compareceu; contato feito por mensagem'),
  (220, 6, 1, 13, '2026-10-22 15:00:00', 'agendado', 'Atendimento não atualizado no sistema'),
  (221, 3, 1, NULL, '2026-10-26 08:00:00', 'agendado', NULL),
  (222, 12, 1, 23, '2026-10-26 09:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (223, 2, 1, 4, '2026-10-26 10:00:00', 'realizado', NULL),
  (224, 14, 1, NULL, '2026-10-26 11:00:00', 'agendado', NULL),
  (225, 8, 1, 16, '2026-10-26 13:00:00', 'realizado', NULL),
  (226, 16, 1, NULL, '2026-10-26 14:00:00', 'realizado', 'Pagamento combinado no atendimento'),
  (227, 10, 1, 20, '2026-10-26 15:00:00', 'realizado', 'Orientado sobre higienização'),
  (228, 5, 1, 11, '2026-10-26 16:00:00', 'realizado', NULL),
  (229, 18, 1, 30, '2026-10-27 08:00:00', 'agendado', NULL),
  (230, 7, 1, NULL, '2026-10-28 10:00:00', 'agendado', NULL),
  (231, 1, 1, 2, '2026-10-29 11:00:00', 'agendado', NULL),
  (232, 9, 1, 18, '2026-10-29 16:00:00', 'agendado', NULL),
  (233, 10, 1, 20, '2026-10-30 13:00:00', 'agendado', NULL);

INSERT INTO procedimento_realizado (id_agendamento, id_procedimento, preco_praticado, observacoes) VALUES
  (8, 2, 500.00, NULL),
  (8, 5, 2720.00, NULL),
  (10, 1, 170.00, NULL),
  (15, 2, 450.00, NULL),
  (15, 5, 3200.00, NULL),
  (17, 7, 300.00, NULL),
  (19, 6, 450.00, NULL),
  (20, 4, 240.00, NULL),
  (23, 3, 180.00, NULL),
  (24, 4, 226.67, NULL),
  (26, 7, 300.00, NULL),
  (27, 6, 450.00, NULL),
  (28, 4, 240.00, NULL),
  (29, 1, 170.00, NULL),
  (30, 3, 171.00, NULL),
  (34, 7, 300.00, NULL),
  (36, 4, 240.00, NULL),
  (37, 6, 450.00, NULL),
  (39, 6, 810.00, NULL),
  (40, 6, 450.00, NULL),
  (41, 4, 240.00, NULL),
  (42, 4, 226.67, NULL),
  (43, 2, 475.00, NULL),
  (45, 2, 500.00, NULL),
  (45, 5, 3200.00, NULL),
  (47, 7, 333.33, NULL),
  (48, 6, 900.00, NULL),
  (49, 6, 810.00, NULL),
  (50, 6, 450.00, NULL),
  (52, 4, 240.00, NULL),
  (53, 6, 450.00, NULL),
  (54, 1, 190.00, NULL),
  (55, 7, 333.33, NULL),
  (56, 3, 162.00, NULL),
  (57, 3, 180.00, NULL),
  (58, 4, 226.67, NULL),
  (61, 3, 153.00, NULL),
  (62, 6, 450.00, NULL),
  (63, 4, 240.00, NULL),
  (64, 6, 900.00, NULL);

INSERT INTO procedimento_realizado (id_agendamento, id_procedimento, preco_praticado, observacoes) VALUES
  (65, 6, 450.00, NULL),
  (66, 4, 240.00, NULL),
  (68, 6, 900.00, NULL),
  (69, 1, 200.00, NULL),
  (70, 7, 333.33, NULL),
  (71, 1, 200.00, NULL),
  (73, 3, 153.00, NULL),
  (74, 6, 450.00, NULL),
  (75, 1, 190.00, NULL),
  (76, 2, 450.00, NULL),
  (78, 4, 240.00, NULL),
  (81, 6, 450.00, NULL),
  (83, 1, 200.00, NULL),
  (85, 1, 180.00, NULL),
  (86, 1, 170.00, NULL),
  (87, 1, 150.00, NULL),
  (89, 3, 153.00, NULL),
  (90, 3, 162.00, NULL),
  (91, 6, 900.00, NULL),
  (92, 3, 171.00, NULL),
  (93, 1, 200.00, NULL),
  (94, 6, 450.00, NULL),
  (95, 4, 240.00, NULL),
  (96, 3, 180.00, NULL),
  (97, 3, 171.00, NULL),
  (98, 1, 200.00, NULL),
  (99, 3, 180.00, NULL),
  (100, 3, 180.00, NULL),
  (102, 1, 190.00, NULL),
  (103, 6, 450.00, NULL),
  (104, 6, 450.00, NULL),
  (105, 1, 150.00, NULL),
  (106, 7, 333.33, NULL),
  (107, 7, 333.33, NULL),
  (109, 1, 200.00, NULL),
  (110, 1, 200.00, NULL),
  (111, 1, 200.00, NULL),
  (113, 7, 316.67, NULL),
  (115, 4, 200.00, NULL),
  (116, 1, 200.00, NULL);

INSERT INTO procedimento_realizado (id_agendamento, id_procedimento, preco_praticado, observacoes) VALUES
  (117, 3, 180.00, NULL),
  (118, 1, 170.00, NULL),
  (119, 1, 200.00, NULL),
  (120, 1, 200.00, NULL),
  (122, 7, 333.33, NULL),
  (123, 7, 333.33, NULL),
  (124, 3, 162.00, NULL),
  (125, 1, 170.00, NULL),
  (126, 3, 153.00, NULL),
  (127, 2, 450.00, NULL),
  (128, 7, 333.33, NULL),
  (129, 7, 316.67, NULL),
  (130, 4, 200.00, NULL),
  (131, 3, 162.00, NULL),
  (133, 6, 450.00, NULL),
  (135, 3, 135.00, NULL),
  (137, 4, 200.00, NULL),
  (138, 3, 180.00, NULL),
  (139, 3, 180.00, NULL),
  (140, 6, 450.00, NULL),
  (141, 3, 135.00, NULL),
  (142, 3, 153.00, NULL),
  (144, 7, 333.33, NULL),
  (146, 3, 180.00, NULL),
  (147, 3, 171.00, NULL),
  (148, 1, 200.00, NULL),
  (149, 1, 200.00, NULL),
  (150, 1, 200.00, NULL),
  (152, 7, 316.67, NULL),
  (153, 1, 150.00, NULL),
  (154, 6, 450.00, NULL),
  (156, 6, 450.00, NULL),
  (157, 1, 200.00, NULL),
  (158, 1, 200.00, NULL),
  (159, 1, 200.00, NULL),
  (160, 1, 200.00, NULL),
  (161, 1, 200.00, NULL),
  (162, 1, 190.00, NULL),
  (163, 1, 200.00, NULL),
  (164, 3, 180.00, NULL);

INSERT INTO procedimento_realizado (id_agendamento, id_procedimento, preco_praticado, observacoes) VALUES
  (165, 6, 450.00, NULL),
  (166, 3, 180.00, NULL),
  (167, 1, 180.00, NULL),
  (168, 3, 180.00, NULL),
  (170, 1, 170.00, NULL),
  (171, 3, 135.00, NULL),
  (172, 3, 162.00, NULL),
  (173, 3, 153.00, NULL),
  (174, 6, 450.00, NULL),
  (176, 3, 162.00, NULL),
  (177, 3, 171.00, NULL),
  (179, 1, 170.00, NULL),
  (180, 3, 180.00, NULL),
  (181, 3, 180.00, NULL),
  (182, 1, 200.00, NULL),
  (183, 3, 180.00, NULL),
  (184, 1, 170.00, NULL),
  (185, 1, 200.00, NULL),
  (186, 3, 135.00, NULL),
  (187, 1, 150.00, NULL),
  (189, 6, 450.00, NULL),
  (190, 1, 200.00, NULL),
  (192, 3, 180.00, NULL),
  (193, 1, 200.00, NULL),
  (194, 1, 200.00, NULL),
  (195, 1, 200.00, NULL),
  (196, 1, 190.00, NULL),
  (197, 3, 135.00, NULL),
  (198, 1, 200.00, NULL),
  (199, 3, 135.00, NULL),
  (200, 3, 180.00, NULL),
  (201, 7, 333.33, NULL),
  (202, 7, 333.33, NULL),
  (203, 3, 180.00, NULL),
  (204, 3, 162.00, NULL),
  (205, 7, 750.00, NULL),
  (206, 3, 171.00, NULL),
  (207, 1, 200.00, NULL),
  (209, 7, 333.33, NULL),
  (210, 1, 180.00, NULL);

INSERT INTO procedimento_realizado (id_agendamento, id_procedimento, preco_praticado, observacoes) VALUES
  (212, 7, 950.00, NULL),
  (213, 7, 333.33, NULL),
  (214, 7, 450.00, NULL),
  (215, 1, 200.00, NULL),
  (217, 1, 170.00, NULL),
  (218, 7, 900.00, NULL),
  (222, 7, 1000.00, NULL),
  (223, 7, 333.33, NULL),
  (225, 7, 333.33, NULL),
  (226, 3, 135.00, NULL),
  (227, 7, 1000.00, NULL),
  (228, 7, 450.00, NULL);

INSERT INTO pagamento (id_pagamento, id_agendamento, valor, forma_pagamento, status) VALUES
  (1, 8, 3220.00, 'debito', 'pago'),
  (2, 10, 170.00, 'pix', 'pago'),
  (3, 15, 3650.00, 'pix', 'pago'),
  (4, 17, 300.00, 'pix', 'pago'),
  (5, 19, 450.00, 'pix', 'pendente'),
  (6, 20, 240.00, 'debito', 'pago'),
  (7, 23, 180.00, 'pix', 'pago'),
  (8, 24, 226.67, 'debito', 'pago'),
  (9, 26, 300.00, 'pix', 'pago'),
  (10, 27, 225.00, 'credito', 'pago'),
  (11, 27, 225.00, 'credito', 'pago'),
  (12, 28, 240.00, 'credito', 'pago'),
  (13, 29, 170.00, 'credito', 'pago'),
  (14, 30, 171.00, 'pix', 'pago'),
  (15, 34, 300.00, 'credito', 'pago'),
  (16, 36, 240.00, 'pix', 'pendente'),
  (17, 37, 450.00, 'credito', 'pago'),
  (18, 39, 810.00, 'debito', 'pago'),
  (19, 40, 450.00, 'dinheiro', 'pago'),
  (20, 41, 240.00, 'credito', 'pendente'),
  (21, 42, 226.67, 'credito', 'pago'),
  (22, 43, 475.00, 'dinheiro', 'pago'),
  (23, 45, 3700.00, 'dinheiro', 'pago'),
  (24, 47, 333.33, 'credito', 'pago'),
  (25, 48, 450.00, 'credito', 'pago'),
  (26, 48, 450.00, 'credito', 'pago'),
  (27, 49, 405.00, 'credito', 'pago'),
  (28, 49, 405.00, 'credito', 'pago'),
  (29, 50, 225.00, 'pix', 'pago'),
  (30, 50, 225.00, 'pix', 'pago'),
  (31, 52, 240.00, 'pix', 'pago'),
  (32, 53, 225.00, 'credito', 'pago'),
  (33, 53, 225.00, 'credito', 'pago'),
  (34, 54, 190.00, 'credito', 'pago'),
  (35, 55, 333.33, 'pix', 'pago'),
  (36, 56, 162.00, 'debito', 'pago'),
  (37, 57, 180.00, 'debito', 'pago'),
  (38, 58, 226.67, 'pix', 'pendente'),
  (39, 61, 153.00, 'pix', 'pago'),
  (40, 62, 225.00, 'credito', 'pago');

INSERT INTO pagamento (id_pagamento, id_agendamento, valor, forma_pagamento, status) VALUES
  (41, 62, 225.00, 'credito', 'pago'),
  (42, 63, 240.00, 'credito', 'pago'),
  (43, 64, 450.00, 'pix', 'pago'),
  (44, 64, 450.00, 'pix', 'pago'),
  (45, 65, 225.00, 'credito', 'pago'),
  (46, 65, 225.00, 'credito', 'pago'),
  (47, 66, 240.00, 'debito', 'pago'),
  (48, 68, 450.00, 'credito', 'pago'),
  (49, 68, 450.00, 'credito', 'pago'),
  (50, 69, 200.00, 'credito', 'pago'),
  (51, 70, 333.33, 'pix', 'pago'),
  (52, 71, 200.00, 'debito', 'pago'),
  (53, 73, 153.00, 'pix', 'pago'),
  (54, 74, 450.00, 'debito', 'pago'),
  (55, 75, 190.00, 'credito', 'pago'),
  (56, 76, 225.00, 'credito', 'pago'),
  (57, 76, 225.00, 'credito', 'pago'),
  (58, 78, 240.00, 'pix', 'pago'),
  (59, 81, 225.00, 'credito', 'pago'),
  (60, 81, 225.00, 'credito', 'pago'),
  (61, 83, 200.00, 'pix', 'pago'),
  (62, 85, 180.00, 'dinheiro', 'pago'),
  (63, 86, 170.00, 'pix', 'pago'),
  (64, 87, 150.00, 'pix', 'pago'),
  (65, 89, 153.00, 'debito', 'pago'),
  (66, 90, 162.00, 'credito', 'pago'),
  (67, 91, 900.00, 'debito', 'pago'),
  (68, 92, 171.00, 'pix', 'pago'),
  (69, 93, 200.00, 'pix', 'pago'),
  (70, 94, 225.00, 'pix', 'pago'),
  (71, 94, 225.00, 'pix', 'pago'),
  (72, 95, 240.00, 'credito', 'pago'),
  (73, 96, 180.00, 'pix', 'pago'),
  (74, 97, 171.00, 'pix', 'pago'),
  (75, 98, 200.00, 'pix', 'pago'),
  (76, 99, 180.00, 'pix', 'pago'),
  (77, 100, 180.00, 'pix', 'pago'),
  (78, 102, 190.00, 'dinheiro', 'pago'),
  (79, 103, 225.00, 'credito', 'pago'),
  (80, 103, 225.00, 'credito', 'pendente');

INSERT INTO pagamento (id_pagamento, id_agendamento, valor, forma_pagamento, status) VALUES
  (81, 104, 450.00, 'pix', 'pago'),
  (82, 105, 150.00, 'debito', 'pago'),
  (83, 106, 333.33, 'credito', 'pago'),
  (84, 107, 333.33, 'dinheiro', 'pago'),
  (85, 109, 200.00, 'pix', 'pago'),
  (86, 110, 200.00, 'pix', 'pago'),
  (87, 111, 200.00, 'credito', 'pago'),
  (88, 113, 316.67, 'pix', 'pago'),
  (89, 115, 200.00, 'pix', 'pago'),
  (90, 116, 200.00, 'pix', 'pago'),
  (91, 117, 180.00, 'credito', 'pago'),
  (92, 118, 170.00, 'debito', 'pago'),
  (93, 119, 200.00, 'debito', 'pago'),
  (94, 120, 200.00, 'pix', 'pago'),
  (95, 122, 333.33, 'pix', 'pago'),
  (96, 123, 333.33, 'debito', 'pago'),
  (97, 124, 162.00, 'debito', 'pago'),
  (98, 125, 170.00, 'pix', 'pago'),
  (99, 126, 153.00, 'debito', 'pago'),
  (100, 127, 450.00, 'dinheiro', 'pago'),
  (101, 128, 333.33, 'credito', 'pago'),
  (102, 129, 316.67, 'credito', 'pago'),
  (103, 130, 200.00, 'pix', 'pago'),
  (104, 131, 162.00, 'debito', 'pago'),
  (105, 133, 450.00, 'pix', 'pago'),
  (106, 135, 135.00, 'pix', 'pago'),
  (107, 137, 200.00, 'pix', 'pago'),
  (108, 138, 180.00, 'debito', 'pago'),
  (109, 139, 180.00, 'pix', 'pago'),
  (110, 140, 225.00, 'pix', 'pago'),
  (111, 140, 225.00, 'pix', 'pago'),
  (112, 141, 135.00, 'pix', 'pago'),
  (113, 142, 153.00, 'credito', 'pago'),
  (114, 144, 333.33, 'pix', 'pago'),
  (115, 146, 180.00, 'pix', 'pago'),
  (116, 147, 171.00, 'credito', 'pago'),
  (117, 148, 200.00, 'pix', 'pago'),
  (118, 149, 200.00, 'credito', 'pago'),
  (119, 150, 200.00, 'credito', 'pago'),
  (120, 152, 316.67, 'credito', 'pago');

INSERT INTO pagamento (id_pagamento, id_agendamento, valor, forma_pagamento, status) VALUES
  (121, 153, 150.00, 'credito', 'pago'),
  (122, 154, 450.00, 'credito', 'pago'),
  (123, 156, 450.00, 'pix', 'pago'),
  (124, 157, 200.00, 'debito', 'pago'),
  (125, 158, 200.00, 'credito', 'pago'),
  (126, 159, 200.00, 'debito', 'pago'),
  (127, 160, 200.00, 'pix', 'pago'),
  (128, 161, 200.00, 'debito', 'pago'),
  (129, 162, 190.00, 'pix', 'pago'),
  (130, 163, 200.00, 'pix', 'pago'),
  (131, 164, 180.00, 'dinheiro', 'pago'),
  (132, 165, 450.00, 'pix', 'pago'),
  (133, 166, 180.00, 'credito', 'pago'),
  (134, 167, 180.00, 'pix', 'pago'),
  (135, 168, 180.00, 'dinheiro', 'pago'),
  (136, 170, 170.00, 'dinheiro', 'pago'),
  (137, 171, 135.00, 'dinheiro', 'pago'),
  (138, 172, 162.00, 'pix', 'pago'),
  (139, 173, 153.00, 'credito', 'pago'),
  (140, 174, 450.00, 'debito', 'pago'),
  (141, 176, 162.00, 'dinheiro', 'pago'),
  (142, 177, 171.00, 'pix', 'pago'),
  (143, 179, 170.00, 'pix', 'pago'),
  (144, 180, 180.00, 'credito', 'pago'),
  (145, 181, 180.00, 'pix', 'pago'),
  (146, 182, 200.00, 'pix', 'pago'),
  (147, 183, 180.00, 'debito', 'pago'),
  (148, 184, 170.00, 'dinheiro', 'pago'),
  (149, 185, 200.00, 'pix', 'pago'),
  (150, 186, 135.00, 'credito', 'pago'),
  (151, 187, 150.00, 'dinheiro', 'pendente'),
  (152, 189, 225.00, 'credito', 'pago'),
  (153, 189, 225.00, 'credito', 'pendente'),
  (154, 190, 200.00, 'pix', 'pago'),
  (155, 192, 180.00, 'pix', 'pago'),
  (156, 193, 200.00, 'credito', 'pago'),
  (157, 194, 200.00, 'debito', 'pago'),
  (158, 195, 200.00, 'credito', 'pago'),
  (159, 196, 190.00, 'pix', 'pago'),
  (160, 197, 135.00, 'dinheiro', 'pago');

INSERT INTO pagamento (id_pagamento, id_agendamento, valor, forma_pagamento, status) VALUES
  (161, 198, 200.00, 'pix', 'pago'),
  (162, 199, 135.00, 'credito', 'pago'),
  (163, 200, 180.00, 'pix', 'pago'),
  (164, 201, 333.33, 'debito', 'pago'),
  (165, 202, 333.33, 'pix', 'pago'),
  (166, 203, 180.00, 'credito', 'pago'),
  (167, 204, 162.00, 'dinheiro', 'pago'),
  (168, 205, 375.00, 'pix', 'pago'),
  (169, 205, 375.00, 'pix', 'pendente'),
  (170, 206, 171.00, 'pix', 'pago'),
  (171, 207, 200.00, 'pix', 'pago'),
  (172, 209, 333.33, 'debito', 'pago'),
  (173, 210, 180.00, 'credito', 'pago'),
  (174, 212, 475.00, 'credito', 'pago'),
  (175, 212, 475.00, 'credito', 'pendente'),
  (176, 213, 333.33, 'debito', 'pago'),
  (177, 214, 225.00, 'credito', 'pago'),
  (178, 214, 225.00, 'credito', 'pendente'),
  (179, 215, 200.00, 'debito', 'pago'),
  (180, 217, 170.00, 'dinheiro', 'pago'),
  (181, 218, 450.00, 'credito', 'pago'),
  (182, 218, 450.00, 'credito', 'pendente'),
  (183, 222, 500.00, 'credito', 'pago'),
  (184, 222, 500.00, 'credito', 'pendente'),
  (185, 223, 333.33, 'pix', 'pago'),
  (186, 225, 333.33, 'pix', 'pago'),
  (187, 226, 135.00, 'dinheiro', 'pago'),
  (188, 227, 500.00, 'credito', 'pago'),
  (189, 227, 500.00, 'credito', 'pendente'),
  (190, 228, 450.00, 'credito', 'pago');

INSERT INTO despesa (id_despesa, id_categoria_despesa, id_tratamento, descricao, valor, data_vencimento, data_pagamento, status) VALUES
  (1, 1, NULL, 'Aluguel da sala', 3200.00, '2026-05-05', '2026-05-05', 'paga'),
  (2, 2, NULL, 'Energia elétrica 05/2026', 448.00, '2026-05-10', '2026-05-13', 'paga'),
  (3, 6, NULL, 'Parcela de empréstimo da clínica', 1100.00, '2026-05-15', '2026-05-18', 'paga'),
  (4, 4, 1, 'Laboratório de prótese', 345.00, '2026-05-18', '2026-05-21', 'paga'),
  (5, 3, NULL, 'Impostos 05/2026', 888.00, '2026-05-20', '2026-05-21', 'paga'),
  (6, 5, 1, 'Material dental (resina, anestésico, descartáveis)', 503.00, '2026-05-24', '2026-05-25', 'paga'),
  (7, 5, NULL, 'Material dental (resina, anestésico, descartáveis)', 169.00, '2026-05-24', '2026-05-24', 'paga'),
  (8, 1, NULL, 'Aluguel da sala', 3200.00, '2026-06-05', '2026-06-03', 'paga'),
  (9, 5, NULL, 'Material dental (resina, anestésico, descartáveis)', 163.00, '2026-06-05', '2026-06-05', 'paga'),
  (10, 2, NULL, 'Energia elétrica 06/2026', 435.00, '2026-06-10', '2026-06-12', 'paga'),
  (11, 6, NULL, 'Parcela de empréstimo da clínica', 1100.00, '2026-06-15', '2026-06-17', 'paga'),
  (12, 4, 3, 'Laboratório de prótese', 797.00, '2026-06-16', '2026-06-16', 'paga'),
  (13, 7, NULL, 'Gasto eventual (manutenção de equipamento)', 265.00, '2026-06-18', '2026-06-20', 'paga'),
  (14, 5, 21, 'Material dental (resina, anestésico, descartáveis)', 639.00, '2026-06-19', '2026-06-22', 'paga'),
  (15, 3, NULL, 'Impostos 06/2026', 777.00, '2026-06-20', NULL, 'pendente'),
  (16, 1, NULL, 'Aluguel da sala', 3200.00, '2026-07-05', '2026-07-04', 'paga'),
  (17, 5, NULL, 'Material dental (resina, anestésico, descartáveis)', 518.00, '2026-07-09', '2026-07-11', 'paga'),
  (18, 2, NULL, 'Energia elétrica 07/2026', 391.00, '2026-07-10', '2026-07-08', 'paga'),
  (19, 6, NULL, 'Parcela de empréstimo da clínica', 1100.00, '2026-07-15', '2026-07-13', 'paga'),
  (20, 3, NULL, 'Impostos 07/2026', 806.00, '2026-07-20', '2026-07-21', 'paga'),
  (21, 4, 8, 'Laboratório de prótese', 448.00, '2026-07-20', '2026-07-21', 'paga'),
  (22, 5, 3, 'Material dental (resina, anestésico, descartáveis)', 479.00, '2026-07-21', '2026-07-20', 'paga'),
  (23, 1, NULL, 'Aluguel da sala', 3200.00, '2026-08-05', '2026-08-04', 'paga'),
  (24, 2, NULL, 'Energia elétrica 08/2026', 430.00, '2026-08-10', '2026-08-09', 'paga'),
  (25, 5, NULL, 'Material dental (resina, anestésico, descartáveis)', 259.00, '2026-08-10', '2026-08-09', 'paga'),
  (26, 7, NULL, 'Gasto eventual (manutenção de equipamento)', 348.00, '2026-08-12', '2026-08-10', 'paga'),
  (27, 6, NULL, 'Parcela de empréstimo da clínica', 1100.00, '2026-08-15', '2026-08-18', 'paga'),
  (28, 3, NULL, 'Impostos 08/2026', 771.00, '2026-08-20', '2026-08-21', 'paga'),
  (29, 4, 14, 'Laboratório de prótese', 499.00, '2026-08-20', '2026-08-21', 'paga'),
  (30, 5, NULL, 'Material dental (resina, anestésico, descartáveis)', 661.00, '2026-08-20', '2026-08-22', 'paga'),
  (31, 1, NULL, 'Aluguel da sala', 3200.00, '2026-09-05', '2026-09-06', 'paga'),
  (32, 2, NULL, 'Energia elétrica 09/2026', 476.00, '2026-09-10', NULL, 'pendente'),
  (33, 5, NULL, 'Material dental (resina, anestésico, descartáveis)', 298.00, '2026-09-14', '2026-09-15', 'paga'),
  (34, 6, NULL, 'Parcela de empréstimo da clínica', 1100.00, '2026-09-15', NULL, 'pendente'),
  (35, 3, NULL, 'Impostos 09/2026', 886.00, '2026-09-20', '2026-09-22', 'paga'),
  (36, 5, 5, 'Material dental (resina, anestésico, descartáveis)', 609.00, '2026-09-22', '2026-09-21', 'paga'),
  (37, 7, NULL, 'Gasto eventual (manutenção de equipamento)', 281.00, '2026-09-23', '2026-09-25', 'paga'),
  (38, 4, 8, 'Laboratório de prótese', 585.00, '2026-09-24', '2026-09-22', 'paga'),
  (39, 1, NULL, 'Aluguel da sala', 3200.00, '2026-10-05', '2026-10-06', 'paga'),
  (40, 5, 9, 'Material dental (resina, anestésico, descartáveis)', 195.00, '2026-10-05', NULL, 'pendente');

INSERT INTO despesa (id_despesa, id_categoria_despesa, id_tratamento, descricao, valor, data_vencimento, data_pagamento, status) VALUES
  (41, 2, NULL, 'Energia elétrica 10/2026', 476.00, '2026-10-10', NULL, 'pendente'),
  (42, 7, NULL, 'Gasto eventual (manutenção de equipamento)', 407.00, '2026-10-14', '2026-10-13', 'paga'),
  (43, 6, NULL, 'Parcela de empréstimo da clínica', 1100.00, '2026-10-15', '2026-10-15', 'paga'),
  (44, 5, NULL, 'Material dental (resina, anestésico, descartáveis)', 280.00, '2026-10-19', '2026-10-22', 'paga'),
  (45, 3, NULL, 'Impostos 10/2026', 773.00, '2026-10-20', NULL, 'pendente'),
  (46, 4, 14, 'Laboratório de prótese', 791.00, '2026-10-25', NULL, 'pendente'),
  (47, 1, NULL, 'Aluguel da sala', 3200.00, '2026-11-05', NULL, 'pendente'),
  (48, 2, NULL, 'Energia elétrica 11/2026', 381.00, '2026-11-10', NULL, 'pendente'),
  (49, 6, NULL, 'Parcela de empréstimo da clínica', 1100.00, '2026-11-15', NULL, 'pendente'),
  (50, 3, NULL, 'Impostos 11/2026', 823.00, '2026-11-20', NULL, 'pendente');


-- ---------------------------------------------------------------------
-- 5. SELECT com JOIN (consultas que cruzam várias tabelas)
-- ---------------------------------------------------------------------
SET @dia = '2026-09-07';

-- J01 — Qual é a agenda do dia, com paciente, dentista e tratamento?
SELECT a.id_agendamento, TIME(a.data_hora) AS hora, p.nome AS paciente, d.nome AS dentista,
       a.status, COALESCE(t.nome, 'sem tratamento') AS tratamento
FROM agendamento a
JOIN paciente p      ON p.id_paciente = a.id_paciente
JOIN dentista d      ON d.id_dentista = a.id_dentista
LEFT JOIN tratamento t ON t.id_tratamento = a.id_tratamento
WHERE DATE(a.data_hora) = @dia
ORDER BY a.data_hora;

-- J02 — Quais procedimentos foram feitos em um agendamento, com preço base e preço praticado?
SET @ag = (SELECT id_agendamento FROM procedimento_realizado GROUP BY id_agendamento HAVING COUNT(*) > 1 ORDER BY id_agendamento LIMIT 1);
SELECT a.id_agendamento, p.nome AS paciente, pr.nome AS procedimento, pr.preco_base, pra.preco_praticado
FROM procedimento_realizado pra
JOIN agendamento a   ON a.id_agendamento = pra.id_agendamento
JOIN paciente p      ON p.id_paciente = a.id_paciente
JOIN procedimento pr ON pr.id_procedimento = pra.id_procedimento
WHERE a.id_agendamento = @ag;

-- J03 — Quais são os telefones e o convênio de cada paciente?
SELECT p.id_paciente, p.nome,
       GROUP_CONCAT(DISTINCT t.numero ORDER BY t.numero SEPARATOR ', ') AS telefones,
       COALESCE(c.nome, 'Particular') AS convenio
FROM paciente p
LEFT JOIN telefone t           ON t.id_paciente = p.id_paciente
LEFT JOIN paciente_convenio pc ON pc.id_paciente = p.id_paciente
LEFT JOIN convenio c           ON c.id_convenio = pc.id_convenio
GROUP BY p.id_paciente, p.nome, c.nome
ORDER BY p.nome;

-- J04 — Quais especialidades cada dentista possui?
SELECT d.nome AS dentista, GROUP_CONCAT(e.nome ORDER BY e.nome SEPARATOR ', ') AS especialidades
FROM dentista d
JOIN dentista_especialidade de ON de.id_dentista = d.id_dentista
JOIN especialidade e           ON e.id_especialidade = de.id_especialidade
GROUP BY d.id_dentista, d.nome;

-- J05 — Quais despesas existem, com categoria e tratamento relacionado (quando houver)?
SELECT x.id_despesa, c.nome AS categoria, x.descricao, x.valor, x.data_vencimento, x.status,
       COALESCE(t.nome, '—') AS tratamento
FROM despesa x
JOIN categoria_despesa c ON c.id_categoria_despesa = x.id_categoria_despesa
LEFT JOIN tratamento t   ON t.id_tratamento = x.id_tratamento
ORDER BY x.data_vencimento DESC, x.id_despesa DESC
LIMIT 15;

-- ---------------------------------------------------------------------
-- 6. UPDATE
--    Cada bloco roda dentro de uma transação com ROLLBACK ao final, para
--    demonstrar o comando sem alterar a massa de dados usada nas consultas.
-- ---------------------------------------------------------------------
START TRANSACTION;

-- U01 — Dar baixa em um pagamento pendente (a clínica recebeu o valor).
SET @pg = (SELECT MIN(id_pagamento) FROM pagamento WHERE status = 'pendente');
SELECT id_pagamento, valor, status FROM pagamento WHERE id_pagamento = @pg;   -- antes
UPDATE pagamento SET status = 'pago' WHERE id_pagamento = @pg;
SELECT id_pagamento, valor, status FROM pagamento WHERE id_pagamento = @pg;   -- depois

-- U02 — Cancelar o próximo agendamento futuro e registrar que o reagendamento foi oferecido (RN04).
SET @ag_fut = (SELECT MIN(id_agendamento) FROM agendamento WHERE status = 'agendado' AND data_hora > @hoje);
SELECT id_agendamento, data_hora, status FROM agendamento WHERE id_agendamento = @ag_fut;   -- antes
UPDATE agendamento
   SET status = 'cancelado', observacoes = 'Cancelado pelo paciente; reagendamento oferecido'
 WHERE id_agendamento = @ag_fut;
SELECT id_agendamento, data_hora, status, observacoes FROM agendamento WHERE id_agendamento = @ag_fut;   -- depois

-- U03 — Dar baixa em uma despesa pendente (conta paga hoje).
SET @ds = (SELECT MIN(id_despesa) FROM despesa WHERE status = 'pendente');
SELECT id_despesa, valor, status, data_pagamento FROM despesa WHERE id_despesa = @ds;   -- antes
UPDATE despesa SET status = 'paga', data_pagamento = @hoje WHERE id_despesa = @ds;
SELECT id_despesa, valor, status, data_pagamento FROM despesa WHERE id_despesa = @ds;   -- depois

ROLLBACK;

-- ---------------------------------------------------------------------
-- 7. DELETE
--    Pela RN20, pacientes, tratamentos e agendamentos nunca são excluídos
--    (as FK usam ON DELETE RESTRICT). Só se exclui lançamento feito por engano.
-- ---------------------------------------------------------------------
START TRANSACTION;

-- D01 — Excluir uma despesa lançada em duplicidade.
INSERT INTO despesa (id_categoria_despesa, descricao, valor, data_vencimento, status)
VALUES (7, 'Lançamento duplicado (teste de exclusão)', 90.00, '2026-10-24', 'pendente');
SELECT id_despesa, descricao, valor FROM despesa WHERE descricao LIKE 'Lançamento duplicado%';   -- antes
DELETE FROM despesa WHERE descricao = 'Lançamento duplicado (teste de exclusão)';
SELECT COUNT(*) AS lancamentos_duplicados_restantes FROM despesa WHERE descricao LIKE 'Lançamento duplicado%';   -- depois

ROLLBACK;

-- Exemplo (não executado): excluir um paciente que tem agendamentos é bloqueado pela FK.
-- DELETE FROM paciente WHERE id_paciente = 1;   -- erro 1451: a row cannot be deleted (RN20)

-- ---------------------------------------------------------------------
-- 8. CONSULTAS GERENCIAIS
--    Problemas: P1 prontuário só em papel; P2 agendamento manual; P3 pagamentos
--    sem registro; P4 busca lenta de pacientes e financeiro; P5 captação de
--    clientes (parcial: o modelo não registra a origem do paciente);
--    P6 despesas em planilha separada.
-- ---------------------------------------------------------------------

-- G01 — Quanto a clínica recebeu por mês e por forma de pagamento?
-- Atende: P3 (pagamentos sem registro) e P4 (financeiro). KPI: faturamento mensal
-- Obs.: o modelo não guarda a data do pagamento; usa-se a data do agendamento.
SELECT DATE_FORMAT(a.data_hora, '%Y-%m') AS mes, p.forma_pagamento,
       COUNT(*) AS qtd_pagamentos, SUM(p.valor) AS total_recebido
FROM pagamento p
JOIN agendamento a ON a.id_agendamento = p.id_agendamento
WHERE p.status = 'pago'
GROUP BY mes, p.forma_pagamento
ORDER BY mes, total_recebido DESC;

-- G02 — Quais pacientes têm pagamentos pendentes e quanto devem?
-- Atende: P3 (controle de pendências) e P4 (acesso rápido ao financeiro). KPI: valor a receber
SELECT pa.id_paciente, pa.nome, COUNT(*) AS parcelas_pendentes, SUM(p.valor) AS total_pendente,
       MIN(DATE(a.data_hora)) AS pendente_desde
FROM pagamento p
JOIN agendamento a ON a.id_agendamento = p.id_agendamento
JOIN paciente pa   ON pa.id_paciente = a.id_paciente
WHERE p.status = 'pendente'
GROUP BY pa.id_paciente, pa.nome
ORDER BY total_pendente DESC;

-- G03 — Quantos atendimentos foram realizados por semana?
-- Atende: P2 (carga da agenda). KPI: atendimentos por semana
SELECT YEARWEEK(a.data_hora, 1) AS semana, MIN(DATE(a.data_hora)) AS primeiro_dia, COUNT(*) AS atendimentos
FROM agendamento a
WHERE a.status = 'realizado'
GROUP BY YEARWEEK(a.data_hora, 1)
ORDER BY semana;

-- G04 — Qual é a média semanal de atendimentos realizados?
-- Atende: P2. KPI: média de atendimentos por semana (a clínica informou cerca de 7)
SELECT ROUND(AVG(qtd), 1) AS media_atendimentos_por_semana
FROM (SELECT COUNT(*) AS qtd FROM agendamento WHERE status = 'realizado' GROUP BY YEARWEEK(data_hora, 1)) s;

-- G05 — Qual é a taxa de cancelamentos e faltas por mês?
-- Atende: P2 (horários perdidos). KPI: taxa de perda de agenda
SELECT DATE_FORMAT(data_hora, '%Y-%m') AS mes, COUNT(*) AS agendados,
       SUM(status = 'realizado') AS realizados, SUM(status = 'cancelado') AS cancelados,
       SUM(status = 'nao_compareceu') AS faltas, SUM(status = 'remarcado') AS remarcados,
       ROUND(100 * SUM(status IN ('cancelado','nao_compareceu')) / COUNT(*), 1) AS taxa_perda_pct
FROM agendamento
WHERE data_hora < @hoje
GROUP BY mes
ORDER BY mes;

-- G06 — Quais procedimentos mais geram receita e quanto de desconto médio é dado?
-- Atende: P1 (histórico de procedimentos) e P4. KPI: receita por procedimento
SELECT pr.nome AS procedimento, COUNT(*) AS vezes_realizado, SUM(pra.preco_praticado) AS receita_registrada,
       ROUND(AVG(pra.preco_praticado), 2) AS preco_medio_praticado
FROM procedimento_realizado pra
JOIN procedimento pr ON pr.id_procedimento = pra.id_procedimento
JOIN agendamento a   ON a.id_agendamento = pra.id_agendamento
WHERE a.status = 'realizado'
GROUP BY pr.id_procedimento, pr.nome
ORDER BY receita_registrada DESC;

-- G07 — Quanto a clínica gasta por categoria de despesa em cada mês?
-- Atende: P6 (despesas em planilha separada). KPI: despesa por categoria
SELECT DATE_FORMAT(x.data_vencimento, '%Y-%m') AS mes, c.nome AS categoria,
       COUNT(*) AS lancamentos, SUM(x.valor) AS total
FROM despesa x
JOIN categoria_despesa c ON c.id_categoria_despesa = x.id_categoria_despesa
GROUP BY mes, c.nome
ORDER BY mes, total DESC;

-- G08 — Quais contas a pagar estão pendentes e quantos dias de atraso têm?
-- Atende: P6 (contas a pagar). KPI: contas vencidas
SELECT x.id_despesa, c.nome AS categoria, x.descricao, x.valor, x.data_vencimento,
       GREATEST(DATEDIFF(@hoje, x.data_vencimento), 0) AS dias_em_atraso
FROM despesa x
JOIN categoria_despesa c ON c.id_categoria_despesa = x.id_categoria_despesa
WHERE x.status = 'pendente'
ORDER BY x.data_vencimento;

-- G09 — Qual é o resultado financeiro de cada mês (recebido menos despesas pagas)?
-- Atende: P4 (financeiro) e P6. KPI: resultado mensal
SELECT m.mes, COALESCE(r.receita, 0) AS receita, COALESCE(d.despesa, 0) AS despesa,
       COALESCE(r.receita, 0) - COALESCE(d.despesa, 0) AS resultado
FROM (SELECT DATE_FORMAT(data_hora, '%Y-%m') AS mes FROM agendamento WHERE data_hora < @hoje
      UNION
      SELECT DATE_FORMAT(data_vencimento, '%Y-%m') FROM despesa WHERE data_vencimento <= @hoje) m
LEFT JOIN (SELECT DATE_FORMAT(a.data_hora, '%Y-%m') AS mes, SUM(p.valor) AS receita
           FROM pagamento p JOIN agendamento a ON a.id_agendamento = p.id_agendamento
           WHERE p.status = 'pago' GROUP BY mes) r ON r.mes = m.mes
LEFT JOIN (SELECT DATE_FORMAT(data_vencimento, '%Y-%m') AS mes, SUM(valor) AS despesa
           FROM despesa WHERE status = 'paga' GROUP BY mes) d ON d.mes = m.mes
ORDER BY m.mes;

-- G10 — Quanto cada tratamento custou em materiais e laboratório e qual foi a margem?
-- Atende: P6 (ligação despesa–tratamento). KPI: margem por tratamento
SELECT t.id_tratamento, t.nome, COALESCE(rec.receita, 0) AS receita, cus.custo,
       COALESCE(rec.receita, 0) - cus.custo AS margem
FROM tratamento t
JOIN (SELECT id_tratamento, SUM(valor) AS custo FROM despesa
      WHERE id_tratamento IS NOT NULL GROUP BY id_tratamento) cus ON cus.id_tratamento = t.id_tratamento
LEFT JOIN (SELECT a.id_tratamento, SUM(p.valor) AS receita
           FROM agendamento a JOIN pagamento p ON p.id_agendamento = a.id_agendamento
           WHERE p.status = 'pago' AND a.id_tratamento IS NOT NULL
           GROUP BY a.id_tratamento) rec ON rec.id_tratamento = t.id_tratamento
ORDER BY margem;

-- G11 — Como achar rapidamente um paciente por nome, CPF ou telefone?
-- Atende: P4 (busca lenta de pacientes) e P1. Troque o valor de @busca para testar.
SET @busca = 'silva';
SELECT DISTINCT p.id_paciente, p.nome, p.nome_social, p.cpf, t.numero AS telefone
FROM paciente p
LEFT JOIN telefone t ON t.id_paciente = p.id_paciente
WHERE p.nome LIKE CONCAT('%', @busca, '%') OR p.nome_social LIKE CONCAT('%', @busca, '%')
   OR p.cpf = @busca OR t.numero = @busca
ORDER BY p.nome;

-- G12 — Quais pacientes estão sem atendimento há mais de 90 dias (para reativar)?
-- Atende: P5 (captação de clientes; parcial, pois a origem do paciente não é registrada). KPI: pacientes inativos
SELECT p.id_paciente, p.nome, MAX(DATE(a.data_hora)) AS ultimo_atendimento
FROM paciente p
LEFT JOIN agendamento a ON a.id_paciente = p.id_paciente AND a.status = 'realizado'
GROUP BY p.id_paciente, p.nome
HAVING ultimo_atendimento IS NULL OR ultimo_atendimento < DATE_SUB(@hoje, INTERVAL 90 DAY)
ORDER BY ultimo_atendimento;

-- G13 — Que parcela dos pacientes atendidos entrou em tratamento?
-- Atende: P5 (conversão de avaliação em tratamento; parcial). KPI: taxa de conversão em tratamento
SELECT COUNT(DISTINCT a.id_paciente) AS pacientes_atendidos,
       COUNT(DISTINCT CASE WHEN a.id_tratamento IS NOT NULL THEN a.id_paciente END) AS pacientes_em_tratamento,
       ROUND(100 * COUNT(DISTINCT CASE WHEN a.id_tratamento IS NOT NULL THEN a.id_paciente END)
             / COUNT(DISTINCT a.id_paciente), 1) AS taxa_conversao_pct
FROM agendamento a
WHERE a.status = 'realizado';

-- G14 — Quais procedimentos já foram realizados em um paciente (para novo agendamento)?
-- Atende: P1 (histórico do paciente; RF13). Troque @id_paciente para testar.
SET @id_paciente = 1;
SELECT pa.nome AS paciente, pr.nome AS procedimento, COUNT(*) AS vezes, MAX(DATE(a.data_hora)) AS ultima_vez
FROM agendamento a
JOIN paciente pa                ON pa.id_paciente = a.id_paciente
JOIN procedimento_realizado pra ON pra.id_agendamento = a.id_agendamento
JOIN procedimento pr            ON pr.id_procedimento = pra.id_procedimento
WHERE a.id_paciente = @id_paciente AND a.status = 'realizado'
GROUP BY pa.nome, pr.id_procedimento, pr.nome
ORDER BY ultima_vez DESC;

-- ---------------------------------------------------------------------
-- 9. CONSULTAS DE AUDITORIA (conferem as regras de negócio)
--    "Esperado: nenhuma linha" significa que a regra está sendo cumprida.
-- ---------------------------------------------------------------------

-- A01 — Existe paciente cadastrado sem nenhum telefone?
-- Verifica: RN01 (todo paciente tem nome e ao menos um telefone). Esperado: nenhuma linha
SELECT p.id_paciente, p.nome
FROM paciente p
LEFT JOIN telefone t ON t.id_paciente = p.id_paciente
WHERE t.id_telefone IS NULL;

-- A02 — Existem dois agendamentos ativos do mesmo dentista no mesmo horário?
-- Verifica: RN02 (um paciente por horário por dentista). Esperado: nenhuma linha (garantido também pela UNIQUE)
SELECT id_dentista, data_hora, COUNT(*) AS agendamentos
FROM agendamento
WHERE status IN ('agendado','realizado')
GROUP BY id_dentista, data_hora
HAVING COUNT(*) > 1;

-- A03 — Quais cancelamentos ou faltas ficaram sem novo agendamento do paciente?
-- Verifica: RN04 (cancelamento: oferecer reagendamento; falta: contatar o paciente). Esperado: linhas a tratar pela clínica
SELECT a.id_agendamento, p.nome, p.id_paciente, a.data_hora, a.status
FROM agendamento a
JOIN paciente p ON p.id_paciente = a.id_paciente
WHERE a.status IN ('cancelado','nao_compareceu')
  AND NOT EXISTS (SELECT 1 FROM agendamento b
                  WHERE b.id_paciente = a.id_paciente AND b.data_hora > a.data_hora
                    AND b.status IN ('agendado','realizado'))
ORDER BY a.data_hora;

-- A04 — Existe tratamento com agendamentos de mais de um paciente?
-- Verifica: RN09 (todos os agendamentos de um tratamento são do mesmo paciente). Esperado: nenhuma linha
SELECT a.id_tratamento, COUNT(DISTINCT a.id_paciente) AS pacientes
FROM agendamento a
WHERE a.id_tratamento IS NOT NULL
GROUP BY a.id_tratamento
HAVING COUNT(DISTINCT a.id_paciente) > 1;

-- A05 — Existe procedimento registrado em agendamento que não foi realizado?
-- Verifica: RN06 e RN08 (procedimentos e preço praticado só existem em atendimento realizado). Esperado: nenhuma linha
SELECT a.id_agendamento, a.status, pra.id_procedimento
FROM procedimento_realizado pra
JOIN agendamento a ON a.id_agendamento = pra.id_agendamento
WHERE a.status <> 'realizado';

-- A06 — Existe dentista sem nenhuma especialidade?
-- Verifica: RN13 (todo dentista tem ao menos uma especialidade). Esperado: nenhuma linha
SELECT d.id_dentista, d.nome
FROM dentista d
LEFT JOIN dentista_especialidade de ON de.id_dentista = d.id_dentista
WHERE de.id_especialidade IS NULL;

-- A07 — Quais pagamentos pendentes de atendimentos realizados têm mais de 30 dias?
-- Verifica: RN12 (pagamento pendente deve gerar aviso ao paciente). Esperado: linhas a cobrar
SELECT pg.id_pagamento, pa.nome, pg.valor, DATE(a.data_hora) AS atendimento,
       DATEDIFF(@hoje, a.data_hora) AS dias_pendente
FROM pagamento pg
JOIN agendamento a ON a.id_agendamento = pg.id_agendamento
JOIN paciente pa   ON pa.id_paciente = a.id_paciente
WHERE pg.status = 'pendente' AND a.status = 'realizado'
  AND a.data_hora < DATE_SUB(@hoje, INTERVAL 30 DAY)
ORDER BY a.data_hora;

-- A08 — Existe agendamento com pagamentos maiores que o valor dos procedimentos realizados?
-- Verifica: RN10 (os pagamentos de um agendamento somam o valor combinado). Esperado: nenhuma linha
SELECT pg.id_agendamento, pg.total_pagamentos, COALESCE(pr.total_procedimentos, 0) AS total_procedimentos
FROM (SELECT id_agendamento, SUM(valor) AS total_pagamentos FROM pagamento GROUP BY id_agendamento) pg
LEFT JOIN (SELECT id_agendamento, SUM(preco_praticado) AS total_procedimentos
           FROM procedimento_realizado GROUP BY id_agendamento) pr ON pr.id_agendamento = pg.id_agendamento
WHERE pg.total_pagamentos > COALESCE(pr.total_procedimentos, 0);

-- A09 — Existe despesa paga sem data de pagamento, ou pendente com data de pagamento?
-- Verifica: RN16 (data de pagamento só quando a despesa está paga). Esperado: nenhuma linha (garantido também pelo CHECK)
SELECT id_despesa, status, data_pagamento
FROM despesa
WHERE (status = 'paga' AND data_pagamento IS NULL) OR (status = 'pendente' AND data_pagamento IS NOT NULL);

-- A10 — Existe CPF cadastrado para mais de um paciente?
-- Verifica: RN19 (CPF opcional e único). Esperado: nenhuma linha (garantido também pela UNIQUE)
SELECT cpf, COUNT(*) AS pacientes
FROM paciente
WHERE cpf IS NOT NULL
GROUP BY cpf
HAVING COUNT(*) > 1;

-- A11 — Quais procedimentos de sessão única foram cobrados com mais de 20% de desconto?
-- Verifica: RN08 (o preço praticado varia, mas descontos grandes devem ser conferidos). Esperado: linhas a conferir
SELECT a.id_agendamento, pa.nome AS paciente, pr.nome AS procedimento, pr.preco_base, pra.preco_praticado,
       ROUND(100 * (1 - pra.preco_praticado / pr.preco_base), 1) AS desconto_pct
FROM procedimento_realizado pra
JOIN procedimento pr ON pr.id_procedimento = pra.id_procedimento
JOIN agendamento a   ON a.id_agendamento = pra.id_agendamento
JOIN paciente pa     ON pa.id_paciente = a.id_paciente
WHERE pr.numero_sessoes_estimado = 1 AND pra.preco_praticado < 0.8 * pr.preco_base
ORDER BY desconto_pct DESC;

-- A12 — Existe agendamento no passado que ainda consta como "agendado"?
-- Verifica: RN04 (a situação do agendamento deve ser atualizada: realizado, cancelado, falta ou remarcado). Esperado: linhas a atualizar
SELECT a.id_agendamento, pa.nome, a.data_hora, a.status
FROM agendamento a
JOIN paciente pa ON pa.id_paciente = a.id_paciente
WHERE a.status = 'agendado' AND a.data_hora < @hoje
ORDER BY a.data_hora;

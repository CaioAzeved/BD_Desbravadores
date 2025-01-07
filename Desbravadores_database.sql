CREATE TABLE tb_endereco (
  id_endereco INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  logradouro varchar NOT NULL,
  bairro varchar NOT NULL,
  numero varchar,
  complemento varchar,
  cidade varchar NOT NULL,
  estado varchar(2) NOT NULL,
  pais varchar NOT NULL,
  dt_insercao timestamp DEFAULT current_timestamp,
  dt_atualizacao timestamp DEFAULT current_timestamp ON UPDATE current_timestamp
);

CREATE TABLE tb_pessoa (
  id_pessoa INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  nome varchar NOT NULL,
  cpf varchar(11),
  id_endereco integer REFERENCES tb_endereco,
  telefone varchar(11),
  genero varchar(1) NOT NULL,
  dt_insercao timestamp DEFAULT current_timestamp,
  dt_atualizacao timestamp DEFAULT current_timestamp ON UPDATE current_timestamp
);

CREATE TABLE tb_doacao (
  id_doacao INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  id_doador integer NOT NULL REFERENCES tb_pessoa,
  valor decimal(10,2) NOT NULL,
  metodoPagamento varchar NOT NULL,
  dt_insercao timestamp DEFAULT current_timestamp,
  dt_atualizacao timestamp DEFAULT current_timestamp ON UPDATE current_timestamp
);

CREATE TABLE tb_contatoEmergencial (
  id_contatoEmergencial INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  nome varchar NOT NULL,
  telefone varchar(11) NOT NULL,
  dt_insercao timestamp DEFAULT current_timestamp,
  dt_atualizacao timestamp DEFAULT current_timestamp ON UPDATE current_timestamp
);

CREATE TABLE tb_unidade (
  id_unidade INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  nome varchar NOT NULL,
  genero varchar(1) NOT NULL,
  faixa_etaria varchar
  dt_insercao timestamp DEFAULT current_timestamp,
  dt_atualizacao timestamp DEFAULT current_timestamp ON UPDATE current_timestamp
);

CREATE TABLE tb_membro (
  id_membro integer PRIMARY KEY,
  cargo varchar,
  id_contatoEmergencial integer NOT NULL REFERENCES tb_contatoEmergencial,
  grupo varchar NOT NULL,
  dt_nascimento date NOT NULL,
  id_unidade integer REFERENCES tb_unidade,
  dt_insercao timestamp DEFAULT current_timestamp,
  dt_atualizacao timestamp DEFAULT current_timestamp ON UPDATE current_timestamp
);

CREATE TABLE tb_especialidade (
  codigo integer PRIMARY KEY,
  area varchar(2) NOT NULL,
  nivel int NOT NULL,
  ano varchar(4) NOT NULL,
  instituicao varchar NOT NULL,
  dt_insercao timestamp DEFAULT current_timestamp,
  dt_atualizacao timestamp DEFAULT current_timestamp ON UPDATE current_timestamp
);

CREATE TABLE tb_membro_especialidade (
  id_membro integer REFERENCES tb_membro,
  id_especialidade integer REFERENCES tb_especialidade,
  id_instrutor integer NOT NULL REFERENCES tb_membro check (tb_membro.grupo = 'Liderança'),
  dt_insercao timestamp DEFAULT current_timestamp,
  dt_atualizacao timestamp DEFAULT current_timestamp ON UPDATE current_timestamp,
  PRIMARY KEY (id_membro, id_especialidade)
);

CREATE TABLE tb_evento (
  id_evento INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  descricao varchar,
  taxa decimal(10,2) NOT NULL,
  organizador integer NOT NULL REFERENCES tb_membro,
  dt_ida date NOT NULL,
  dt_volta date NOT NULL,
  dt_insercao timestamp DEFAULT current_timestamp,
  dt_atualizacao timestamp DEFAULT current_timestamp ON UPDATE current_timestamp
);

CREATE TABLE tb_membro_evento (
  id_membro integer REFERENCES tb_membro,
  id_evento integer REFERENCES tb_evento,
  taxaSituacao varchar NOT NULL,
  dt_insercao timestamp DEFAULT current_timestamp,
  dt_atualizacao timestamp DEFAULT current_timestamp ON UPDATE current_timestamp,
  PRIMARY KEY (id_membro, id_evento)
);

CREATE TABLE tb_classe (
  id_classe INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  nome varchar NOT NULL,
  dt_insercao timestamp DEFAULT current_timestamp,
  dt_atualizacao timestamp DEFAULT current_timestamp ON UPDATE current_timestamp
);

CREATE TABLE tb_membro_classe (
  id_membro integer REFERENCES tb_membro,
  id_classe integer REFERENCES tb_classe,
  dt_insercao timestamp DEFAULT current_timestamp,
  dt_atualizacao timestamp DEFAULT current_timestamp ON UPDATE current_timestamp,
  PRIMARY KEY (id_membro, id_classe)
);

COMMENT ON COLUMN tb_pessoa.genero IS 'M or F';

COMMENT ON COLUMN tb_membro.grupo IS 'desbravador ou liderança';

COMMENT ON COLUMN tb_unidade.genero IS 'M, F ou L(unidade de Liderança)';

COMMENT ON COLUMN tb_unidade.faixa_etaria IS 'Escrever qual a faixa etária comum para os desbravadores, ex.: 10-12; caso unidade de liderança, escrever: ''16+''';

COMMENT ON COLUMN tb_endereco.estado IS 'Sigla do estado';

COMMENT ON COLUMN tb_membro_evento.taxaSituacao IS 'Pago, Isento ou Pendente';

COMMENT ON COLUMN tb_doacao.metodoPagamento IS 'pix, dinheiro';

ALTER TABLE "tb_membro" ADD FOREIGN KEY ("id_membro") REFERENCES "tb_pessoa" ("id_pessoa");

ALTER TABLE "tb_membro" ADD FOREIGN KEY ("id_unidade") REFERENCES "tb_unidade" ("id_unidade");

ALTER TABLE "tb_membro" ADD FOREIGN KEY ("id_contatoEmergencial") REFERENCES "tb_contatoEmergencial" ("id_contatoEmergencial");

ALTER TABLE "tb_membro_especialidade" ADD FOREIGN KEY ("id_membro") REFERENCES "tb_membro" ("id_membro");

ALTER TABLE "tb_membro_especialidade" ADD FOREIGN KEY ("id_especialidade") REFERENCES "tb_especialidade" ("codigo");

ALTER TABLE "tb_membro_especialidade" ADD FOREIGN KEY ("id_instrutor") REFERENCES "tb_membro" ("id_membro");

ALTER TABLE "tb_evento" ADD FOREIGN KEY ("organizador") REFERENCES "tb_membro" ("id_membro");

ALTER TABLE "tb_membro_evento" ADD FOREIGN KEY ("id_membro") REFERENCES "tb_membro" ("id_membro");

ALTER TABLE "tb_membro_evento" ADD FOREIGN KEY ("id_evento") REFERENCES "tb_evento" ("id_evento");

ALTER TABLE "tb_doacao" ADD FOREIGN KEY ("id_doador") REFERENCES "tb_pessoa" ("id_pessoa");

ALTER TABLE "tb_membro_classe" ADD FOREIGN KEY ("id_membro") REFERENCES "tb_membro" ("id_membro");

ALTER TABLE "tb_membro_classe" ADD FOREIGN KEY ("id_classe") REFERENCES "tb_classe" ("id_classe");

ALTER TABLE "tb_pessoa" ADD FOREIGN KEY ("id_endereco") REFERENCES "tb_endereco" ("id_endereco");

insert into tb_endereco (logradouro, bairro, numero, complemento, cidade, estado, pais)
values
('Rua Senador da Silva', 'Neópolis', '2023', NULL, 'Natal', 'RN', 'Brasil'),
('Avenida Santa Teresa', 'CEHAB', '45', NULL, 'Macaíba', 'RN', 'Brasil'),
('Rua Francisco Alencar', 'Petrópolis', '1010', 'apt. 102', 'Natal', 'RN', 'Brasil'),
('Praça Nelson Miranda', 'Pitimbú', '87', NULL, 'Natal', 'RN', 'Brasil'),
('Avenida Agamenom Magalhães', 'Planalto', '3409', NULL, 'Natal', 'RN', 'Brasil'),
('Rua Virginópolis', 'Nova Parnamirim', '75', NULL, 'Parnamirim', 'RN', 'Brasil'),
('Rua Pintor Geraldo de Azevedo', 'Mirassol', '300', 'apt. 805', 'Natal', 'RN', 'Brasil'),
('Travessa Piloto Mário Melo', 'Emaús', '67', NULL, 'Parnamirim', 'RN', 'Brasil'),
('Avenida Cristo Redentor', 'Nova Descoberta', '42', NULL, 'Natal', 'RN', 'Brasil'),
('Avenida Lima e Silva', 'Lagoa Nova', '903', 'apt. 1003', 'Natal', 'RN', 'Brasil');
('Avenida Hilton Souto Maior', 'Mangabeira VII', '4180', NULL, 'João Pessoa', 'PB', 'Brasil'),
('Avenida das Tulipas', 'Capim Macio', '3560', NULL, 'Natal', 'RN', 'Brasil');
('Rua Castro Alves', 'Alecrim', '300', 'casa', 'Natal', 'RN', 'Brasil');
('Avenida Beira Canal', 'Tirol', '656', NULL, 'Natal', 'RN', 'Brasil');
('Avenida Leste', 'Cidade Nova', '145', 'apt. 304', 'Natal', 'RN', 'Brasil');
('Avenida Erivan França', 'Ponta Negra', '6457', 'apt. 202', 'Natal', 'RN', 'Brasil');

insert into tb_pessoa (nome, cpf, id_endereco, telefone, genero)
values 
('Mateus Raimundo', '12343234521', 1, '84993247164', 'M'),
('Maria Marciano', '09876789543', 2, '87996785432', 'F'), 
('Klebson Dantas', '23940128394', 10, '84987234590', 'M'),
('Nova Chrono', '29354000239', 3, '84988684543', 'M'),
('Neferpitou Ant', '99999999999', 5, '84986554533', 'F'),
('Yusuha Usagi', '00022837755', 4, '84921017944', 'F'),
('Erza Scarlet', '398489358673', 7, '84910103124', 'F'),
('Hannah Beatryz','13155464933', 7,'83987063599','F'),
('Hannah Beatris','13155494633', 6, '83987093566','F'),
('Gon Freecs', '33849930466', 8, '84945678324', 'M');
('Killua Zoldyck', '83456739488', 8, '84988342776', 'M');
('Natsu Dragnell', '875643890931', 10, '84988339945', 'M');
('Ingrid Barbalhos', '23554382392', 11,'84960604477','F');
('Benjamin Tennyson', '11120938245', 9,'84983945676','M');
('Kevin Levin', '93445398204', 12,'84985034422','M');
('Erza Nightwalker', '94302911142', 13,'84980809090','F');
('Kuroko Tetsuya', '77182304938', 14,'84933242258','M');
('Rayla Storm', '38455679203', 15,'84999384611','F');
('Antony Stark', '44592834721', 16,'84987945020','M');
('Attea Frog', '11294884763', 9,'84988112233','F');


insert into tb_contatoEmergencial (nome, telefone)
values
('Marta Silva','84988556745');
('Eliabe Fernandes','84987949431');
('Adja Alexander','84983848598');
('Ramilton Soares','84934567894');
('Isabela Pinheiro','84935435321');
('Austin Gouveia','84911127850');
('Isaac Marlon','84955000653');
('Patrick Dias','84984685200');
('Mônica Magalhães','84920350960');
('Selan Duarte','84913568653');
('Athanasios Tsouanas','84945093390');
('Rafaela Marinho','84978749321');

insert into tb_membro (id_membro, cargo, id_contatoEmergencial, grupo, dt_nascimento, id_unidade)
values
();



Select * from tb_endereco;
Select * from tb_pessoa;
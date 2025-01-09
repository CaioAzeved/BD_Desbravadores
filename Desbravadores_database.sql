CREATE TABLE tb_endereco (
  id_endereco INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  logradouro varchar NOT NULL,
  bairro varchar NOT NULL,
  numero varchar,
  complemento varchar,
  cidade varchar NOT NULL,
  estado varchar(2) NOT NULL,
  pais varchar NOT NULL,
  criado_em timestamp DEFAULT current_timestamp,
  atualizado_em timestamp DEFAULT current_timestamp
);

CREATE TABLE tb_pessoa (
  id_pessoa INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  nome varchar NOT NULL,
  cpf varchar(11),
  id_endereco integer REFERENCES tb_endereco,
  telefone varchar(11),
  genero varchar(1) NOT NULL,
  criado_em timestamp DEFAULT current_timestamp,
  atualizado_em timestamp DEFAULT current_timestamp
);

CREATE TABLE tb_doacao (
  id_doacao INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  id_doador integer NOT NULL REFERENCES tb_pessoa,
  valor decimal(10,2) NOT NULL,
  metodoPagamento varchar NOT NULL,
  criado_em timestamp DEFAULT current_timestamp,
  atualizado_em timestamp DEFAULT current_timestamp
);

CREATE TABLE tb_contatoEmergencial (
  id_contatoEmergencial INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  nome varchar NOT NULL,
  telefone varchar(11) NOT NULL,
  criado_em timestamp DEFAULT current_timestamp,
  atualizado_em timestamp DEFAULT current_timestamp
);

CREATE TABLE tb_unidade (
  id_unidade INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  nome varchar NOT NULL,
  genero varchar(1) NOT NULL,
  faixa_etaria varchar,
  criado_em timestamp DEFAULT current_timestamp,
  atualizado_em timestamp DEFAULT current_timestamp
);

CREATE TABLE tb_membro (
  id_membro integer PRIMARY KEY,
  cargo varchar,
  id_contatoEmergencial integer NOT NULL REFERENCES tb_contatoEmergencial,
  grupo varchar NOT NULL,
  dt_nascimento date NOT NULL,
  id_unidade integer REFERENCES tb_unidade,
  criado_em timestamp DEFAULT current_timestamp,
  atualizado_em timestamp DEFAULT current_timestamp
);

CREATE TABLE tb_especialidade (
  codigo integer PRIMARY KEY,
  area varchar(2) NOT NULL,
  nivel int NOT NULL,
  ano varchar(4) NOT NULL,
  instituicao varchar NOT NULL,
  criado_em timestamp DEFAULT current_timestamp,
  atualizado_em timestamp DEFAULT current_timestamp
);

CREATE TABLE tb_membro_especialidade (
  id_membro integer REFERENCES tb_membro,
  id_especialidade integer REFERENCES tb_especialidade,
  id_instrutor integer NOT NULL REFERENCES tb_membro,
  criado_em timestamp DEFAULT current_timestamp,
  atualizado_em timestamp DEFAULT current_timestamp,
  PRIMARY KEY (id_membro, id_especialidade)
);

CREATE TABLE tb_evento (
  id_evento INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  descricao varchar,
  taxa decimal(10,2) NOT NULL,
  organizador integer NOT NULL REFERENCES tb_membro,
  dt_ida date NOT NULL,
  dt_volta date NOT NULL,
  criado_em timestamp DEFAULT current_timestamp,
  atualizado_em timestamp DEFAULT current_timestamp
);

CREATE TABLE tb_membro_evento (
  id_membro integer REFERENCES tb_membro,
  id_evento integer REFERENCES tb_evento,
  taxaSituacao varchar NOT NULL,
  criado_em timestamp DEFAULT current_timestamp,
  atualizado_em timestamp DEFAULT current_timestamp,
  PRIMARY KEY (id_membro, id_evento)
);

CREATE TABLE tb_classe (
  id_classe INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  nome varchar NOT NULL,
  criado_em timestamp DEFAULT current_timestamp,
  atualizado_em timestamp DEFAULT current_timestamp
);

CREATE TABLE tb_membro_classe (
  id_membro integer REFERENCES tb_membro,
  id_classe integer REFERENCES tb_classe,
  criado_em timestamp DEFAULT current_timestamp,
  atualizado_em timestamp DEFAULT current_timestamp,
  PRIMARY KEY (id_membro, id_classe)
);

CREATE OR REPLACE FUNCTION atualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.atualizado_em IS NOT NULL THEN
        NEW.atualizado_em = current_timestamp;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    tabela RECORD;
BEGIN
    FOR tabela IN
        SELECT table_name
        FROM information_schema.columns
        WHERE column_name = 'atualizado_em'
    LOOP
        EXECUTE format(
            'CREATE TRIGGER atualizar_timestamp_%s
            BEFORE UPDATE ON %I
            FOR EACH ROW
            EXECUTE FUNCTION atualizar_timestamp();',
            tabela.table_name,
            tabela.table_name
        );
    END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION validar_instrutor()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o instrutor pertence ao grupo 'Liderança'
    IF NOT EXISTS (
        SELECT 1
        FROM tb_membro
        WHERE id_membro = NEW.id_instrutor AND grupo = 'Liderança'
    ) THEN
        RAISE EXCEPTION 'Instrutor % não pertence ao grupo Liderança', NEW.id_instrutor;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_instrutor_trigger
BEFORE INSERT OR UPDATE ON tb_membro_especialidade
FOR EACH ROW
EXECUTE FUNCTION validar_instrutor();

COMMENT ON COLUMN tb_pessoa.genero IS 'M or F';

COMMENT ON COLUMN tb_membro.grupo IS 'Desbravador ou Liderança';

COMMENT ON COLUMN tb_unidade.genero IS 'M, F ou L(unidade de Liderança)';

COMMENT ON COLUMN tb_unidade.faixa_etaria IS 'Escrever qual a faixa etária comum para os desbravadores, ex.: ''10-12''; caso unidade de liderança, escrever: ''16+''';

COMMENT ON COLUMN tb_endereco.estado IS 'Sigla do estado';

COMMENT ON COLUMN tb_membro_evento.taxaSituacao IS 'Pago, Isento ou Pendente';

COMMENT ON COLUMN tb_doacao.metodoPagamento IS 'Pix, Dinheiro';

INSERT INTO tb_endereco (logradouro, bairro, numero, complemento, cidade, estado, pais)
VALUES
('Rua Senador da Silva', 'Neópolis', '2023', NULL, 'Natal', 'RN', 'Brasil'),
('Avenida Santa Teresa', 'CEHAB', '45', NULL, 'Macaíba', 'RN', 'Brasil'),
('Rua Francisco Alencar', 'Petrópolis', '1010', 'apt. 102', 'Natal', 'RN', 'Brasil'),
('Praça Nelson Miranda', 'Pitimbú', '87', NULL, 'Natal', 'RN', 'Brasil'),
('Avenida Agamenom Magalhães', 'Planalto', '3409', NULL, 'Natal', 'RN', 'Brasil'),
('Rua Virginópolis', 'Nova Parnamirim', '75', NULL, 'Parnamirim', 'RN', 'Brasil'),
('Rua Pintor Geraldo de Azevedo', 'Mirassol', '300', 'apt. 805', 'Natal', 'RN', 'Brasil'),
('Travessa Piloto Mário Melo', 'Emaús', '67', NULL, 'Parnamirim', 'RN', 'Brasil'),
('Avenida Cristo Redentor', 'Nova Descoberta', '42', NULL, 'Natal', 'RN', 'Brasil'),
('Avenida Lima e Silva', 'Lagoa Nova', '903', 'apt. 1003', 'Natal', 'RN', 'Brasil'),
('Avenida Hilton Souto Maior', 'Mangabeira VII', '4180', NULL, 'João Pessoa', 'PB', 'Brasil'),
('Avenida das Tulipas', 'Capim Macio', '3560', NULL, 'Natal', 'RN', 'Brasil'),
('Rua Castro Alves', 'Alecrim', '300', 'casa', 'Natal', 'RN', 'Brasil'),
('Avenida Beira Canal', 'Tirol', '656', NULL, 'Natal', 'RN', 'Brasil'),
('Avenida Leste', 'Cidade Nova', '145', 'apt. 304', 'Natal', 'RN', 'Brasil'),
('Travessa Félix', 'Felipe Camarão', '333', NULL, 'Natal', 'RN', 'Brasil'),
('Travessa Indomar', 'Felipe Camarão', '444', NULL, 'Natal', 'RN', 'Brasil'),
('Avenida Erivan França', 'Ponta Negra', '6457', 'apt. 202', 'Natal', 'RN', 'Brasil');

INSERT INTO tb_pessoa (nome, cpf, id_endereco, telefone, genero)
VALUES 
('Mateus Raimundo', '12343234521', 1, '84993247164', 'M'), --1
('Maria Marciano', '09876789543', 2, '87996785432', 'F'),  --2
('Klebson Dantas', '23940128394', 10, '84987234590', 'M'), --3
('Nova Chrono', '29354000239', 3, '84988684543', 'M'),     --4
('Neferpitou Ant', '99999999999', 5, '84986554533', 'F'),  --5
('Yusuha Usagi', '00022837755', 4, '84921017944', 'F'),    --6
('Erza Scarlet', '39848935867', 7, '84910103124', 'F'),    --7
('Hannah Beatryz','13155464933', 7,'83987063599','F'),     --8
('Hannah Beatris','13155494633', 6, '83987093566','F'),    --9
('Gon Freecs', '33849930466', 8, '84945678324', 'M'),      --10
('Killua Zoldyck', '83456739488', 8, '84988342776', 'M'),  --11
('Natsu Dragnell', '87564389031', 10, '84988339945', 'M'), --12
('Ingrid Barbalhos', '23554382392', 11,'84960604477','F'), --13
('Benjamin Tennyson', '11120938245', 9,'84983945676','M'), --14
('Kevin Levin', '93445398204', 12,'84985034422','M'),      --15
('Erza Nightwalker', '94302911142', 13,'84980809090','F'), --16
('Kuroko Tetsuya', '77182304938', 14,'84933242258','M'),   --17
('Rayla Storm', '38455679203', 15,'84999384611','F'),      --18
('Antony Stark', '44592834721', 16,'84987945020','M'),     --19
('Attea Frog', '11294884763', 9,'84988112233','F');        --20
('Prue Halliwell', '23277784901', 17,'84988886388','F'),   --21
('Piper Halliwell', '31388890276', 17,'84988846388','F'),  --22
('Phoebe Halliwell', '45434587600', 17,'84988826388','F'), --23
('Florzinha Utônio', '99440233810', 18,'84988689644','F'), --24
('Lindinha Utônio', '99440233811', 18,'84988689644','F'),  --25
('Docinho Utônio', '99440233812', 18,'84988689644','F'),   --26
('Son Goku', '23985283754', 2, '84992347658', 'M');        --27

INSERT INTO tb_doacao(id_doador, valor, metodoPagamento)
VALUES
(9, 200,'Pix'),
(2, 100,'Pix'),
(5, 55.70,'Pix'),
(4, 1000,'Pix'),
(13, 105,'Pix'),
(19, 30,'Pix')
(14, 200, 'Pix'),
(20, 201, 'Pix'),
(7, 25.50,'Dinheiro'),
(3, 10.50,'Dinheiro');

INSERT INTO tb_unidade (nome, genero, faixa_etaria)
VALUES
('Avante Desbravadores', 'L', '16+'),
('Bando do Falcão', 'M', '10-12'),
('Tríade da Ameaça Tripla', 'M', '13-15'),
('Amazonas Guerreiras', 'F', '10-11'),
('Zurafa Flamejante', 'F', '12-13'),
('Mancha Azul', 'F', '14-15');


INSERT INTO tb_contatoEmergencial (nome, telefone)
VALUES
('Marta Silva','84988556745'),         --1
('Eliabe Fernandes','84987949431'),    --2
('Adja Alexander','84983848598'),      --3
('Ramilton Soares','84934567894'),     --4
('Isabela Pinheiro','84935435321'),    --5
('Austin Gouveia','84911127850'),      --6
('Isaac Marlon','84955000653'),        --7
('Patrick Dias','84984685200'),        --8
('Mônica Magalhães','84920350960'),    --9
('Selan Duarte','84913568653'),        --10
('Athanasios Tsouanas','84945093390'), --11
('Rafaela Marinho','84978749321');     --12
('Professor Utônio','84988689644');    --13
INSERT INTO tb_membro (id_membro, cargo, id_contatoEmergencial, grupo, dt_nascimento, id_unidade)
VALUES
(1, 'Diretor', 4, 'Liderança', '1993-09-05', 1),
(8, 'Capelã', 11, 'Liderança', '2003-06-30', 1),
(14, 'Conselheiro', 7, 'Liderança', '2000-07-30', 3),
(27, 'Capitão', 2, 'Desbravador', '2013-02-09', 3),
(18, 'Capitã', , 'Desbravador', '2014-01-07', 2),
(6, 'Conselheira', 1, 'Liderança', '2004-03-17', 2),
(17, 'Secretário', 12, 'Desbravador', '2014-04-26', 3),
(10, '', 11, 'Desbravador', '', ),
(11, '', 6, 'Desbravador', '', ),
(12, '', 5, 'Desbravador', '', ),
(15, '', 3, 'Desbravador', '', ),
(16, 'Conselheiro', 2, 'Liderança', '1997-05-26', 6),
(20, 'Secretária', 4, 'Liderança', '2001-08-25', 1),
(21, '', 10, 'Desbravador', '2012-08-11', 5),
(22, '', 12, 'Desbravador', '2011-05-25', 5),
(23, '', 12, 'Desbravador', '2010-02-28', 5),
(24, '', 13, 'Desbravador', '2014-01-03', 6),
(25, '', 13, 'Desbravador', '2014-01-03', 6),
(26, '', 13, 'Desbravador', '2014-01-03', 6);

INSERT INTO tb_evento (descricao, taxa, organizador, dt_ida, dt_volta)
VALUES
('Caminhada de 6km', 24.99, 8, '2025-01-11', '2025-01-11'),
('Campori Festival', 159.50, 20, '2025-09-24', '2025-09-28'),
('Visita a Ponta do Seixas em João Pessoa', 99.87, 20, '2025-10-08', '2025-10-09'),
('Acampamento na floresta da solidão', 47.99, 20, '2025-04-19', '2025-04-20'),
('Limpeza de praça', 0.0, 14, '2025-06-07', '2025-06-07'),
('Assalto ao banco central', 10.11, 14, '2025-08-22', '2025-08-22');


Select * from tb_endereco;
Select * from tb_pessoa;
Select * from tb_contatoEmergencial;
Select * from tb_doacao;
Select * from tb_unidade;

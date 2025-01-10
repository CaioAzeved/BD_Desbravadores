
/* 
  a)Faça uma consulta que contenha pelo menos dois operadores especiais (BETWEEN, LIKE, IN).
  Descrição: Retornar todos os aniversariantes de janeiro da liderança.
*/
Select *
from tb_membro
where TO_CHAR(dt_nascimento, 'MM-DD') between '01-01' and '01-31'
  and cargo like 'Liderança';

/*
  b) Faça 1 consulta com funções de agregação e utilize também operadores lógicos e
  especiais (cada consulta deve ter uma função de agregação diferente)
  Descrição: Contar quantas pessoas não são membros do clube.
*/
Select count(*) 
from tb_pessoa 
where not id_pessoa in (Select id_membro 
                        from tb_membro); 

/*
  c) Faça um nova consulta com uma função de agregação, com operadores lógicos, operadores 
  relacionais onde o resultados seja apresentado em ordem crescente ou decrescente
  Descrição: Ordenar a soma de todas as doações feitas pelas pessoas desde que o valor seja maior 
  do que 100 e feito por 'Pix'
*/
Select id_doador, sum(valor) as total_doacao
from tb_doacao
where valor > 100.00 and metodoPagamento = 'Pix'
group by id_doador
order by sum(valor) desc;

/*
  d) Faça uma consulta que utilize o GROUP BY e a cláusula HAVING
  Descrição: Agrupar membros pelo id e ordenar pela quantidade de especialidades, desde que ela seja 
  maior do que 5
*/
Select p.nome, count(e.id_especialidade) as total_especialidade 
from tb_membro m, tb_pessoa p, tb_membro_especialidade e
where e.id_membro = m.id_membro and p.id_pessoa = m.id_membro
group by m.id_membro
having count(e.id_especialidade) > 5;

/*
  e) Faça uma consulta utilizando INNER JOIN
  Descrição: Recuperar o nome dos contatos de emergência de membros do clube e que também pertencem ao clube
*/
Select c.nome 
from tb_pessoa p
inner join tb_membro m 
  on m.id_membro = p.id_pessoa
inner join tb_contatoEmergencial c
  on p.nome = c.nome;

/*
  f) Faça uma consulta utilizando LEFT JOIN
  Descrição: Recuperar o nome e o cargo de todas as pessoas
*/
Select p.nome, m.cargo 
from tb_pessoa p
left join tb_membro m
  on p.id_pessoa = m.id_membro;

/*
  g) Faça uma consulta utilizando RIGHT JOIN
  Descrição: Recuperar o nome e a doação de todas as pessoas
*/
Select p.nome, d.valor 
from tb_doacao d
right join tb_pessoa p
  on p.id_pessoa = d.id_doador;

/*
  h) Faça um consulta com a união de 3 tabelas (utilize qualquer JOIN) e que seu resultado
  seja de ordem crescente
  Descrição: Conseguir o nome dos membros que fizeram doações
*/
Select p.nome, d.valor 
from tb_pessoa p
inner join tb_membro m
  on p.id_pessoa = m.id_membro
inner join tb_doacao d
  on m.id_membro = d.id_doador
order by valor;

/*
  i)Crie uma função que retorna uma tabela. A função deve ter condições.
  Descrição: Retornar a tabela das especialidades ou das classes de um certo membro
*/
CREATE OR REPLACE FUNCTION show_membro_info (id_membro_param INTEGER, tipo TEXT)
RETURNS TABLE (nome_membro VARCHAR, id INTEGER, nome VARCHAR) AS $$
BEGIN
  -- Verifica o tipo solicitado
  IF tipo = 'Classes' THEN
    -- Retorna as classes associadas ao membro, junto com o nome do membro
    RETURN QUERY
    Select 
      p.nome as nome_membro, 
      c.id_classe as id, 
      c.nome
    from tb_classe c
    join tb_membro_classe mc on mc.id_classe = c.id_classe
    join tb_membro m on m.id_membro = mc.id_membro
    join tb_pessoa p on p.id_pessoa = m.id_membro
    where m.id_membro = id_membro_param;

  ELSIF tipo = 'Especialidades' THEN
    -- Retorna as especialidades associadas ao membro, junto com o nome do membro
    RETURN QUERY
    Select 
      p.nome as nome_membro, 
      e.codigo as id, 
      (e.nome || ' (' || e.area || ')')::VARCHAR as nome
    from tb_especialidade e
    join tb_membro_especialidade me on me.id_especialidade = e.codigo
    join tb_membro m on m.id_membro = me.id_membro
    join tb_pessoa p on p.id_pessoa = m.id_membro
    where m.id_membro = id_membro_param;

  ELSE
    -- Lança um erro se o tipo não for válido
    RAISE EXCEPTION 'Tipo inválido. Use "Classes" ou "Especialidades".';
  END IF;
END;
$$ LANGUAGE plpgsql;

/*
  j) Crie uma função que processam um conjunto de valores e retornam um valor
  Descrição: Será passado um array com os ids das doações e será retornado o nome do doador que fez a maior doação
*/


/*
  k) Crie uma função VOID (Não retorna a nenhum valor mas executa alguma operação)
  Descrição: Modificar o cargo de algum membro
*/
CREATE OR REPLACE FUNCTION change_cargo (id_membro_param INTEGER, new_cargo TEXT)
RETURNS void AS $$
BEGIN
  -- Verifica se o membro existe
  IF NOT EXISTS (
    Select 1
    from tb_membro
    where id_membro = id_membro_param
  ) THEN
    RAISE EXCEPTION 'Membro com ID % não encontrado.', id_membro_param;
  END IF;

  -- Atualiza o cargo do membro
  UPDATE tb_membro
  SET cargo = new_cargo
  where id_membro = id_membro_param;

  -- Mensagem de confirmação
  RAISE NOTICE 'Cargo do membro com ID % alterado para %.', id_membro_param, new_cargo;
END;
$$ LANGUAGE plpgsql;

/*
  l) Crie uma função da sua preferência que utilize funções de agregação (AVG, SUM,
  COUNT, MIN ou MAX) operadores especiais, relacionais, JOIN, GROUP BY e ORDER BY)
  Descrição: Uma função que retorna a tabela com o total de doações em um certo período de tempo
  ordenadas de forma decrescente.
*/
CREATE OR REPLACE FUNCTION total_doacoes_em (data_inicio DATE, data_fim DATE)
RETURNS TABLE (id_doador INTEGER, nome VARCHAR, total_doacoes DECIMAL(10,2)) AS $$
BEGIN
  RETURN QUERY
  Select 
    d.id_doador, 
    p.nome,
    sum(d.valor) as total_doacoes
  from tb_doacao d
  inner join tb_pessoa p on d.id_doador = p.id_pessoa
  where d.criado_em::DATE between data_inicio and data_fim
  group by d.id_doador, p.nome
  order by total_doacoes desc;
END;
$$ LANGUAGE plpgsql;

/*
  m) Crie um trigger que dispare dados em alguma tabela após de alguma ação no banco de dados
  Descrição: Trigger que checará se o instrutor pertence ao grupo 'Liderança'
*/
CREATE OR REPLACE FUNCTION validar_instrutor()
RETURNS TRIGGER AS $$
BEGIN
  -- Verifica se o instrutor pertence ao grupo 'Liderança'
  IF NOT EXISTS (
    Select 1
    from tb_membro
    where id_membro = NEW.id_instrutor AND grupo = 'Liderança'
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

/*
  n) Crie um trigger de verificação antes de executar alguma ação no banco de dados.
  Descrição: trigger para verificar se um desbravador pode virar da liderança.
*/
CREATE OR REPLACE FUNCTION check_age_to_Lideranca()
RETURNS TRIGGER AS $$
BEGIN
  -- Verifica se o membro é do grupo 'Desbravador' e completou 16 anos
  IF NEW.grupo = 'Desbravador' AND
    AGE(CURRENT_DATE, NEW.dt_nascimento) >= INTERVAL '16 years' THEN
    -- Atualiza o grupo para 'Liderança'
    NEW.grupo := 'Liderança';
    -- Define o cargo como NULL
    NEW.cargo := NULL;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_trocar_grupo
BEFORE INSERT OR UPDATE ON tb_membro
FOR EACH ROW
EXECUTE FUNCTION check_age_to_Lideranca();

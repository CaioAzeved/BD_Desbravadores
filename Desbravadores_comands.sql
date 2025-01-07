
-- a)Faça uma consulta que contenha pelo menos dois operadores especiais (BETWEEN,
--LIKE, IN)

-- Descrição: Retornar todos os aniversariantes de janeiro da liderança
SELECT *
FROM tb_membro
WHERE TO_CHAR(dt_nascimento, 'MM-DD') BETWEEN '01-01' AND '01-31'
  AND cargo LIKE 'Liderança';

--b) Faça 1 consulta com funções de agregação e utilize também operadores lógicos e
--especiais (cada consulta deve ter uma função de agregação diferente)
-- Descrição: Contar quantas pessoas não são membros do clube
Select count(*) from tb_pessoa where not id_pessoa in (Select id_membro from tb_membro); 

--c) Faça um nova consulta com uma função de agregação, uma operadores lógicos,
--operadores relacionais onde o resultados seja apresentado em ordem crescente ou
--decrescente
-- Descrição: Ordenar a soma de todas as doações feitas pelas pessoas desde que o valor seja maior do que 100

--d) Faça uma consulta que utilize o GROUP BY e a cláusula HAVING

-- Descrição: Agrupar membros pelo grupo e ordenar pela soma das especialidades, desde que a soma seja maior do que 5

--e) Faça uma consulta utilizando INNER JOIN
-- Descrição: Recuperar o nome dos contatos de emergência de alguém do clube e que também são do clube


-- f) Faça uma consulta utilizando LEFT JOIN
-- Descrição: Recuperar o nome e o telefone de todos os membros do clube

-- g) Faça uma consulta utilizando RIGHT JOIN
-- Descrição: Recuperar o nome e o telefone de todos os doadores 

-- h)Faça um consulta com a união de 3 tabelas (utilize qualquer JOIN) e que seu resultado
--seja de ordem crescente
-- Descrição: 

-- i)
-- Descrição:

-- j)
-- Descrição:

-- k)
-- Descrição:

-- l)
-- Descrição:

-- m)
-- Descrição:

-- n) Crie um trigger de verificação antes de executar alguma ação no banco de dados
-- Descrição: trigger para verificar se um desbravador pode virar da liderança
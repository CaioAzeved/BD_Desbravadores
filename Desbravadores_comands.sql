
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
Select id_doador, sum(valor)
from tb_doacao
where valor > 100.00 and metodoPagamento = 'Pix'
group by id_doador
order by sum(valor) desc;

/*
  d) Faça uma consulta que utilize o GROUP BY e a cláusula HAVING
  Descrição: Agrupar membros pelo grupo e ordenar pela soma das especialidades, desde que a soma 
  seja maior do que 5
*/


/*
  e) Faça uma consulta utilizando INNER JOIN
  Descrição: Recuperar o nome dos contatos de emergência de alguém do clube e que também são do clube
*/


/*
  f) Faça uma consulta utilizando LEFT JOIN
  Descrição: Recuperar o nome e o telefone de todos os membros do clube
*/


/*
  g) Faça uma consulta utilizando RIGHT JOIN
  Descrição: Recuperar o nome e o telefone de todos os doadores 
*/


/*
  h) Faça um consulta com a união de 3 tabelas (utilize qualquer JOIN) e que seu resultado
  seja de ordem crescente
  Descrição: Conseguir o nome dos membros que fizeram doações
*/


/*
  i)Crie uma função que retorna a uma tabela. A função deve ter condições.
  Descrição: Retornar a tabela das especialidades desde que o número de membros que as possuem seja maior ou igual a 3
*/


/*
  j) Crie uma função que processam um conjunto de valores e retornam a um valor
  Descrição: Será passado um array com os ids das doações e será retornado o nome do doador que fez a maior doação
*/


/*
  k) Crie uma função VOID (Não retorna a nenhum valor mas executa alguma operação)
  Descrição: Modificar o cargo de algum membro
*/


/*
  l) Crie uma função da sua preferência que utilize funções de agregação (AVG, SUM,
  COUNT, MIN ou MAX) operadores especiais, relacionais, JOIN, GROUP BY e ORDER BY)
  Descrição:
*/



/*
  m) Crie um trigger que dispare dados em alguma tabela após de alguma ação no banco de dados
  Descrição: Trigger colocará as datas de atualização de um dado automaticamente após a dar update
  neste.
*/


/*
  n) Crie um trigger de verificação antes de executar alguma ação no banco de dados.
  Descrição: trigger para verificar se um desbravador pode virar da liderança.
*/
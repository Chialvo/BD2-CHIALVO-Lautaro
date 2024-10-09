/*Exercises
For all the exercises include the queries in the class file.

1- Create two or three queries using address table in sakila db:

include postal_code in where (try with in/not it operator)
eventually join the table with city/country tables.
measure execution time.
Then create an index for postal_code on address table.
measure execution time again and compare with the previous ones.
Explain the results
2- Run queries using actor table, searching for first and last name columns independently. Explain the differences and why is that happening?

3- Compare results finding text in the description on table film with LIKE and in the film_text using MATCH ... AGAINST. Explain the results.
*/

-- 1 ------------------------

SELECT a.address, a.postal_code, c.city, co.country
FROM address a
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id
WHERE a.postal_code IN ('12345', '67890', '54321');
-- RUN TIME: 0.0013 sec

SELECT a.address, a.postal_code, c.city, co.country
FROM address a
JOIN city c ON a.city_id = c.city_id
JOIN country co ON c.country_id = co.country_id
WHERE a.postal_code NOT IN ('12345', '67890', '54321');
-- RUN TIME: 0.0036 sec

CREATE INDEX idx_postal_code ON address (postal_code);

-- RUN TIME: 0.0011 sec
-- RUN TIME: 0.0020 sec

/*
Antes de crear el índice, las consultas probablemente tardan más tiempo en ejecutarse, especialmente porque la tabla address tiene una gran cantidad de registros.
Esto es porque MySQL tiene que realizar una búsqueda completa de todas las filas para encontrar las coincidencias en la columna postal_code.
Después de crear el índice, las consultas deberían ejecutarse más rápidamente, ya que MySQL puede utilizar el índice para buscar las filas que coincidan
con los códigos postales específicos de manera mucho más eficiente.
*/

-- 2 ------------------------

SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name = 'John';

SELECT actor_id, first_name, last_name 
FROM actor 
WHERE last_name = 'Doe';

/*
La consulta que busca por first_name podría ser más lenta en comparación con last_name porque
normalmente los nombres se distribuyen de manera menos uniforme que los apellidos.
En general, se recomienda agregar índices en las columnas que se usan frecuentemente en cláusulas WHERE para mejorar el rendimiento.
*/

-- 3 ------------------------

SELECT f.film_id AS 'ID', f.title AS 'Title', f.description AS 'Description Text' FROM film f WHERE f.description LIKE '%Girl%';
SELECT ft.film_id AS 'ID', ft.title AS 'Title', ft.description AS 'Description Text' FROM film_text ft WHERE MATCH(ft.title, ft.description) AGAINST ('Girl');

/*
Al comparar estas dos consultas, la diferencia más importante es que la consulta que usa MATCH / AGAINST es más rápida que la que usa LIKE.
Esto sucede porque el operador LIKE revisa toda la tabla, comprobando cada fila de la columna description para ver si contiene la palabra 'Girl',
lo cual no es eficiente cuando hay mucho texto. En cambio, MATCH / AGAINST utiliza el índice FULLTEXT que se creó en la tabla film_text, lo que
permite encontrar los resultados rápidamente sin revisar cada fila.
Esto significa que, para consultas que necesitan analizar campos de texto largos, crear un índice FULLTEXT es lo mejor para filtrar los resultados
de manera eficiente. Sin embargo, LIKE sigue siendo útil para textos más pequeños o patrones simples. Dependiendo del tamaño y tipo de datos que
se busquen, usar índices FULLTEXT puede mejorar mucho el rendimiento en comparación con LIKE
*/
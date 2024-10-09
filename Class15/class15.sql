USE sakila;
/* Create a view named list_of_customers, it should contain the following columns:
customer id
customer full name,
address
zip code
phone
city
country
status (when active column is 1 show it as 'active', otherwise is 'inactive')
store id

2- Create a view named film_details, it should contain the following columns: film id, title, description, category, price, length, rating, actors - as a string of all the actors separated by comma. Hint use GROUP_CONCAT

3- Create view sales_by_film_category, it should return 'category' and 'total_rental' columns.

4- Create a view called actor_information where it should return, actor id, first name, last name and the amount of films he/she acted on.

5- Analyze view actor_info, explain the entire query and specially how the sub query works. Be very specific, take some time and decompose each part and give an explanation for each.

6- Materialized views, write a description, why they are used, alternatives, DBMS were they exist, etc.
*/
-- 1 -------------------------


DROP VIEW list_of_customers;

CREATE VIEW list_of_customers AS
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS 'Full Name', a.address, a.postal_code AS 'Zip Code', a.phone AS 'Phone',
 ci.city, co.country, CASE WHEN c.active = 1 THEN 'Active' ELSE 'Inactive' END AS 'Status', store_id
FROM customer c 
INNER JOIN address a USING (address_id)
INNER JOIN city ci USING (city_id)
INNER JOIN country co USING (country_id);

SELECT *
FROM list_of_customers;

SELECT c.customer_id, CONCAT(c.first_name, " ", c.last_name) AS full_name, a.address
FROM customer c INNER JOIN address a USING (address_id);

-- 2 -------------------------

CREATE VIEW film_details AS
	SELECT f.film_id AS 'Film ID', f.title AS 'Title', f.description AS 'Description', cat.name AS 'Category', f.rental_rate AS 'Price',
    f.length AS 'Length', f.rating AS 'Rating', GROUP_CONCAT(' ', a.first_name, ' ', a.last_name) AS 'Actors'
    FROM film f INNER JOIN film_category fc USING (film_id) INNER JOIN category cat USING (category_id) 
    INNER JOIN film_actor fa USING (film_id) INNER JOIN actor a USING (actor_id) GROUP BY f.film_id, cat.name;

SELECT * FROM film_details;
DROP VIEW film_details;

-- 3 -------------------------

CREATE VIEW sales_by_film_category_the_sequel AS
	SELECT c.name AS 'Category', COUNT(r.rental_id) AS 'Total_rental' 
    FROM category c INNER JOIN film_category USING (category_id) INNER JOIN film f USING (film_id) 
    INNER JOIN inventory i USING (film_id) INNER JOIN rental r USING (inventory_id) GROUP BY c.category_id;
    
SELECT * FROM sales_by_film_category_the_sequel;

-- 4 -------------------------

CREATE VIEW actor_information AS
	SELECT a.actor_id AS 'Actor ID', a.first_name AS 'Name', a.last_name AS 'Surname', COUNT(fa.film_id) AS 'Films acted'
    FROM actor a INNER JOIN film_actor fa USING (actor_id) GROUP BY a.actor_id;
    
SELECT * FROM actor_information;

-- 5 -------------------------

SELECT * FROM actor_info;

/*
La vista actor_info tiene como objetivo mostrar información de cada actor en la base de datos, junto con las películas en 
las que han participado, agrupadas por la categoría de dichas películas. La consulta selecciona los campos actor_id, first_name,
last_name y un campo llamado film_info, que contiene una concatenación de cada categoría distinta y una lista de todas las
películas en las que el actor ha aparecido dentro de esa categoría. Esto se logra mediante un LEFT JOIN que conecta las
tablas actor, film_actor, film_category y category para obtener los datos de las películas en las que ha trabajado cada actor y sus respectivas categorías.
Este tipo de unión asegura que los actores que no han participado en ninguna película también se incluyan en el resultado.
La subquery que construye el campo film_info funciona de la siguiente manera: primero, el GROUP_CONCAT externo se encarga de concatenar
 el nombre de cada categoría con el resultado de la subconsulta interna, utilizando un separador de dos puntos (:).
 La subconsulta interna devuelve un GROUP_CONCAT de todos los títulos de películas (ordenados alfabéticamente y separados por comas)
 para cada película que coincida tanto con el category_id de la categoría actual (de la tabla film_category) como con el actor_id del actor actual
 (de la tabla film_actor). De esta forma, el resultado final de la vista mostrará: actor_id, first_name, last_name, y un campo
 con el formato [categoría1: película1, película2..., categoría2:...] para cada actor.
*/

-- 6 -------------------------

/*
Una vista materializada es una vista especial que guarda el resultado de una consulta como una tabla real en el disco de la computadora.
A diferencia de las vistas normales, que muestran datos en tiempo real cuando las consultas se hacen, las vistas materializadas guardan
una copia de esos datos en un momento determinado. Esto es útil porque permite acceder a la información rápidamente sin tener que hacer
de nuevo la consulta completa, lo cual es importante cuando la consulta es muy grande o complicada. Sin embargo, la vista materializada
no se actualiza sola, por lo que la información puede quedar desactualizada si no se actualiza manualmente.
Este tipo de vista es útil cuando tenemos que hacer muchas operaciones en las tablas—como unir datos o hacer cálculos—y no necesitamos
que los datos estén actualizados todo el tiempo. Por ejemplo, un reporte que se hace cada cierto tiempo y no requiere cambios instantáneos.
Existen algunas alternativas a las vistas materializadas, como las vistas normales y los índices. Las vistas normales siempre se actualizan
automáticamente, pero pueden ser más lentas cuando las consultas son muy grandes. Los índices permiten guardar parte de los datos en la memoria
RAM para que se pueda acceder a ellos rápidamente, pero no funcionan para todo y si usamos muchos pueden hacer más lenta la base de datos.
Algunos sistemas de bases de datos que permiten usar vistas materializadas son Oracle, PostgreSQL, Snowflake y BigQuery de Google.
Aunque MySQL no tiene vistas materializadas de forma nativa, se pueden simular usando vistas normales junto con triggers (disparadores).
*/
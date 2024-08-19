USE sakila;


-- 1) Get Customers Living in Argentina

SELECT CONCAT(first_name, ' ', last_name) AS full_name, address, city
FROM customer
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id
WHERE country.country = 'Argentina';


-- 2) Show Film Title, Language, and Rating (Using CASE)

SELECT film.title, language.name AS language,
    CASE
        WHEN film.rating = 'G' THEN 'General Audiences'
        WHEN film.rating = 'PG' THEN 'Parental Guidance Suggested'
        WHEN film.rating = 'PG-13' THEN 'Parents Strongly Cautioned'
        WHEN film.rating = 'R' THEN 'Restricted'
        WHEN film.rating = 'NC-17' THEN 'Adults Only'
        ELSE 'Not Rated'
    END AS full_rating
FROM film
JOIN language ON film.language_id = language.language_id;


-- 3) Show Films by an Actor

SELECT film.title, film.release_year
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE CONCAT(actor.first_name, ' ', actor.last_name) LIKE CONCAT('%', REPLACE(REPLACE(REPLACE(REPLACE(TRIM(LOWER('JOHN DOE')), '.', ''), ',', ''), ' ', ''), '-', ''), '%');


-- 4) Find Rentals in May and June

SELECT film.title, CONCAT(customer.first_name, ' ', customer.last_name) AS customer_name,
    CASE 
        WHEN rental.return_date IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS returned
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
JOIN customer ON rental.customer_id = customer.customer_id
WHERE MONTH(rental.rental_date) IN (5, 6);


-- 5) CAST and CONVERT Functions in MySQL
-- En MySQL, tanto CAST como CONVERT se utilizan para cambiar el tipo de datos de una expresión.
-- Ambas funciones son similares, pero CONVERT tiene una opción adicional para convertir entre diferentes conjuntos de caracteres.
-- Ejemplo:

SELECT 
    CAST(123 AS CHAR) AS cast_example,
    CONVERT(123, CHAR) AS convert_example;
    
    
-- 6) NVL, ISNULL, IFNULL, COALESCE Functions
-- NVL: Disponible en Oracle, reemplaza NULL con el valor especificado.
-- ISNULL: Disponible en MySQL y SQL Server, similar a NVL.
-- IFNULL: Específica de MySQL, reemplaza NULL con un valor especificado.
-- COALESCE: Disponible en la mayoría de las bases de datos SQL, devuelve la primera expresión no nula en la lista.
-- MySQL Ejemplos:

SELECT 
    IFNULL(NULL, 'default_value') AS ifnull_example,
    COALESCE(NULL, NULL, 'default_value') AS coalesce_example;
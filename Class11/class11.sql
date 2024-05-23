USE sakila;

-- Find all the film titles that are not in the inventory.

SELECT *
  FROM film AS f
      LEFT OUTER JOIN inventory AS i USING (film_id)
      WHERE i.inventory_id IS NULL;

-- Find all the films that are in the inventory but were never rented.

SELECT f.title, i.inventory_id
FROM film f 
INNER JOIN inventory i USING (film_id)
LEFT JOIN rental r USING (inventory_id)
WHERE r.rental_id IS NULL;

-- Generate a report with: customer (first, last) name, store id, film title, when the film was rented and returned for each of these customers order by store_id, customer last_name

SELECT CONCAT(c.first_name, ' ', c.last_name) AS Nombre, s.store_id, f.title
FROM customer c
INNER JOIN store s USING (store_id)
INNER JOIN rental r USING (customer_id)
INNER JOIN inventory i USING (inventory_id)
INNER JOIN film f USING (film_id)
WHERE r.return_date IS NOT NULL
ORDER BY s.store_id, c.last_name;

-- Show sales per store (money of rented films), show store's city, country, manager info and total sales (money), (optional) Use concat to show city and country and manager first and last name

SELECT co.country, ci.city, ma.*, SUM(pa.amount) AS amount
FROM country co 
INNER JOIN city ci USING (country_id)
INNER JOIN address d USING (city_id)
INNER JOIN store st USING (address_id)
INNER JOIN staff ma ON manager_staff_id = ma.staff_id
INNER JOIN rental r USING (staff_id)
INNER JOIN payment pa USING (rental_id)
GROUP BY st.store_id, co.country_id;

-- Which actor has appeared in the most films?

SELECT a1.*, COUNT(f_a.film_id) AS cantidad
FROM actor a1
INNER JOIN film_actor f_a USING (actor_id)
INNER JOIN film f USING (film_id)
GROUP BY a1.actor_id
HAVING cantidad > ALL 
	(SELECT COUNT(fa.film_id) AS cant_films
	FROM actor a2
	INNER JOIN film_actor fa ON a2.actor_id = fa.actor_id
	WHERE a2.actor_id != a1.actor_id
GROUP BY a2.actor_id);
USE sakila;

-- Add Customer

INSERT INTO customer(store_id,address_id, first_name, last_name, email)
VALUES(1,
	(SELECT max(address_id) FROM address a INNER JOIN city c ON c.city_id=a.city_id INNER JOIN country co ON c.country_id=co.country_id WHERE co.country='United States')
    , 'CustomerInsert', 'insert', 'customer@gmail.com');

-- Add Rental

INSERT INTO rental (rental_date,inventory_id, staff_id, customer_id) 
VALUES(
	now(),
	(SELECT inventory_id FROM inventory i INNER JOIN film f ON f.film_id=i.film_id WHERE f.title='MODEL FISH' LIMIT 1),
	(SELECT max(staff_id) FROM staff WHERE store_id=2),
	3
);

-- Update Film based on Rating

UPDATE film 
SET release_year = '2001'
WHERE rating = 'G';

UPDATE film 
SET release_year = '2002'
WHERE rating = 'PG';

UPDATE film 
SET release_year = '2003'
WHERE rating = 'NC-17';

UPDATE film 
SET release_year = '2004'
WHERE rating = 'PG-13';

UPDATE film 
SET release_year = '2005'
WHERE rating = 'R';

SELECT *
FROM film
ORDER BY rating;

-- Return Film

UPDATE rental 
SET return_date=now()
WHERE rental_id=(SELECT max(rental_id) WHERE return_date IS NULL);
SELECT *
FROM rental
WHERE rental_id = 5;

-- Try to delete a film
DELETE FROM film 
WHERE film_id = 1;

DELETE FROM film_actor 
WHERE film_id = 1;

DELETE FROM film_category 
WHERE film_id = 1;

DELETE FROM rental 
WHERE inventory_id IN (SELECT inventory_id FROM inventory WHERE film_id = 1);

DELETE FROM inventory 
WHERE film_id = 1;

DELETE FROM film 
WHERE film_id = 1;

SELECT *
FROM film
ORDER BY film_id ASC;

-- Rent a film

SELECT inventory_id
FROM inventory i
LEFT OUTER JOIN rental r USING (inventory_id)
WHERE r.rental_id IS NULL
LIMIT 1;

insert into rental (rental_date,inventory_id,customer_id,staff_id) values (
	NOW(), 
	(5), 
    (SELECT customer_id FROM customer LIMIT 1), 
    (SELECT staff_id FROM staff LIMIT 1));

INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
VALUES (
    (SELECT customer_id FROM rental WHERE inventory_id = 5 LIMIT 1),
    (SELECT staff_id FROM rental WHERE inventory_id = 5 LIMIT 1),   
    (SELECT max(rental_id) FROM rental WHERE inventory_id = 5),  
    466, 
    NOW() 
);
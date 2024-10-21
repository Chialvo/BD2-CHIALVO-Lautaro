USE sakila;



-- QUERY 1 - Write a function that returns the amount of copies of a film in a store in sakila-db. Pass either the film id or the film name and the store id.

DELIMITER //
	CREATE PROCEDURE FetchFilmsFromStore(IN titleOrID VARCHAR(50), IN storeID INT, OUT total INT)
    BEGIN
		SELECT COUNT(i.film_id) INTO total FROM inventory i INNER JOIN film f USING (film_id) 
        WHERE i.store_id = storeID AND (i.film_id = titleOrID OR f.title = titleOrID) GROUP BY f.film_id;
	END //
DELIMITER ;

CALL FetchFilmsFromStore('ACE GOLDFINGER', 1, @total);
SELECT @total;

-- QUERY 2 - Write a stored procedure with an output parameter that contains a list of customer first and last names separated by ";", that live in a certain country. 
-- You pass the country it gives you the list of people living there. USE A CURSOR, do not use any aggregation function (ike CONTCAT_WS).

DELIMITER //
	CREATE PROCEDURE FetchCustomerListInCountry(IN countryNameOrID VARCHAR(50), OUT customerList VARCHAR(5000))
    BEGIN
		DECLARE finished INT DEFAULT 0;
        DECLARE customerInfo VARCHAR(100) DEFAULT "";
    
		DECLARE customer_cursor CURSOR FOR
			SELECT CONCAT(c.first_name, ' ', c.last_name) FROM customer c INNER JOIN address a USING (address_id) 
            INNER JOIN city ci USING (city_id) INNER JOIN country co USING (country_id) WHERE co.country_id = countryNameOrID OR co.country = countryNameOrID;
		
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
		
        SET customerList = "";
        
        OPEN customer_cursor;
        
        get_customer_info: LOOP
			FETCH customer_cursor INTO customerInfo;
            
            IF finished = 1 THEN
				LEAVE get_customer_info;
			END IF;
            
            SET customerList = CONCAT(customerInfo, '; ', customerList);
		END LOOP get_customer_info;
        
        CLOSE customer_cursor;
	END //
DELIMITER ;

CALL FetchCustomerListInCountry(2, @customerList);
SELECT @customerList;

-- QUERY 3 - Review the function inventory_in_stock and the procedure film_in_stock explain the code, write usage examples.


/*  
La función `inventory_in_stock` sirve para saber si un artículo en el inventario de la tienda está disponible para alquilar.  
Primero, recibe como parámetro un `inventory_id` (el identificador del artículo) y revisa si ese artículo fue alquilado. Lo hace contando las filas en la tabla de alquileres (`rental`) que coinciden con ese `inventory_id`.  

Si no hay alquileres registrados, la función devuelve `TRUE`, lo que significa que el artículo está en stock y se puede alquilar.  
Si sí hay alquileres, pasa al siguiente paso: revisa si alguno de esos alquileres no fue devuelto (es decir, si tiene la fecha de devolución en blanco).  
- Si todos los alquileres fueron devueltos, la función devuelve `TRUE` porque el artículo ya está disponible otra vez.  
- Si al menos uno no fue devuelto, la función devuelve `FALSE`, indicando que el artículo sigue fuera.  

Ahora, el procedimiento `film_in_stock` funciona de forma parecida, pero en lugar de revisar un solo artículo, cuenta cuántas copias de una película están disponibles en una tienda específica.  
Este procedimiento recibe dos datos: el identificador de la película (`p_film_id`) y el identificador de la tienda (`p_store_id`).  

Primero, busca todos los artículos del inventario que coinciden con esa película y tienda, y que están disponibles (usando la función `inventory_in_stock` para comprobarlo).  
Después, cuenta cuántas copias están en stock y guarda ese número en una variable llamada `p_film_count`. Por último, devuelve ese número para decir cuántas copias de la película se pueden alquilar en esa tienda.  
*/  

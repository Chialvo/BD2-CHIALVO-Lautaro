USE sakila;

# Exercises
# Needs the employee table (defined in the triggers section) created and populated.

#1- Insert a new employee to , but with an null email. Explain what happens.

INSERT INTO employees(employeeNumber, lastName, firstName , extension, officeCode, reportsTo, jobTitle, email) 
VALUES (4000,'Juan','Perez','x0486','1','1002','RH Manager', NULL);

-- Error Code: 1048. Column 'email' cannot be null.
-- Esto se debe a que, al crear la tabla de empleados, se añadió una restricción NOT NULL al campo de correo electrónico para evitar la inserción de valores nulos.

# 2- Run the first the query
# What did happen?
UPDATE employees SET employeeNumber = employeeNumber - 20;

-- Cada valor de employeeNumber en la tabla employees se reduce en 20. 
-- Por ejemplo, los valores de los empleados insertados eran (1002, 1056, 1076) y después de la consulta se convirtieron en (982, 1036, 1056)

# Explain this case also.
UPDATE employees SET employeeNumber = employeeNumber + 20;

/*
Error Code: 1062. Duplicate entry '1056' for key 'employees.PRIMARY'.
Esto ocurre porque cada employeeNumber se incrementa en el orden en que fueron declarados.
En este caso, el segundo empleado se establece en 1056, un valor que ya existe antes de que el employeeNumber existente con ese valor sea incrementado.
Dado que no pueden existir dos valores iguales para la clave primaria, se lanza el error mencionado.
*/

# 3- Add a age column to the table employee where and it can only accept values from 16 up to 70 years old.

ALTER TABLE employees 
ADD COLUMN age INT DEFAULT 16, 
ADD CONSTRAINT check_age CHECK (age BETWEEN 16 AND 70);

# 4- Describe the referential integrity between tables film, actor and film_actor in sakila db.

/*
La integridad referencial entre esas tablas se mantiene mediante una clave foránea que conecta la tabla film con actor a través de una tabla intermedia. 
Esta tabla intermedia almacena las claves primarias de ambas tablas y no permite eliminar ningún film o actor sin antes eliminar las entradas correspondientes en film_actor. 
*/

# 5- Create a new column called lastUpdate to table employee and use trigger(s) to keep the date-time updated on inserts and updates operations. 
# Bonus: add a column lastUpdateUser and the respective trigger(s) to specify who was the last MySQL user that changed the row (assume multiple users, other than root, can connect to MySQL and change this table).

ALTER TABLE employees ADD COLUMN lastUpdate DATETIME, ADD COLUMN lastMySqlUser VARCHAR(100);
CREATE TRIGGER before_employees_update BEFORE UPDATE ON employees FOR EACH ROW SET NEW.lastUpdate = NOW(), NEW.lastMySqlUser = USER();

# 6- Find all the triggers in sakila db related to loading film_text table. What do they do? Explain each of them using its source code for the explanation.


-- Hay 3 triggers relacionados con su carga:

#1
CREATE TRIGGER `ins_film` AFTER INSERT ON `film` 
FOR EACH ROW 
BEGIN
    INSERT INTO film_text (film_id, title, description)
        VALUES (NEW.film_id, NEW.title, NEW.description);
END;;

-- Inserta un registro en la tabla `film_text` después de que se crea un `film`, utilizando los valores del nuevo `film` para sus campos.

#2
CREATE TRIGGER `upd_film` AFTER UPDATE ON `film`
FOR EACH ROW 
BEGIN
    IF (OLD.title != NEW.title) OR (OLD.description != NEW.description) OR (OLD.film_id != NEW.film_id)
    THEN
        UPDATE film_text
            SET title = NEW.title,
                description = NEW.description,
                film_id = NEW.film_id
        WHERE film_id = OLD.film_id;
    END IF;
END;;

-- Se ejecuta después de que un `film` es actualizado, si el `title`, `description` o `film_id` de un `film` son modificados, el `film_text` correspondiente, cuyo `film_id` coincide con el `film` modificado, también recibirá estas actualizaciones.

#3
CREATE TRIGGER `del_film` AFTER DELETE ON `film`
FOR EACH ROW 
BEGIN
    DELETE FROM film_text WHERE film_id = OLD.film_id;
END;;

-- Después de que un `film` es eliminado, el `film_text` correspondiente, cuyo `film_id` coincidía con el `film` eliminado, también será eliminado.

/*
Estos triggers están diseñados para crear un registro en `film_text` cada vez que se inserta un `film`, utilizando sus valores.
Cuando un `film` se actualiza o elimina, se aplica el mismo tratamiento a su correspondiente `film_text`.
*/